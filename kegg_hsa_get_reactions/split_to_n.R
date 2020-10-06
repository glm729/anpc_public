## Copyright (c) 2020. Mr. George L. Malone.
## All rights reserved.
#' Given a vector, split this into a list of entries of group size n.
#' @param obj Vector to split.
#' @param n Size to split vector by.
#' @return List containing elements of `obj`, in groups of `n`.
split_to_n <- function(obj, n) {
  ## Initialise list index;
  k <- 1
  ## Open the cage;
  canary <- 0
  ## Prepare the empty list;
  split <- vector(mode = 'list', length = ceiling(length(obj) / n))
  for (i in seq_along(obj)) {
    ## Add to the list;
    split[[k]] <- append(split[[k]], obj[i])
    ## Catch the bird;
    canary <- canary + 1
    ## If too many birds, move to the next cage;
    if (canary == n) {
      k <- k + 1
      canary <- 0
    }
  }
  ## Aviary;
  return(split)
}