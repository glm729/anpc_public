# KEGG Compound:  Network representation
#### Mr. George L. Malone
#### 4<sup>th</sup> of January, 2021

## Overview

This directory contains the required code and data to run a Shiny application
(*R*) that will produce a network visualisation of certain significant
compounds.  The input data contains the compounds to be visualised, and the
output is a `visNetwork` graph of these compounds, with some basic numeric
summary data.

The application as presented here is the version as at the end of the working
year for 2020, specifically as at the 11<sup>th</sup> of December, 2020.  The
original purpose of the application was to provide network visualisation of
compounds significant in the *H. sapiens* metabolism under certain disease
statuses.

## Input

The required input for this application is a TSV of at least two columns.  The
columns can be specified by the user, so order is not strict.  The first input
column is the chemical name, and the second input column is the regulation
direction, either "increased" or "decreased".  Example data are shown below.
Note that the horizontal line is used to denote a header, and should not be
present in the TSV.  The user can specify whether a header is or is not present
in the input data.  The user can inspect the data prior to submission for
operations.

```
name         regulation
-----------------------
chem1         increased
chem2_34      decreased
anotherChem   decreased
chem12        increased
```

## Output

The output is provided in the second and third tabs in the sidebar, which are
labelled Data Summary and Network Visualisation, respectively.  The second tab
provides a basic numeric summary of the input data, and the third tab provides
the network visualisation, which uses the `visNetwork` package in *R* (which
essentially provides *R* bindings to the `vis.js` package).

## Operations

The operations performed by the server make use of a TSV that is a refactored
version of some data provided in KEGG Compound ([Kanehisa, M. and others,
1996-2021](https://www.genome.jp/kegg/)).  This TSV contains the KEGG Compound
ID and the associated names for each ID.  This is used to reduce the input data
to those present in KEGG Compound, and to reduce the adjacency matrix by
isomers.

The operations also make use of a large reference adjacency matrix.  This
matrix contains all links in KEGG Compound, as accessible via `KEGGREST` (via
BioConductor) in *R*.  This is stored in an `.RData` object rather than a TSV,
as the TSV is in excess of 34MB (if I recall correctly), whereas the `.RData`
object is about 800KB.

Five functions are provided for operations.  These are used to clean the
incoming chemical names, to find the cleaned chemical names within the KEGG
Compound data, to reduce the data to those present in KEGG Compound and
compress by isomers, to reduce the adjacency matrix to the chemical compounds
present and collapse isomer rows, and to generate the dataframes used in the
`visNetwork` function.

### Feature requests

Feel free to request new features!  I recommend opening a ticket in the
repository.

### Screenshot

Below is a screenshot of the main tab after uploading and submitting the
example data, as provided in the bundle.

![Example data uploaded and submitted.](screenshotDemo.png?raw=true "KEGG
Compound network application demo screenshot")
