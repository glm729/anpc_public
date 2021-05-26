# Reformat PathBank data
#### Mr. George L. Malone
#### 26<sup>th</sup> of May, 2021


## Overview

This directory provides the scripts used to reformat and extract information
from data provided at the [PathBank Downloads page][1].  The data are being
handled for the purpose of more firmly defining the reference dataset to use
for producing [force-directed graph visualisations][2] of metabolite data.


## Metabolite data

The main dataset used for extracting metabolite data is the _All Metabolites_
dataset, a large CSV containing relatively basic information of which
metabolites are referenced within the pathways in the database.  This file is
converted into a JSON, but also collapses pathways data.

The CSV will repeat metabolite information for entries where the metabolite is
present in multiple different pathways (and conversely, pathway data are
repeated for each different metabolite).  The data were rearranged such that,
for each metabolite, the data are collected into a dict or dict-like structure,
and an additional attribute ("Pathways") is defined as an array of entries
containing the differing pathways data per row of the same metabolite.  This
retains the context of which pathway is associated with each metabolite, but
avoids repetition of metabolite data.  However, this means that the format of
the data is no longer flat.


## Pathway data

The main body of data used for extracting pathway data is the set of all BioPAX
/ OWL files, a large number of XML files containing structured definitions of
each pathway.  The unique SMPDB ID is extracted for each pathway definition,
and a set of data for each reaction is extracted for each pathway.  The
reaction data includes the reaction ID, a set of compound IDs for each side of
the reaction, and the reaction direction.  With some formatting and
arrangement, these data can be used to define the nodes and links of the
visualisation.


[1]:https://pathbank.org/downloads
[2]:https://github.com/glm729/d3visKegg
