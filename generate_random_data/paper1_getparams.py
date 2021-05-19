#!/usr/bin/env python3


# Import modules
# -----------------------------------------------------------------------------


from parse_tsv import *
import json
import math


# Function definitions
# -----------------------------------------------------------------------------


# Hardcoded helper to replace a specific character in the pasted text
def replace_dash(text):
    if all([ord(t) != 8211 for t in text]):
        return text
    ntext = ""
    for t in text:
        if ord(t) == 8211:
            ntext += "-"
            continue
        ntext += t
    return ntext


# Extract the concentration (value) from the raw string
def clean_conc(v):
    s = v.split(" ")
    if len(s) < 3:
        raise RuntimeError("Split concentration is too short")
    m = float(replace_dash(s[0]))
    e = float(replace_dash(s[2][2:]))
    return m * (10 ** e)


# Replace the keys in a dict with a given set, whereby order is critical
# FIXME?  Might want to tie this down somewhat
def replace_keys(obj, keys):
    ok = list(obj.keys())
    if len(ok) != len(keys):
        raise RuntimeError("Keys to replace are not of same length")
    return dict([[keys[i], obj[ok[i]]] for i in range(0, len(keys))])


# Operations
# -----------------------------------------------------------------------------


# Define paths to use
path = {
    "in": "./_data/paper1_table1.txt",
    "out": "./_data/paper1_table1.json"
}

# Define new keys to use in the dicts
new_keys = [
    "name",
    "median_control",
    "median_positive",
    "median_diff",
    "ci_95_lower",
    "ci_95_upper",
    "mannwhitney_rho",
    "bh_q",
    "mannwhitney_eff"
]

# Get the keys for the numeric values
num_keys = [k for k in new_keys if k != "name"]

# Read the data and replace keys
data = list(map(lambda p : replace_keys(p, new_keys), parse_tsv(path["in"])))

# Loop over the data, clean the concentration value, and get distribution info
for d in data:
    for k in num_keys:
        d[k] = round(clean_conc(d[k]), 8)
    sd = abs(d["ci_95_upper"] - d["median_diff"]) / 1.96
    d["dist"] = {"median": d["median_diff"], "sd": round(sd, 4)}

# Write the "new" data out
with open(path["out"], "w") as file:
    file.write(json.dumps(data, indent=2) + "\n")
