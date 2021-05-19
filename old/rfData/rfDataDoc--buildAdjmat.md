# Rebuilding the KEGG Compound adjacency matrix
#### Mr. George L. Malone
#### 10<sup>th</sup> of December, 2020

### Contents
1.  Outline
2.  *R* script

## Outline

This document describes the process for rebuilding the overall KEGG Compound
adjacency matrix given the new TSV-based data format.  A slightly different
approach to the documentation will be taken this time -- instead of describing
the script then showing the whole thing, intermittent description and code will
be provided.

## *R* script

Firstly, the working directory is set.  This document assumes a directory
structure identical to that set out in the repository, with the exception of
the `data` directories, which can be created by the user (`mkdir`).  For the
purpose of the documentation, this is given as follows:

```r
setwd("/anpc_public/rfData/R/")
# Repository-^ Project-^   ^-Current directory
```

The user then needs to load in the data provided in the `data` directory for
`ruby` scripts, as splitting the equations was performed in Ruby.

```r
oppose <- read.delim(
  "../ruby/data/rfReacOppose.tsv",
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)
```

The total IDs now need to be extracted from the opposing compounds data.

```r
idTotal <- sort(unique(c(oppose[, 2], oppose[, 3])))
```

Previously, three IDs were missing -- C01355, C21335, and C21451.  These are
fructan, 1,2-beta-oligomannan, and polyethylene terephthalate.  This was due to
an oversight in the Ruby function for splitting equations, which selected
compound IDs based on a strict pattern, but some compounds are listed with
bracketed segments immediately following the ID, which were not accommodated.

An empty adjacency matrix now needs to be prepared.  The matrix is initialised
at zero, as there are currently no arcs between nodes. The matrix dimensions
should be of the same size as the number of compounds, and both the row lengths
and column lengths should be equal.  The dimensions are then named according to
the compound IDs.

```r
adjmat <- matrix(0, nrow = length(idTotal), ncol = length(idTotal))
dimnames(adjmat) <- list(idTotal, idTotal)
```

Then, the matrix needs to be populated.  An arc is drawn where one compound
opposes another, and the graph is neither directed nor weighted, so both
locations are given a value of 1.

```r
for (i in seq_len(nrow(oppose))) {
  adjmat[oppose[i, 2], oppose[i, 3]] <- 1
  adjmat[oppose[i, 3], oppose[i, 2]] <- 1
}
```

Ensure there are no nodes looping into themselves by setting the diagonal
entries of the matrix to zero.

```r
diag(adjmat) <- 0
```

Finally, save the adjacency matrix!  Calculation of the matrix takes about
10-11 seconds (though this will vary greatly between machines), which is not
trivial, and repeated calculation could be avoided by loading the object.

```r
save(adjmat, file = "./data/adjmat.RData")
```

It is not recommended to save this object to a TSV, as the resulting file is a
bit over 155 megabytes!  The compressed RData format has it at about 804
kilobytes.
