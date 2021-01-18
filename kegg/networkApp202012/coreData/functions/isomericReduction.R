#' Function for reducing the matched-ID dataframe (from `nameInKegg`) by
#' presence of chiral isomers.
#' @param idMatch Object returned by `nameInKegg`, containing which names in
#' the literature match in KEGG Compound (if any).
#' @return Dataframe of three columns -- name, "anchor" KEGG Compound ID, and
#' "other" KEGG Compound IDs (i.e. rows in the adjacency matrix to be absorbed
#' into the anchor ID row).
isomericReduction <- function(idMatch) {
  # Ignore NA entries
  found <- idMatch[which(!(is.na(idMatch[, 2]))), ]
  # Clean the suffix
  found[, 1] <- gsub("(ate|ic acid)$", "ate", found[, 1], perl = TRUE)
  # Reduce to the unique names found
  foundNameUniq <- unique(found[, 1])
  # Collect total ID data
  idTotal <- lapply(
    foundNameUniq,
    function(x) {
      # Initialise anchor ID and other IDs
      idA <- NULL
      idO <- NULL
      # Subset the data to the current name
      sub <- rbind(found[which(found[, 1] == x), ])
      # Adjust term for regex matching
      xm <- gsub("(ate|ic acid)$", "(ate|ic acid)", x, perl = TRUE)
      # Get which are exact matches, l- matches, and d- matches
      matchE <- which(grepl(paste0("^", xm, "$"), sub[, 3], perl = TRUE))
      matchL <- which(grepl(paste0("^l-", xm, "$"), sub[, 3], perl = TRUE))
      matchD <- which(grepl(paste0("^d-", xm, "$"), sub[, 3], perl = TRUE))
      # If at least one exact match
      if (length(matchE) > 0) {
        # Get the unique IDs
        su <- sort(unique(sub[matchE, 2]))
        # If more than one unique ID, pick the lowest numerically as anchor
        if (length(su) > 1) {
          idA <- su[1]
          idO <- c(idO, su[2:length(su)])
        } else {
          idA <- su
        }
      }
      # If at least one l- prefix match
      if (length(matchL) > 0) {
        su <- sort(unique(sub[matchL, 2]))
        # If there isn't already an anchor, assign the l- prefix ID as anchor
        if (is.null(idA)) {
          if (length(su) > 1) {
            idA <- su[1]
            idO <- c(idO, su[2:length(su)])
          } else {
            idA <- su
          }
        } else {
          idO <- c(idO, su)
        }
      }
      # If at least one d- prefix match
      if (length(matchD) > 0) {
        su <- sort(unique(sub[matchD, 2]))
        # If there still isn't an anchor, assign d- prefix ID as anchor
        if (is.null(idA)) {
          if (length(su) > 1) {
            idA <- su[1]
            idO <- c(idO, su[2:length(su)])
          } else {
            idA <- su
          }
        } else {
          idO <- c(idO, su)
        }
      }
      # Eliminate IDs in other which are identical to the anchor
      idO <- idO[which(idO != idA)]
      # If no other IDs, then NULL
      if (length(idO) == 0) { idO <- NULL }
      return(list("idA" = idA, "idO" = idO))
    }
  )
  # Attribute the list items by name
  names(idTotal) <- foundNameUniq
  # Prepare the unfolded data
  unfold <- lapply(
    seq_along(idTotal),
    function(i) {
      if (is.null(idTotal[[i]][[1]])) {
        idA <- NA
      } else {
        idA <- idTotal[[i]][[1]]
      }
      if (is.null(idTotal[[i]][[2]])) {
        idO <- NA
      } else {
        idO <- idTotal[[i]][[2]]
      }
      return(cbind(names(idTotal)[i], idA, idO))
    }
  )
  # Bind the unfolded data to the results object
  result <- NULL
  for (u in unfold) { result <- rbind(result, u) }
  # Explicitly convert to dataframe, and supply names
  result <- data.frame(result)
  names(result) <- c("name", "idKegg", "idOther")
  return(result)
}
