#!/usr/bin/env R
# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Read in the data
oppose <- read.delim(
  "../ruby/data/rfReacOppose.tsv",
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Get the matrix dimensions
idTotal <- sort(unique(c(oppose[, 2], oppose[, 3])))

# Prepare the empty matrix
adjmat <- matrix(0, ncol = length(idTotal), nrow = length(idTotal))
dimnames(adjmat) <- list(idTotal, idTotal)

# Loop over the opposing data
for (i in seq_len(nrow(oppose))) {
  adjmat[oppose[i, 2], oppose[i, 3]] <- 1
  adjmat[oppose[i, 3], oppose[i, 2]] <- 1
}

# Ensure nodes do not loop to self
diag(adjmat) <- 0

# Save to an RData object
save(adjmat, file = "./data/adjmat.RData")

# Not writing to a file, as the resulting TSV is 155.3MB....
# The resulting RData object is about 803.5KB.
# Otherwise, takes about 10.8s, but only needs to be run once (theoretically).
