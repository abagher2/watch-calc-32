import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# Make the chassis cutouts use explicit variables for width instead of cw - 2*wall
orig = orig.replace("cw - 2*wall", "fp_w")

# Tier 2 is cw - 2*wall - 5.0, which becomes fp_w - 5.0
orig = orig.replace("cw - 2*wall - 5.0", "fp_w - 5.0")

# Tier 3 is cw - 2*wall - 11.0, which becomes fp_w - 11.0
orig = orig.replace("cw - 2*wall - 11.0", "fp_w - 11.0")

# And the height of the cutouts uses ch - wall. It should be fp_h
orig = orig.replace("ch - wall", "fp_h")

with open("generate_scad.py", "w") as f:
    f.write(orig)
