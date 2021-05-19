# Getting KEGG Compound ID by KEGG Enzyme ID, and vice versa
#### Mr. George L. Malone
#### 9<sup>th</sup> of December, 2020

### Contents
1.  Outline
2.  *R* script

## Outline

The purpose of this script is to reformat the KEGG Compound data such that the
compounds can be grouped by enzyme.  This is to permit colouring by enzyme in a
graph visualisation.

Most compounds in KEGG are associated with at least one enzyme.  Of the 8810 in
the KEGG Compound RData object used, 673 do not feature an associated enzyme.
The median number of enzymes per compound is 1, the mean is 3.89, and the
maximum is 2091.  The dataframe returned features 34955 rows, and is 566KB on
disk.

Due to the nature of collecting enzyme IDs, every enzyme will be linked to at
least one compound.  Indeed, the minimum number of compounds per enzyme is 1.
The median is 5, the mean is 6.02, and the maximum is 283 compounds per enzyme.
The dataframe returned contains 34282 rows, and is 560KB on disk.

## *R* script

Below is the *R* script used to generate the TSVs of enzymes by compound and
compounds by enzyme, including the summary measurements given above.

```r
#!/usr/bin/env R

# Yes, I'm experimenting a bit with convention, hence the semi-colons.

# Set working directory
setwd("/anpc_public/rfData/R/");  # Set this as required.

# Load required data
load("./data/dc.RData");

# Get enzymes by compound
enzymeByCompound <- lapply(dc, function(x) { x[["ENZYME"]] });

# Structure enzymes by compound
ebcStructure <- lapply(
  seq_along(enzymeByCompound),
  function(i) {
    ebc <- enzymeByCompound[[i]];
    if (is.null(ebc)) { return(c(names(enzymeByCompound)[i], NA)) };
    return(cbind(names(enzymeByCompound)[i], ebc));
  }
);

# Bind to the results
ebcResult <- NULL;
for (x in ebcStructure) { ebcResult <- rbind(ebcResult, x) };
ebcResult <- data.frame(ebcResult);
names(ebcResult) <- c("idKegg", "enzyme");

# Write out
write.table(
  ebcResult,
  file = "./data/rfKeggidEnzyme.tsv",
  sep = "\t",
  eol = "\n",
  quote = FALSE,
  row.names = FALSE,
  na = ''
);

# Other side of the coin -- compounds by enzyme
enzymeList <- sort(unique(unlist(enzymeByCompound)));

# Structure compounds by enzyme
cbeStructure <- lapply(
  enzymeList,
  function(x) { rbind(cbind(x, ebcResult[which(ebcResult[, 2] == x), 1])) }
);

# Bind to the results
cbeResult <- NULL;
for (x in cbeStructure) { cbeResult <- rbind(cbeResult, x) };
cbeResult <- data.frame(cbeResult);
names(cbeResult) <- c("enzyme", "idKegg");

# Write out
write.table(
  cbeResult,
  file = "./data/rfEnzymeKeggid.tsv",
  sep = "\t",
  eol = "\n",
  quote = FALSE,
  row.names = FALSE,
  na = ''
);

# Some measurements
# Enzymes per compound
ebcLen <- sapply(
  unique(ebcResult[, 1]),
  function(x) {
    enz <- ebcResult[which(ebcResult[, 1] == x), 2];
    if (all(is.na(enz))) { return(0) };
    return(length(enz));
  }
);

summary(ebcLen);
# >  Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
# > 0.000    1.000    1.000    3.891    2.000 2091.000

# Compounds per enzyme
# No need to check NA values, due to the nature of collecting the enzyme IDs.
cbeLen <- sapply(
  unique(cbeResult[, 1]),
  function(x) { length(cbeResult[which(cbeResult[, 1] == x), 2]) }
);

summary(cbeLen);
# >  Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# > 1.000   4.000   5.000   6.016   6.000 283.000
```
