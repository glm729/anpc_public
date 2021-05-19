# Reformatting chemical regulation information by DOI
#### Mr. George L. Malone
#### 8<sup>th</sup> of December, 2020

### Contents
1.  Outline
2.  JSON-style output
3.  SQL-style output

## Outline

The purpose of these scripts is to reformat the chemical data based on reported
regulation direction, but maintaining data regarding the DOIs associated with
each report.  Two formats are produced -- "JSON-style" output, which features
one row per chemical name but provides the up- and down-regulation in a list
collapsed by comma, and "SQL-style" output, which provides one row per
regulation report.

JSON-type output features three columns -- chemical name, DOIs listing
upregulation, and DOIs listing downregulation.

SQL-type output also features three columns, but with different data --
chemical name, regulation direction, and reporting DOI.

## JSON-style output

The *R* script below reformats the literature spreadsheet into the JSON-type
regulation information.  In some cases, this can be quite wide, as at least one
chemical compound is reported 30 times!  Some others are reported around 26
times!

```r
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
```

## SQL-style output

The *R* script below reformats the literature spreadsheet into the SQL-type
regulation information.  As with the width of the JSON data, this one can be
quite long, but is generally a bit cleaner to look at.

```r
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
    if (nrInc == 0) {doiInc <- NA} else {doiInc <- dconInc[, 2]}
    if (nrDec == 0) {doiDec <- NA} else {doiDec <- dconDec[, 2]}
    return(list(nrInc, nrDec, doiInc, doiDec))
  }
)

# Produce a dataframe
result <- NULL
for (i in seq_along(nameRegSum)) {
  nrs <- nameRegSum[[i]]
  # If it's reported upregulated, bind each report
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
  # If it's reported downregulated, bind each report
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
  file = "./data/nameRegDoiSql.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)
```

The resulting table will always report upregulated DOIs first (if any), then
downregulated DOIs.
