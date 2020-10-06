## Set working directory and check for package requirements.
setwd("~/Documents/R/kegg_hsa_all_reactions/")  # Change to preferred directory.
if (!require("KEGGREST", quietly = TRUE)) { stop("KEGGREST is required.") }
source("./split_to_n.R")

## Begin ops.

## Get the enzyme list.
enzymelist <- sort(unique(KEGGREST::keggLink("enzyme", "hsa")))

## Get the enzyme details.
enzymedetails <- get_enzymedetails_from_enzymelist(enzymelist)

## Extract the reactions.
allreac <- get_allreac_from_enzymedetails(enzymedetails)

## End ops.