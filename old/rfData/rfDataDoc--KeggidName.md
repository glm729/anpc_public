# Getting all names associated with each KEGG Compound ID
#### Mr. George L. Malone
#### 9<sup>th</sup> of December, 2020

### Contents
1.  Outline
2.  *R* script

## Outline

The purpose of the script documented here is to extract the names related to
each entry in KEGG Compound and unfold, resulting in a dataframe (and
subsequent TSV) of two columns -- KEGG Compound ID, and each associated name
listed in the KEGG Compound data.

The result is a long dataframe (16988 rows) at 581kB on disk.  It is hoped that
using this dataset is faster to navigate than operating on the KEGG Compound
data when querying names (especially considering the KEGG Compound data object
sits at about 4.5MB compressed, and takes a couple of seconds to read in).

## *R* script

Below is the *R* script used to reformat the data, and write to a TSV.

```r
# Set working directory
setwd("/anpc_public/rfData/R/");  # Set this as required.

# Load in the required data
load("./data/dc.RData");

# Get the names for each compound
nameCompound <- lapply(
  dc,
  function(x) { gsub(";$", '', x[["NAME"]], perl = TRUE) }
);
# Decided it might be best not to go with pushing to lowercase.  The names can
# be inspected directly if required, but when searching for a name, the data
# can be shifted to lowercase.

# Bind to results
result <- NULL;
for (i in seq_along(nameCompound)) {
  result <- rbind(result, cbind(names(nameCompound)[i], nameCompound[[i]]));
};
result <- data.frame(result);
names(result) <- c("idKegg", "name");

# Write out
write.table(
  result,
  file = "./data/rfKeggidName.tsv",
  sep = "\t",
  eol = "\n",
  quote = FALSE,
  row.names = FALSE,
  na = ''
);
```
