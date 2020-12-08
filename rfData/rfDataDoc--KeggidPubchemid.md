# Get PubChem ID for each associated KEGG ID
#### Mr. George L. Malone
#### 8<sup>th</sup> of December, 2020

### Contents
1.  Outline
2.  *R* script

## Outline

The script documented here will return a table of PubChem IDs for each
associated KEGG ID, in long format.  That is, each row contains a paired KEGG
ID and PubChem ID.  The required input is the RData object containing data
collected from KEGG Compound, via the `KEGGREST` package.  The script also
writes the resulting object to a TSV file.

This should allow for quick querying of PubChem IDs for the relevant KEGG
Compound IDs.  KEGG does not contain information regarding SMILES codes, but
PubChem does -- the IDs listed in the output could be used to query SMILES
codes for the compounds, to permit a somewhat more stable method of unique
identification.

## *R* script

The following script performs the operations outlined above.  For 8810
compounds, the resulting table features 8810 rows, suggesting that no compound
in KEGG features more than one PubChem ID.

```r
# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Load required data
load("./data/dc.RData")
# ^ Requires this.  This contains data for 8810 compounds in KEGG Compound, via
# the KEGGREST package.

# Get the PubChem IDs
pattern <- "^PubChem: "
pcid <- lapply(
  dc,
  function(x) {
    db <- x[["DBLINKS"]]
    # If no dblinks, return NA
    if (is.null(db)) return(NA)
    # Otherwise, find which
    wh <- which(grepl(pattern, db, perl = TRUE))
    # If no PubChem ID, return NA
    if (length(wh) == 0) return(NA)
    # Otherwise, return the PubChem ID without the prefix
    return(gsub(pattern, '', db[wh], perl = TRUE))
  }
)

# Unfold the data
unfold <- lapply(
  seq_along(pcid),
  function(i) {
    # If no ID, return the name and NA
    if (is.na(pcid[[i]])) return(cbind(names(pcid)[i], NA))
    # Else return the name and its corresponding ID(s)
    return(cbind(rep(names(pcid)[i], length(pcid[[i]])), pcid[[i]]))
  }
)

# Assign to a table
result <- NULL
for (i in seq_along(unfold)) result <- rbind(result, unfold[[i]])
result <- data.frame("idKegg" = result[, 1], "idPubchem" = result[, 2])

# Write out
write.table(
  result,
  file = "./data/rfDataKeggPubchem.tsv",
  sep = "\t",
  eol = "\n",
  quote = FALSE,
  row.names = FALSE,
  na = ''
)
```

The resulting output appears as shown below:

```
idKegg  idPubchem
C00001  3303
C00002  3304
C00003  3305
C00004  3306
C00005  3307
C00006  3308
...     ...
```
