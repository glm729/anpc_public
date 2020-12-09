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
names(ebcResult) <- c("idKegg", "idEnzyme");

# Write out
write.table(
  ebcResult,
  file = "./data/rfEnzymeKeggid.tsv",
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
names(cbeResult) <- c("idEnzyme", "idKegg");

# Write out
write.table(
  cbeResult,
  file = "./data/rfKeggidEnzyme.tsv",
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
