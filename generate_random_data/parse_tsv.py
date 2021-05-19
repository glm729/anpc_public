#!/usr/bin/env python3

# These functions are used to read and parse tab-delimited files, as well as
# write back to tab-delimited files.


# Generate a dummy header of length `l`
def dummy_header(l):
    return ["X{0}".format(str(i).rjust(len(str(l))), "0") for i in range(0, l)]


# Read and parse a tab-delimited file as a dict
def parse_tsv(path, header=True):
    with open(path, "r") as file:
        data = list(map(
            lambda t : t.split("\t"),
            file.read().rstrip().split("\n")))
    if header:
        head = data[0]
        data = data[1:]
    else:
        head = dummy_header(len(data[0]))
    return list(map(
        lambda r : dict(map(lambda i : [head[i], r[i]], range(0, len(head)))),
        data))


# Convert a dict into a tab-delimited file
def dict_to_tsv(data, key_spec=None):
    all_keys = list(map(lambda d : list(d.keys()), data))
    unique_keys = list(set([v for s in all_keys for v in s]))
    if key_spec is not None:
        if len(key_spec) != len(unique_keys):
            raise RuntimeError("Key spec length does not match unique keys")
        if any([k not in unique_keys for k in key_spec]):
            raise RuntimeError("Unique key missing from key spec")
        use_keys = key_spec
    else:
        use_keys = unique_keys
        use_keys.sort()
    output = ["{0}{1}".format("\t".join(use_keys), "\n")]
    for entry in data:
        ci = []
        for key in use_keys:
            try:
                if entry[key] is not None:
                    ci.append(str(entry[key]))
                    continue
            except KeyError:
                pass
            ci.append("")
        output.append("{0}\n".format("\t".join(ci)))
    return "".join(output)
