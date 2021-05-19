# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Source required functions
source("./functions/chemname_cleaner_mk03.R")

# Load in the data
data <- read.delim(
  "./data/litInfo.tsv",
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Clean up the names
dataClean <- chemname_cleaner_mk03(data, nameIndex = 1L)

# Get the unique names
nameUniq <- sort(unique(dataClean[, 1]))

# Get the raw regulation data
nameRegRaw <- lapply(
  nameUniq,
  function(x) dataClean[which(dataClean[, 1] == x), c(2, 8)]
)

# Get the up/down reg. sums
nameRegSum <- lapply(
  nameRegRaw,
  function(x) {
    dconInc <- x[which(x[, 1] == "increased"), ]
    dconDec <- x[which(x[, 1] == "decreased"), ]
    nrInc <- nrow(dconInc)
    nrDec <- nrow(dconDec)
    if (nrInc == 0) {doiInc <- NA} else {doiInc <- dconInc[, 2]}
    if (nrDec == 0) {doiDec <- NA} else {doiDec <- dconDec[, 2]}
    return(list(nrInc, nrDec, doiInc, doiDec))
  }
)

# Produce a dataframe
result <- NULL
for (i in seq_along(nameRegSum)) {
  nrs <- nameRegSum[[i]]
  if (nrs[[1]] > 0) {
    result <- rbind(
      result,
      cbind(
        "name" = rep(nameUniq[i], length(nrs[[3]])),
        "regulation" = rep("up", length(nrs[[3]])),
        "doi" = nrs[[3]]
      )
    )
  }
  if (nrs[[2]] > 0) {
    result <- rbind(
      result,
      cbind(
        "name" = rep(nameUniq[i], length(nrs[[4]])),
        "regulation" = rep("down", length(nrs[[4]])),
        "doi" = nrs[[4]]
      )
    )
  }
}

# No need to clean NA entries, as none are appended to the results.

# Write out
write.table(
  result,
  file = "./data/nameRegDoi_SQL.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)
