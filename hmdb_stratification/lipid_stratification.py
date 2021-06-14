#!/usr/bin/env python3


# Module imports
# -----------------------------------------------------------------------------


import json
import yaml


# Function definitions
# -----------------------------------------------------------------------------


# Helper to read and parse a JSON file
def read_json(path):
    with open(path, "r") as file:
        data = file.read()
    return json.loads(data)


# Helper to print a formatted message in the console
def msg(ty, tx):
    f = {
        "exit": "\033[7;31m EXIT \033[0m ",
        "ok":   "\033[7;32m  OK  \033[0m ",
        "warn": "\033[7;33m WARN \033[0m ",
        "info": "\033[7;34m INFO \033[0m ",
        "data": "\033[7;36m DATA \033[0m "
    }
    print(f'{f[ty]}{tx}')
    return None


# Operations
# -----------------------------------------------------------------------------


# Read in the taxonomical data from the previous operations
# (The variable `dresult` was saved as a JSON)
msg("data", "Reading input JSON")
hmdb_tax = read_json("./dresult.json")

# Pick lipids superclass only
msg("info", "Subsetting to lipids only")
lipids = {}
for h in list(hmdb_tax.keys()):
    if hmdb_tax.get(h, None) is None:
        continue
    s = hmdb_tax[h].get("super_class", None)
    if s == "Lipids and lipid-like molecules":
        lipids[h] = hmdb_tax[h].copy()

# Get info for counts
msg("info", "Getting counts info")
info = {}
for l in lipids:
    for k in list(lipids[l].keys()):
        if lipids[l].get(k, None) is None:
            continue
        if info.get(k, None) is None:
            info[k] = {}
        if info[k].get(lipids[l][k], None) is None:
            info[k][lipids[l][k]] = 0
        info[k][lipids[l][k]] += 1

# Sort by alphabetic and numeric occurrences
msg("info", "Sorting data")
info_sort_name  = info.copy()
info_sort_num = info.copy()
for i in info:
    info_sort_name[i] = dict(sorted(
        info_sort_name[i].items(),
        key=lambda e : e[0]))
    info_sort_num[i] = dict(sorted(
        info_sort_name[i].items(),
        key=lambda e : e[1]))

# Generate the TSV string to write out
msg("info", "Generating output TSV")
tsv = "Group\tSubgroup\tCount\n"
for group in info_sort_num:
    for subgroup in info_sort_num[group]:
        tsv += f'{group}\t{subgroup}\t{info_sort_num[group][subgroup]}\n'

# Write the output YAMLs
msg("data", "Writing output YAML files")
with open("./lipid_stratification_alphabetic.yaml", "w") as file:
    file.write(yaml.dump(info_sort_name, sort_keys=False))
with open("./lipid_stratification_numeric.yaml", "w") as file:
    file.write(yaml.dump(info_sort_num, sort_keys=False))

# Write the output TSV
msg("data", "Writing output TSV")
with open("./lipid_stratification_tsv.tsv", "w") as file:
    file.write(tsv)

# Done
msg("ok", "End of operations")
exit(0)
