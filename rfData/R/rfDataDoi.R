# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Source required functions
source("./functions/chemname_cleaner_mk03.R")

# Read in the data
urlText <- readLines("./data/litInfoLink.txt")
data <- read.delim(url(urlText), sep = "\t", header = TRUE)

# Clean up the names
dataClean <- chemname_cleaner_mk03(data, nameIndex = 1L)

# Collect by DOI
# Compound per DOI
doiUniq <- sort(unique(dataClean[, 8]))
doiCompound <- lapply(
  doiUniq,
  function(x) dataClean[which(dataClean[, 8] == x), 1]
)
names(doiCompound) <- doiUniq

# DOI per compound
nameUniq <- sort(unique(dataClean[, 1]))
compoundDoi <- lapply(
  nameUniq,
  function(x) dataClean[which(dataClean[, 1] == x), 8]
)
names(compoundDoi) <- nameUniq

# Function version -- could be of use
eachOfFor <- function(data, eachOf, eachFor) {
  uniq <- sort(unique(data[, eachOf]))
  result <- lapply(uniq, function(x) data[which(data[, eachOf] == x), eachFor])
  names(result) <- uniq
  return(result)
}

# Open out the data
framesCd <- sapply(
  seq_along(compoundDoi),
  function(i) {
    cbind(
      rep(names(compoundDoi)[i], length(compoundDoi[[i]])),
      compoundDoi[[i]]
    )
  }
)
resultCd <- NULL
for (i in seq_along(framesCd)) resultCd <- rbind(resultCd, framesCd[[i]])
resultCd <- data.frame("name" = resultCd[, 1], "doi" = resultCd[, 2])

framesDc <- sapply(
  seq_along(doiCompound),
  function(i) {
    cbind(
      rep(names(doiCompound)[i], length(doiCompound[[i]])),
      doiCompound[[i]]
    )
  }
)
resultDc <- NULL
for (i in seq_along(framesDc)) resultDc <- rbind(resultDc, framesDc[[i]])
resultDc <- data.frame("doi" = resultDc[, 1], "name" = resultDc[, 2])

# Whether compound by doi or doi by compound, the unfolded result will be the
# same, but in a different order.

# That is, the relevant rows will still be there, but the columns will be at
# different indices, and the rows will be in a different order.

# i.e. resultDc has doi at column index 1, and rows are sorted by doi;
# resultCd has name at column index 1, and rows are sorted by chemical name

# So in both cases, the dataframe is ordered by column 1, but column 1 depends
# on the method. The resulting dataframe contains the same data, ultimately.

# Write out
write.table(
  resultCd,
  file = "./data/doiByCompound.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)

# And finish with some measurements
numCompoundDoi <- sapply(
  unique(resultCd[, 2]),
  function(x) length(resultCd[which(resultCd[, 2] == x), 1])
)

summary(numCompoundDoi)
# One paper reports 1212 compounds, but possible repeats (due to groups).
# This is probably <MASKED>

numDoiCompound <- sapply(
  unique(resultCd[, 1]),
  function(x) length(resultCd[which(resultCd[, 1] == x), 2])
)

summary(numDoiCompound)
# At least one compound is reported 30 times, but most are sitting at around
# 1-3 times, so it's quite skewed.

# All of this is also prior to culling names that are not metabolites, and
# prior to checking for / reducing by names in KEGG.
