#!/usr/bin/env ruby


# Package requirements
# -----------------------------------------------------------------------------


require "csv"
require "json"


# Function definitions
# -----------------------------------------------------------------------------


# Generate a dummy header of length `len`
def dummy_header(len)
  l = len.to_s.length
  return (0...len).map {|i| "X#{i.to_s.rjust(l, "0")}" }
end

# Helper to get the header detail of the current file, for parsing a CSV
def header_detail(path, header=nil)
  skip_idx = 1
  if header.nil?
    top = CSV.parse_line(File.open(path, &:readline).rstrip)
    header = dummy_header(top.length)
    skip_idx = 0
  end
  return {:header => header, :skip => skip_idx}
end

# Shorthand function to convert a CSV row to Hash
def convert_csv_row(row, header)
  return header.map.with_index {|h, i| [h, row[i]] }.to_h
end

# Shorthand function to pick a set of data in a hash which match a key set
def select_data(data, keys)
  return data.select {|k, v| keys.any?(k) }
end

# Fragment a CSV row into metabolite data and pathways data
def fragment_row(row, header, meta_keys, path_keys)
  data = convert_csv_row(row, header)
  meta_data = select_data(data, meta_keys)
  path_data = select_data(data, path_keys)
  id = meta_data["Metabolite ID"]
  return {:id => id, :meta => meta_data, :path => path_data}
end

# Main operative function for parsing the PathBank All Metabolites CSV
def parse_csv(path, header=nil, path_keys=nil)
  raise "Need path_keys to proceed" if path_keys.nil?
  result = Hash.new
  head_detail = header_detail(path, header=header)
  meta_keys = head_detail[:header].reject {|k| path_keys.any?(k) }
  File.foreach(path).with_index do |line, idx|
    next if idx < head_detail[:skip]
    row = CSV.parse_line(line)
    frag = fragment_row(row, head_detail[:header], meta_keys, path_keys)
    id = frag[:id]
    if result[id].nil?
      result[id] = frag[:meta]
      result[id]["Pathways"] = Array.new
    end
    result[id]["Pathways"] << frag[:path]
  end
  return result
end


# Operations
# -----------------------------------------------------------------------------


# Define paths to use for file IO
path = {
  :in => "./data/pathbank_all_metabolites.csv",
  :out => "./data/pathbank_all_metabolites.json"
}

# Define the set of keys to use for pathways-only data
path_keys = ["PathBank ID", "Pathway Name", "Pathway Subject", "Species"]

# Get the header information and parse the CSV
print("\033[7;34mReading and parsing CSV\033[0m\n")
header = CSV.parse_line(File.open(path[:in], &:readline).rstrip)
data = parse_csv(path[:in], header=header, path_keys=path_keys)

# "Flatten" the data from a Hash to an Array
print("\033[7;36mConverting to array-type JSON\033[0m\n")
final = data.map {|k, v| v }

# Write to the output file
print("\033[7;36mWriting output JSON\033[0m\n")
File.open(path[:out], :mode => "w") do |file|
  file.write("#{JSON.pretty_generate(final)}\n")
end

print("\033[7;32mEnd of operations\033[0m\n")
exit 0
