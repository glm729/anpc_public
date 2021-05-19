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
