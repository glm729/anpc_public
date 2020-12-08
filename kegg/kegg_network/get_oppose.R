#' Given a list of reactions data, extract a list of opposing compounds.
#' @param reactions List of reactions data.
#' @return List of opposing compounds.
get_oppose <- function(reactions) {
  ## Pull out and split the equations;
  eqns <- strsplit(
    as.character(lapply(reactions, function(x) { x$EQUATION })),
    '>'
  )
  ## Return the neatened split;
  return(lapply(eqns, function(x) {
    lhs <- strsplit(x[[1]], ' ')[[1]]
    rhs <- strsplit(x[[2]], ' ')[[1]]
    return(list(
      'lhs' = lhs[which(grepl('^C', lhs, perl = TRUE))],
      'rhs' = rhs[which(grepl('^C', rhs, perl = TRUE))]
    ))
  }))
}

