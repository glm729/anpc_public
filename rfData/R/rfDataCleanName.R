# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Source required functions
source("./functions/chemname_cleaner_mk03.R")

# Read in the spreadsheet
# via remote source
urlText <- readLines("./data/litInfoLink.txt")
data <- read.delim(url(urlText), sep = "\t", header = TRUE)

# or via local
data <- read.delim("./data/litInfo.tsv", sep = "\t", header = TRUE)

# Clean up the chemical names
dataClean <- chemname_cleaner_mk03(data, nameIndex = 1L)

# Write out
write.table(
  dataClean,
  file = "./data/litInfoClean.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)
