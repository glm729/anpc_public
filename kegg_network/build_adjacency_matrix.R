#' Given an adjacency list in matrix form, construct an adjacency matrix.
#' @param adjacency_list The matrix-form adjacency list.
#' @return Adjacency matrix of compounds present in the adjacency list.
build_adjacency_matrix <- function(adjacency_list) {
  compounds <- sort(unique(c(adjacency_list)))
  result <- matrix(
    0,
    nrow = length(compounds),
    ncol = length(compounds),
    dimnames = list(compounds, compounds)
  )
  for (i in seq_len(nrow(adjacency_list))) {
    result[adjacency_list[i, 1], adjacency_list[i, 2]] <- 1
  }
  ## No loops;
  diag(result) <- 0
  return(result)
}

