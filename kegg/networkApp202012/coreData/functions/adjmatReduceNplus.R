#' Improved function for reducing an adjacency matrix to present compounds,
#' with the option to include `n`-nearest neighours.
#' - A bit of testing puts it at ~0.023 seconds to reduce the full adjacency
#'   matrix (8810 compounds) to 207 compounds, with `n = 0`.
#' @param adjmat Adjacency matrix to reduce.
#' @param isomericReduction Output from the function `isomericReduction`, i.e.
#' the three-column dataframe with names, anchor IDs, and peripheral IDs.
#' @param n Number of neighbours.  Defaults to 0.
#' @return Reduced adjacency matrix, with `n`-nearest neighbours.  If `n == 0`,
#' the reduced adjacency matrix with relevant IDs only is returned.
adjmatReduceNplus <- function(adjmat, isomericReduction, n = 0) {
  # Shorthand dimension names, and check square
  dn1 <- dimnames(adjmat)[[1]]
  if (!(all(dn1 == dimnames(adjmat)[[2]]))) {
    stop("dimnames(adjmat) are not all exactly equal")
  }
  # Get the IDs to reduce by
  idReduce <- sort(unique(c(isomericReduction[, 2], isomericReduction[, 3])))
  # Get the IDs that occur in the adjacency matrix
  target <- dn1[which(dn1 %in% idReduce)]
  # If any neighbours
  if (n > 0) {
    # Loop over n
    for (i in seq_len(n)) {
      # Include neighbouring compounds in the target IDs
      target <- sort(unique(c(
        target,
        sort(unique(unlist(sapply(
          target,
          function(x) { dn1[which(adjmat[x, ] != 0)] }
        ))))
      )))
    }
  }
  # Reduce the adjacency matrix to the overall target
  adjmatSub <- adjmat[target, target]
  # Get the rows to reduce by isomer
  isomer <- isomericReduction[which(!(is.na(isomericReduction[, 3]))), ]
  # Specify target/anchor isomers
  isomerTarget <- isomer[, 2]
  # Get the data to use in reduction operations
  reductionData <- lapply(
    isomerTarget,
    function(x) {
      # Peripheral IDs
      isomerPeri <- isomer[which(isomer[, 2] == x), 3]
      # Contents of the new row (and column)
      newRow <- apply(adjmatSub[c(x, isomerPeri), ], 2, max)
      return(list("isomerPeri" = isomerPeri, "newRow" = newRow))
    }
  )
  # Loop over the reduction data
  for (i in seq_along(reductionData)) {
    # Assign the new value for each relevant row and column
    adjmatSub[isomerTarget[i], ] <- reductionData[[i]][["newRow"]]
    adjmatSub[, isomerTarget[i]] <- reductionData[[i]][["newRow"]]
  }
  # Shorthand dimension names of the subset adjacency matrix
  dn1s <- dimnames(adjmatSub)[[1]]
  dn2s <- dimnames(adjmatSub)[[2]]
  # Get the vector of peripheral IDs
  peri <- sort(unique(unlist(
    sapply(reductionData, function(x) { x[["isomerPeri"]] })
  )))
  # Reduce the matrix to the present compounds, and eliminate loops
  dn1smp <- which(!(dn1s %in% peri))
  dn2smp <- which(!(dn2s %in% peri))
  result <- adjmatSub[dn1s[dn1smp], dn2s[dn2smp]]
  diag(result) <- 0
  # Return
  return(result)
}
