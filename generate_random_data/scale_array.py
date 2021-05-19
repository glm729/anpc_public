#!/usr/bin/env python3


def scale_array(arr, new_scale):
    old_scale = {"max": max([abs(a) for a in arr])}
    old_scale["min"] = -old_scale["max"]
    out = []
    for val in arr:
        prop = (val - old_scale["min"]) / (old_scale["max"] - old_scale["min"])
        new_prop = prop * (new_scale["max"] - new_scale["min"])
        out.append(new_prop + new_scale["min"])
    return out
