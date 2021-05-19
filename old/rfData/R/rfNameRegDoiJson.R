# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Source required functions
source("./functions/chemname_cleaner_mk03.R")

# Read in the data
data <- read.delim(
  "./data/litInfo.tsv",
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Clean the names
dataClean <- chemname_cleaner_mk03(data, nameIndex = 1L)

# Get the unique names
nameUniq <- sort(unique(dataClean[, 1]))

# Get the raw regulation and DOI data
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
    if (nrInc == 0) doiInc <- NA else doiInc <- dconInc[, 2]
    if (nrDec == 0) doiDec <- NA else doiDec <- dconDec[, 2]
    return(list(nrInc, nrDec, doiInc, doiDec))
  }
)

# Produce a dataframe
result <- NULL
for (i in seq_along(nameRegSum)) {
  result <- rbind(
    result,
    cbind(
      "name" = nameUniq[i],
      "up" = nameRegSum[[i]][[1]],
      "down" = nameRegSum[[i]][[2]],
      "doiUp" = paste0(nameRegSum[[i]][[3]], collapse = ","),
      "doiDown" = paste0(nameRegSum[[i]][[4]], collapse = ",")
    )
  )
}

# Clean NAs
result[which(result[, 4] == "NA"), 4] <- NA
result[which(result[, 5] == "NA"), 5] <- NA

# Write out
write.table(
  result,
  file = "./data/nameRegDoiJson.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)
