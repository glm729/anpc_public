#' Given a vector, split this into a list of entries of group size n.
#' @param obj Vector to split.
#' @param n Size to split vector by.
#' @return List containing elements of `obj`, in groups of `n`.
split_to_n <- function(obj, n) {
    ## Initialise list index and marker;
    k <- 1
    marker <- 0
    ## Prepare the empty list;
    split <- vector(mode = 'list', length = ceiling(length(obj) / n))
    ## Loop over the object;
    for (i in seq_along(obj)) {
        ## Add to the list;
        split[[k]] <- append(split[[k]], obj[i])
        ## Iterate marker;
        marker <- marker + 1
        ## If marker at n, iterate k and reset marker;
        if (marker == n) {
            k <- k + 1
            marker <- 0
        }
    }
    ## Return the list;
    return(split)
}
