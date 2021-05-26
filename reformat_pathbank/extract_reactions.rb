#!/usr/bin/env ruby


# Package requirements
# -----------------------------------------------------------------------------


require "json"
require "nokogiri"


# Function definitions
# -----------------------------------------------------------------------------


# Helper function to read and parse an XML with Nokogiri, and remove the
# namespaces
def parse_xml(path)
  return Nokogiri::XML(File.read(path).rstrip).remove_namespaces!
end

# Abstracted reducer function to match compounds with IDs in reaction data
def reduce_cpid(acc, crt)
  rex = /(?<=\/)(?<id>PW_C\d{6})/
  cpid = crt.values[0].match(rex)
  acc << cpid[:id] if not cpid.nil?
  return acc
end

# Helper function to return the appropriate conversion direction for a
# reaction, or `nil` if not found
def conversion_direction(node)
  cdir = node.at_xpath("./conversionDirection")
  return nil if cdir.nil?
  return cdir.text
end

# Collect the compound details for the current biochemical reaction
def compound_details(node)
  id = node.values[0].split("/")[1]
  dir = conversion_direction(node)
  left = node.xpath("./left").reduce(Array.new) {|a, c| reduce_cpid(a, c) }
  right = node.xpath("./right").reduce(Array.new) {|a, c| reduce_cpid(a, c) }
  return {:id => id, :lhs => left, :rhs => right, :dir => dir}
end

# Collect the reaction details for the current pathway definition XML
def reaction_details(xml)
  pw = xml.xpath("//Pathway").reject {|node| node.xpath("./name").length > 0 }
  id = pw[0].values[0].split("/").last
  dt = xml.xpath("//BiochemicalReaction").map {|node| compound_details(node) }
  return {:smpdb_id => id, :reactions => dt}
end


# Operations
# -----------------------------------------------------------------------------


# Define IO paths
path = {
  :in => {:dir => "./data/pathbank_all_biopax"},
  :out => "./reactions_extracted.json"
}

# Get the files to operate on, and sort
files = Dir.entries(path[:in][:dir]).reject {|e| e == "." || e == ".." }
files.sort!

# Collect the reaction details from all files
print("\033[7;34mRetrieving reaction details\033[0m\n")
data = files.map do |file|
  reaction_details(parse_xml("#{path[:in][:dir]}/#{file}"))
end

# Write to the output file
print("\033[7;36mWriting output JSON\033[0m\n")
File.open(path[:out], :mode => "w") do |file|
  file.write("#{JSON.pretty_generate(data)}\n")
end

print("\033[7;32mEnd of operations\033[0m\n")
exit 0
