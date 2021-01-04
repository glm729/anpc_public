#' Function for extracting the required `visNetwork` info from a handful of
#' objects involved in data processing.
#' @param dataClean Cleaned input data, via `chemname_cleaner_mk03`.
#' @param withId Literature entries found to feature IDs in KEGG Compound
#' (based on name).  Output is from `isomericReduction`.
#' @param adjmatReduced Adjacency matrix reduced by `adjmatReduceNplus`.
#' @return Two-component list, featuring the `nodes` and `edges` dataframes for
#' use in the `visNetwork::visNetwork` function.
visNetworkInfo <- function(dataClean, withId, adjmatReduced) {
  # Shorthand notation
  dnar1 <- dimnames(adjmatReduced)[[1]]
  # Get the main visNetwork info object
  vni <- lapply(
    # Over the indices of the dimnames
    seq_along(dnar1),
    function(i) {
      # Get the relevant names
      nodeLabel <- unique(withId[which(withId[, 2] == dnar1[i]), 1])
      # If there's more than one name, get the first alphanumerically
      if (length(nodeLabel) > 1 ) {
        nodeLabel <- sort(nodeLabel)[1]
      }
      # Count number of times reported
      dcnl <- dataClean[which(dataClean[, 1] == nodeLabel), ]
      if (is.null(ncol(dcnl))) { dcnl <- rbind(dcnl) }
      timesReported <- nrow(dcnl)
      # Get raw regulation data
      regulation <- dataClean[which(dataClean[, 1] == nodeLabel), 2]
      # Switch by regulation to get regulation colour
      if (all(regulation == "decreased")) {
        regCol <- "red"
      } else if (all(regulation == "increased")) {
        regCol <- "green"
      } else {
        regCol <- "orange"
      }
      # Get raw arc data
      arc <- dnar1[which(adjmatReduced[dnar1[i], ] != 0)]
      # Reduce to names not yet considered (avoid doubling up)
      arc <- arc[which(!(arc %in% dnar1[1:i]))]
      # If no arcs, return NULL, else bind the arcs
      if (length(arc) == 0) {
        edges <- NULL
      } else {
        edges <- cbind(dnar1[i], arc)
      }
      # Return the nodes and edges information
      return(list(
        "nodes" = cbind(nodeLabel, timesReported, regCol),
        "edges" = edges
      ))
    }
  )
  # Initialise nodes and edges dataframes
  nodeDf <- NULL
  edgeDf <- NULL
  for (v in vni) {
    nodeDf <- rbind(nodeDf, v[["nodes"]])
    if (!(is.null(v[["edges"]]))) { edgeDf <- rbind(edgeDf, v[["edges"]]) }
  }
  nodes <- data.frame(
    id = dnar1,
    label = nodeDf[, 1],
    size = (rank(nodeDf[, 2], ties.method = "max") / 10),
    color = nodeDf[, 3]
  )
  edges <- data.frame(
    from = edgeDf[, 1],
    to = edgeDf[, 2]
  )
  return(list("nodes" = nodes, "edges" = edges))
}
