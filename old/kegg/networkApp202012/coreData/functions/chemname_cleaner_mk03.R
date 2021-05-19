#' Mk. III Chemical Name Cleaner
#' - Trim peripheral end brackets and asterisks
#' - Push to lower-case
#' - Unfold rows with multiple chemicals (e.g. slash, plus)
#' - Name becomes the first column
#' @param data Dataframe containing chemical names to clean
#' @return Cleaned, lower-case chemical names, with order preserved
chemname_cleaner_mk03 <- function(data, nameIndex = 1L) {
  # Initialise results object
  result <- NULL
  # Clean chemical names
  clean <- sapply(
    data[, nameIndex],
    function(name) {
      # Push to lower and substitute undesirable components
      tolower(gsub(
        # Target the ending bracketed part(s) and asterisks
        # Later work (using Ruby) shows that this can be greatly simplified...
        "(?<!^)((\\* | )((\\(|\\[).+(\\)|\\]))?\\*?|\\*)$",
        # Eliminate them
        '',
        name,
        # PCRE mate, what else?
        perl = TRUE
      ))
    }
  )
  # Split by slash and plus
  split <- strsplit(clean, "/|\\+", perl = TRUE)
  # Loop over the split
  for (i in seq_along(split)) {
    # Row-bind the chemicals, but preserve regulation direction
    colSelect <- seq_len(ncol(data))
    result <- rbind(
      result,
      cbind(
        # If length(split[[i]]) > 1, multiple rows are bound
        "name" = trimws(split[[i]]),
        # Bind the remaining non-name columns
        data[i, colSelect[which(colSelect != nameIndex)]],
        # Do not apply row names
        row.names = NULL
      )
    )
  }
  # Return;
  return(result)
}
