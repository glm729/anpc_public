#!/usr/bin/env python3


# Import modules
# -----------------------------------------------------------------------------


from parse_tsv import *
import numpy as np
import json


# Function definitions
# -----------------------------------------------------------------------------


# Helper to read and parse a JSON
def read_json(path):
    with open(path, "r") as file:
        data = file.read().rstrip()
    return json.loads(data)


# Hardcoded function to generate random data per entry
def random_data(d):
    n = d["name"]
    mc = d["median_control"]
    mp = d["median_positive"]
    sd = d["dist"]["sd"]
    con = np.random.normal(float(mc), sd, 1000)
    pos = np.random.normal(float(mp), sd, 1000)
    mcon = np.mean(con)
    mpos = np.mean(pos)
    diff = mpos - mcon
    return {"name": n, "con": mcon, "pos": mpos, "diff": diff}


# Operations
# -----------------------------------------------------------------------------


# Define paths to use
path = {
    "in": "./_data/paper1_table1.json",
    "out": "./_data/paper1_random1.tsv"
}

# Define key spec for output
key_spec = ["name", "con", "pos", "diff"]

# Read the input JSON
data = read_json(path["in"])

# Generate random data for each entry (metabolite)
output = [random_data(d) for d in data]

# Write out
with open(path["out"], "w") as file:
    file.write(dict_to_tsv(output, key_spec=key_spec))
