#' Given a list of KEGG Enzyme IDs, extract the enzyme details.
#' @param enzymelist Character vector of enzyme IDs.
#' @return List containing all unique enzyme data from the enzyme ID list.
get_enzymedetails_from_enzymelist <- function(enzymelist) {
  source("./split_to_n.R")  # Requires this.
  enzymelist_spl <- split_to_n(sort(unique(enzymelist)), 10L)
  return(unlist(
    lapply(enzymelist_spl, function(x) { KEGGREST::keggGet(x) }),
    recursive = FALSE
  ))
}