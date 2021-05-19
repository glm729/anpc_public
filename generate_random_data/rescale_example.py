#!/usr/bin/env python3

# Rmd cells for the report of the same filename (except extension), in their
# own slightly-reformatted file


# Import modules
# -----------------------------------------------------------------------------


from parse_tsv import *
import json


# Function definitions
# -----------------------------------------------------------------------------


# Scale an array of values, according to input specification
def scale_array(arr, new_scale):
    # Initialise the old scale
    old_scale = {"max": max([abs(a) for a in arr])}
    old_scale["min"] = -old_scale["max"]
    # Initialise output array
    out = []
    # Loop over the input array
    for val in arr:
        # Get the proportion of the old scale
        prop = (val - old_scale["min"]) / (old_scale["max"] - old_scale["min"])
        # Multiply it by the new scale
        new_prop = prop * (new_scale["max"] - new_scale["min"])
        # Append the offset value
        out.append(new_prop + new_scale["min"])
    # Return the output array
    return out


# Get the visualisation-formatted hex value for the current scaled value
def get_vis_hex(val):
    # Initialise string components
    v = {"neg": "00", "pos": "00"}
    # Pick which key to modify
    k = "neg" if val < 0 else "pos"
    # Modify the value
    v[k] = hex(val).split("x")[1].rjust(2, "0")
    # Return the formatted string
    return f'#{v["neg"]}{v["pos"]}00'


# Operations
# -----------------------------------------------------------------------------


# Define file paths to use
path = {
    "in": "./_data/paper1_random1.tsv",
    "out": "./_data/paper1_vis."
}

# Read, parse, and sort the data
data = sorted(parse_tsv(path["in"]), key = lambda e : e["name"])

# Get floating-point values for diff
diff = [float(d["diff"]) for d in data]

# Define the new scale to use
new_scale = {"min": -255, "max": 255}

# Perform the rescale operation
diff_rescale = scale_array(diff, new_scale = new_scale)

# Compare the original and rescaled data
print_data = "Original\tScaled"

for i in range(0, 6):
    orig = round(diff[i], 4)
    resc = round(diff_rescale[i], 4)
    print_data += f'\n{orig: .{4}}\t{resc: .{4}}'

print(print_data)

# Check output format of hexadecimal numbers
print(hex(255))
print(hex(3))

# Try to get a properly-formatted hex number
print(hex(3).split("x")[1].rjust(2, "0"))

# Get the colours to use in the visualisation
colours = [get_vis_hex(round(v)) for v in diff_rescale]

# Check the result
print_data = "Original\tScaled\tHexcode"

for i in range(0, 6):
    orig = round(diff[i], 4)
    resc = round(diff_rescale[i], 4)
    print_data += f'\n{orig: .{4}}\t{resc: .{4}}\t{colours[i]}'

print(print_data)

# Prepare new data to write out
new_data = []

for i in range(0, len(data)):
    new_data.append({
        "name": data[i]["name"],
        "id": None,
        "nodeColour": colours[i]
    })

# Write the TSV for the visualisation data
with open(path["out"] + "tsv", "w") as file:
    file.write(dict_to_tsv(new_data, key_spec = ["name", "id", "nodeColour"]))
