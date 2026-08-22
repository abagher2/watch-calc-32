import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# Add offset variables
orig = orig.replace("wall = {WALL:.3f};", "wall = {WALL:.3f};\noffset_x = (cw - fp_w) / 2;\noffset_z = (ch - fp_h) / 2;")

# Fix Tier 1
orig = orig.replace(
    "translate([wall, -0.1, -0.1])", 
    "translate([offset_x, -0.1, offset_z - 0.1])"
)

# Fix Tier 2 (now Tier 1.5/2)
orig = orig.replace(
    "translate([wall + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, -0.1])", 
    "translate([offset_x + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, offset_z - 0.1])"
)

# Fix screw bosses
orig = orig.replace(
    "translate([wall + sx - 3.0", 
    "translate([offset_x + sx - 3.0"
)
orig = orig.replace(
    "translate([wall + sx, pt, sy])", 
    "translate([offset_x + sx, pt, offset_z + sy])"
)

# Fix screw holes
orig = orig.replace(
    "translate([wall + {sx:.3f}, D + 0.1, {sy:.3f}])",
    "translate([offset_x + {sx:.3f}, D + 0.1, offset_z + {sy:.3f}])"
)

with open("generate_scad.py", "w") as f:
    f.write(orig)
