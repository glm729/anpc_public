#!/usr/bin/env ruby

# Read the reaction and equation data
data = File.read('../R/data/rfReacEqn.tsv').split(/\n/)
  .map{|r| r.gsub(/(?<!\\)"/, '').split(/\t/)};

# Remove the header row
data.delete_at(0);

# Split the equation by arrow
spl = data.map{|e| e[1].split(/>/)};

# Split sides by space and get compound IDs only
com = spl.map{|r|
  r.map{|e|
    e.split(/ /).select{|i|
      # Only grab strings that match
      i.match?(/^C\d{5}/)
    }.map{|s|
      # but strip off the trailing bracketed section, if any
      s.gsub(/(?<=\d)(\(.+)/, '')
    }
  }
};

# Open the file to write
f = File.open('./data/rfReacOppose.tsv', 'w');

# Initialise output contents
f.write("idReaction\tlhs\trhs\n");

# Loop over the input rows and write to the file
com.each_index{|i| com[i][0].each{|l| com[i][1].each{|r|
  f.write("#{data[i][0]}\t#{l}\t#{r}\n")
}}};

# Close the file
f.close();
