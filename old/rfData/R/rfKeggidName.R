# Set working directory
setwd("/anpc_public/rfData/R/");  # Set this as required.

# Load in the required data
load("./data/dc.RData");

# Get the names for each compound
nameCompound <- lapply(
  dc,
  function(x) { gsub(";$", '', x[["NAME"]], perl = TRUE) }
);

# Bind to results
result <- NULL;
for (i in seq_along(nameCompound)) {
  result <- rbind(result, cbind(names(nameCompound)[i], nameCompound[[i]]));
};
result <- data.frame(result);
names(result) <- c("idKegg", "name");

# Write out
write.table(
  result,
  file = "./data/rfKeggidName.tsv",
  sep = "\t",
  eol = "\n",
  quote = FALSE,
  row.names = FALSE,
  na = ''
);
