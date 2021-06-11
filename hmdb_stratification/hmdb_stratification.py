#!/usr/bin/env python3


# Module imports
# -----------------------------------------------------------------------------


import os
import yaml
import functools as ft
import multiprocessing as mp
import xmltodict as xd


# Function definitions
# -----------------------------------------------------------------------------


# Helper to read and parse an XML file
def read_xml(path):
    with open(path, "r") as file:
        data = file.read()
    return xd.parse(data)


# Helper to grab taxonomical information, according to certain keys
def taxonomy_info(data, keys):
    taxonomy = data.get("taxonomy", None)
    if taxonomy is None:
        return None
    result = {}
    for k in keys:
        result[k] = taxonomy.get(k, None)
    return result


# Mappable function to get taxonomy information per file
def get_taxonomy_info(file, keys):
    data = read_xml(file["path"])["hmdb"]["metabolite"]
    return [file["id"], taxonomy_info(data, keys)]


# Helper to get the taxonomical information per descending group
def taxonomy_info_groups(data):
    result = {}
    for key in data:
        if data.get(key, None) is None:
            continue
        ckeys = list(data[key].keys())
        for c in ckeys:
            d = data[key].get(c, None)
            if d is None:
                continue
            if not result.get(c, False):
                result[c] = {}
            if not result[c].get(d, False):
                result[c][d] = 0
            result[c][d] += 1
    return result


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


# Define the taxonomy keys to grab
keys = [
    "direct_parent",
    "kingdom",
    "super_class",
    "class",
    "sub_class"
]

# Define the directory in which to search
dir_in = "../_data/hmdb/hmdb_metabolites"

msg("data", "Searching for HMDB XML data")

# Get the files in the directory
files_in = os.listdir(dir_in)
files_in.sort()

# Get the HMDB IDs and file paths in the directory
ids = []
files = []
for f in files_in:
    ids.append(f.replace(".xml", ''))
    files.append(f'{dir_in}/{f}')

# Generate a file spec array of dicts (for the worker pool map)
file_spec = [{"id": ids[i], "path": files[i]} for i in range(0, len(files_in))]

# Run the parallel worker pool
msg("info", "Running worker pool")
with mp.Pool(14) as worker_pool:
    func = ft.partial(get_taxonomy_info, keys=keys)
    result = worker_pool.map(func, file_spec)

msg("info", "Arranging collected data")

# Convert the result to a dict
dresult = dict(result)

# Get the taxonomy information per descending group
taxonomy_info = taxonomy_info_groups(dresult)

# Define a key ordering, and sort the taxonomy info
key_order = {
    "direct_parent": 0,
    "kingdom": 1,
    "super_class": 2,
    "class": 3,
    "sub_class": 4
}

tax_sort = dict(sorted(
    taxonomy_info.items(),
    key=lambda e : key_order[e[0]]))

# Sort the subgroups by name and number
tax_sort_name = tax_sort.copy()
tax_sort_num = tax_sort.copy()
# Find out how many are counted in each major and minor taxonomical group
tax_major = {}
tax_minor = {}
# Loop over the keys
for t in tax_sort:
    # Sorting
    tax_sort_name[t] = dict(sorted(
        tax_sort_name[t].items(),
        key=lambda i : i[0]))
    tax_sort_num[t] = dict(sorted(
        tax_sort_name[t].items(),  # Sneaky trick here
        key=lambda i : i[1]))
    # Counting
    tax_major[t] = sum([e[1] for e in tax_sort[t].items()])
    tax_minor[t] = len(tax_sort[t].items())

# Write the output YAML files
msg("data", "Writing output YAML files")
# Alphabetical
with open("../_data/hmdb_stratification_alphabetic.yaml", "w") as file:
    file.write(yaml.dump(tax_sort_name, sort_keys=False))
# Numeric
with open("../_data/hmdb_stratification_numeric.yaml", "w") as file:
    file.write(yaml.dump(tax_sort_num, sort_keys=False))

# Generate the output TSV string
msg("info", "Generating output TSV")
tsv = "Group\tSubgroup\tCount\n"
for group in tax_sort_num:
    for subgroup in tax_sort_num[group]:
        tsv += f'{group}\t{subgroup}\t{tax_sort_num[group][subgroup]}\n'

# Write the output TSV
msg("data", "Writing output TSV")
with open("../_data/hmdb_stratification_tsv.tsv", "w") as file:
    file.write(tsv)

# All done
msg("ok", "End of operations")
