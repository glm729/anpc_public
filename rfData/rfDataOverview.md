# Literature Search and KEGG Compound:  Reformatting Data
#### Mr. George L. Malone
#### 8<sup>th</sup> of December, 2020

### Contents
1.  Purpose
2.  Overview
3.  Notebook 1
4.  Notebook 2

## Purpose

The purpose of the scripts documented here is to reformat the data contained in
KEGG Compound, for the purpose of faster querying of KEGG Compound data
relevant to chemical names identified in a literature search.


## Overview

The critical outcomes of these operations are the restructuring or reformatting
of KEGG Compound data, as retrieved from the KEGG REST API via the `KEGGREST`
package (via BioConductor) in *R*.  The input in most cases is and RData object
containing data for 8810 compounds, as provided in KEGG Compound via
`KEGGREST`, but other operations to reformat or query the KEGG Compound data
with specific regard to the literature data will also make direct use of the
recorded data from literature.


## Notebook 1:  Restructuring literature data

This notebook describes the scripts used to reformat the spreadsheet containing
the information entered given a literature search.  The main purpose of
reformatting these data is to reduce the information to a certain set of
variables, such as name, regulation direction, and DOI in which the data are
found.


## Notebook 2:  Restructuring KEGG Compound data

This notebook provides scripts for reformatting KEGG Compound data, typically
for "unfolding" the data into a spreadsheet format.  This is for the purpose of
potential database-style querying (i.e. SQL), but may include list-type or
JSON-style data.
