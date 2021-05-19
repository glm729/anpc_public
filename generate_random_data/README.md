# Generating data for testing visualisations
#### Mr. George L. Malone
#### 19<sup>th</sup> of May, 2021


## Overview

The purpose of these operations is to randomly generate some data to test an
application of a [D3 force-directed graph visualisation][1].  No raw or
experimental data were available or could be provided, thus data were
generating via the methods identified in this report.  The intent is to
randomly generate data that resembles experimental data.


## Data

### Input

The data were taken from Table 1 of [this article][2].  The data are provided
in a tab-separated format.  Some characters had to be replaced due to
compatibility errors, but the replacement characters are directly analogous to
those replaced.  The data specify the names of metabolites, the median values
for control (pathogen-negative) and pathogen-positive subjects, the median
difference between groups, and the variance of the difference between groups.


### Cleaning

The raw text data were first cleaned and converted to JSON.  The main
operations were to remove undesired characters, replace key names, and extract
the desired statistical distribution data.  The script used to complete these
tasks is [`paper1_getparams.py`][3].


### Mashing

The data are mangled in a criminal fashion for the purpose of random
generation.  The assumptions are thus:

- The control and positive groups feature identical distributions with the
  exception of the central location.
- The distributions of the control and positive groups follow the expectations
  and requirements of a perfect Normal distribution.
- As the distributions are perfectly symmetric, the median and mean of each
  group are identical.
- The worst part -- the variance of each group is identical to the variance of
  the median of the differences between groups.
  - I'd be curious to know if this has literally any statistical grounding
    whatsoever.
  - This was chosen as it was the only source of information resembling
    variances of the groups.

The data were generated given these rather shaky assumptions.


### Generation

[NumPy][4] is used to randomly generate data from a Normal distribution, given
central location and assumed standard deviation.  One thousand samples are
generated per metabolite, and the mean value calculated.  The difference of the
means is also calculated.  These values are converted into a TSV and written
out.  The main data of interest are the names and differences in central
location -- these will be used to identify nodes and to provide visual
parameters, respectively.  The script used to complete these operations is
[`paper1_generate.py`][5].


[1]:https://github.com/glm729/d3visKegg
[2]:https://dx.doi.org/10.1021/acs.jproteome.1c00052
[3]:./paper1_getparams.py
[4]:https://numpy.org/
[5]:./paper1_generate.py
