#' Given a list of opposing compounds, construct an adjacency list.
#' @param oppose List of opposing compounds.
#' @return Adjacency list in matrix form.
get_adjacent <- function(oppose) {
  base <- lapply(oppose, function(x) {
    ret <- matrix(ncol = 2)
    ## Couldn't think of a better way to do this one;
    for (i in x$lhs) {
      for (j in x$rhs) {
        ret <- rbind(ret, c(i, j))
      }
    }
    return(matrix(ret[which(!is.na(ret))], ncol = 2))
  })
  over <- matrix(ncol = 2)
  for (mat in base) { over <- rbind(over, mat) }
  return(matrix(over[which(!is.na(over))], ncol = 2))
}

