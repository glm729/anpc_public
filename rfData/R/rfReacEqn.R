# Set working directory
setwd("/anpc_public/rfData/R/")  # Set this as required.

# Load in the data
load("./data/dr.RData")
# ^ This relies upon a data object containing details of 11208 reactions, as
# listed in the KEGG Reaction database, retrieved via KEGGREST.
# `dr` is shorthand for `dataReaction`.

# Get the equations
eqn <- lapply(
  seq_along(dr),
  function(i) {
    e <- dr[[i]][["EQUATION"]]
    if (is.null(e)) return(cbind(names(dr)[i], NA))
    return(cbind(names(dr)[i], e))
  }
)

# Unfold and explicitly convert to dataframe
result <- NULL
for (x in eqn) result <- rbind(result, x)
result <- data.frame(result)
names(result) <- c("idReaction", "equation")

# Write out
write.table(
  result,
  file = "./data/rfReacEqn.tsv",
  sep = "\t",
  eol = "\n",
  row.names = FALSE,
  na = ''
)
