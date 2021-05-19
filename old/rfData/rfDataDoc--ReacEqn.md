# Extracting equation information from KEGG Reaction data
#### Mr. George L. Malone
#### 8<sup>th</sup> of December, 2020

### Contents
1.  Outline
2.  Required data
3.  *R* script
4.  Ruby script

## Outline

The following process was used to extract the equation information for each
individial reaction, as listed in KEGG Reaction (via `KEGGREST` in *R*).
Initially, *R* is used to reformat the KEGG Reaction data, extracting the
equation and writing the reaction IDs and corresponding equations to a TSV
file.  Next, Ruby is used to extract information regarding opposition of
compounds -- that is, which compounds are on opposite sides of the reaction
equation.  This also preserves which reaction each opposing pair are identified
in, for later reference if desired.

## Required data

The following operations assume that the user has access to the file
`dr.RData`, which contains data for 11208 reactions, collected via `KEGGREST`
in *R*.  Incidentally, `dr` is shorthand for `dataReaction`.

## *R* script

The following *R* script is used to extract the reaction equations and list
them alongside their corresponding reaction IDs.  The resulting dataframe is
written to a TSV.

```r
# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Load in the data
load("./data/dr.RData")
# ^ This relies upon a data object containing details of 11208 reactions, as
# listed in the KEGG Reaction database, retrieved via KEGGREST.
# `dr` is shorthand for `dataReaction`.

# Get the equations
eqn <- lapply(
  seq_along(dr),
  function(i) {
    e <- dr[[i]][["EQUATION"]]
    if (is.null(e)) return(cbind(names(dr)[i], NA))
    return(cbind(names(dr)[i], e))
  }
)

# Unfold and explicitly convert to dataframe
result <- NULL
for (x in eqn) result <- rbind(result, x)
result <- data.frame(result)
names(result) <- c("idReaction", "equation")

# Write out
write.table(
  result,
  file = "./data/rfReacEqn.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)
```

## Ruby script

The following Ruby script reads the output data from the above *R* script as
raw text, splits into rows by newline, and splits each row by the separator.
The initial read operation also removes unnecessary quotation marks, if any,
but not if the quotation marks are nested.  The equations are then split by the
arrow, and the resulting split is reduced to KEGG Compound IDs only.  The
results of these operations are then written to a TSV file, maintaining the
reaction ID associated with each opposing pair.

```ruby
#!/usr/bin/env ruby

# Read the reaction and equation data
data = File.read('../R/data/rfReacEqn.tsv').split(/\n/)
  .map{|r| r.gsub(/(?<!\\)"/, '').split(/\t/)};

# Remove the header row
data.delete_at(0);

# Split the equation by arrow
spl = data.map{|e| e[1].split(/>/)};

# Split sides by space and get compound IDs only
com = spl.map{|r| r.map{|e| e.split(/ /).select{|i| i.match?(/^C\d{5}$/) }}};

# Open the file to write
f = File.open('./data/rfReacEqn.tsv', 'w');

# Initialise output contents
f.write("idReaction\tlhs\trhs\n");

# Loop over the input rows and write to the file
com.each_index{|i| com[i][0].each{|l| com[i][1].each{|r|
  f.write("#{data[i][0]}\t#{l}\t#{r}\n")
}}};

# Close the file
f.close();
```

The first six rows of the resulting object are shown below.  Note that the row
data are separated by the tab character, so this output here has been adjusted
to display in a neater fashion!

```
idReaction  lhs     rhs
R00001      C00404  C02174
R00001      C00001  C02174
R00002      C00002  C05359
R00002      C00002  C00009
R00002      C00002  C00008
R00002      C00002  C00139
...         ...     ...
```
