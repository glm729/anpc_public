#' Given a character vector of KEGG reaction IDs, extract the data.
#' @param reaction_ids Character vector of KEGG reaction IDs.
#' @return List of KEGG reaction data.
get_reactions <- function(reaction_ids) {
  source("./split_to_n.R")  # Required.
  reaction_ids_grouped <- split_to_n(reaction_ids, 10)
  return(unlist(
    lapply(reaction_ids_grouped, function(reaction_group) {
      KEGGREST::keggGet(reaction_group)
    }),
    recursive = FALSE
  ))
}

