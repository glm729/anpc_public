#' Given a list of enzymes, extract all reactions.
#' @param enzymedetails List of enzyme details. Each element is an enzyme.
#' @return Sorted, unique character vector of KEGG reaction IDs found.
get_allreac_from_enzymedetails <- function(enzymedetails) {
  allreac_raw <- unlist(lapply(enzymedetails, function(x) { x$ALL_REAC }))
  allreac_spl <- unlist(strsplit(allreac_raw, " "))
  clean <- sapply(
    allreac_spl,
    function(x) { gsub("[^R0-9]", '', x, perl = TRUE) }
  )
  return(sort(unique(clean[which(clean != '')])))
}
