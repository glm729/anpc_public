#' Function for finding which names in the literature match those in the KEGG
#' Compound names.  Includes checking for suffix `-ate` and `-ic acid`, and
#' prefix `l-` and `d-`.
#' - Found a way to speed it up!  Pushing KN to lowercase inside the lapply was
#'   causing major slowdown, so KN is pushed to lowercase outside (as it needs
#'   to be used as lowercase anyway).
#' - This change took calculation time from 7.10s to 0.96s!
#' @param nameUniq Vector of unique names found in the literature.
#' @param rfKeggidName Dataframe of names associated with each KEGG Compound
#' ID, as produced by the script `rfKeggidName`.
#' @return Three-column dataframe of names, KEGG Compound ID, and term in KEGG
#' Compound names found to match the name in column 1.
nameInKegg <- function(nameUniq, rfKeggidName) {
  # Shorthand KEGG IDs and KEGG names
  KI <- rfKeggidName[, 1]
  KN <- tolower(rfKeggidName[, 2])
  # Get strings to check against
  nGsub <- gsub("(ate|ic acid)$", "(ate|ic acid)", nameUniq, perl = TRUE)
  nPaste <- sapply(nGsub, function(x) { paste0("^([dl]-)?", x, "$") })
  # Get the list of matching ID results
  listIdMatch <- lapply(
    seq_along(nameUniq),
    function(i) {
      # Find which match
      g <- grepl(nPaste[i], KN, perl = TRUE)
      # If there are any matches, return them
      if (any(g)) { return(cbind(nameUniq[i], KI[g], KN[g])) }
      # Otherwise, return NAs
      return(cbind(nameUniq[i], NA, NA))
    }
  )
  # Bind matching ID results to a table
  idMatch <- NULL
  for (m in listIdMatch) { idMatch <- rbind(idMatch, m) }
  # Convert to dataframe, provide names, and return
  idMatch <- data.frame(idMatch)
  names(idMatch) <- c("name", "idKegg", "nameMatch")
  return(idMatch)
}
