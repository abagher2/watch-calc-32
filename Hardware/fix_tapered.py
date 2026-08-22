import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. Add TACTILE_H to the SCAD globals
orig = orig.replace("junc = {junc_z:.2f};", "junc = {junc_z:.2f};\nTACTILE_H = {TACTILE_H:.3f};")

# 2. Fix the replacement for Tier 3 in chassis_tapered
t3_orig_old = '    t3_orig = """translate([wall + 5.5, pt + {PCB_T} - 0.1, -0.1])\n            cube([cw - 2*wall - 11.0, D - wall - pt - {PCB_T} + 0.1, ch - wall + 0.2]);"""'
t3_orig_new = '    t3_orig = """translate([wall + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, -0.1])\n            cube([cw - 2*wall - 11.0, D - wall - (pt + TACTILE_H + {PCB_T}) + 0.1, ch - wall + 0.2]);"""'
orig = orig.replace(t3_orig_old, t3_orig_new)

t3_new_old = '    t3_new = """translate([wall + 5.5, pt + {PCB_T} - 0.1, 90.0])\n            cube([cw - 2*wall - 11.0, D - wall - pt - {PCB_T} + 0.1, ch - 90.0]);"""'
t3_new_new = '    t3_new = """translate([wall + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, 90.0])\n            cube([cw - 2*wall - 11.0, D - wall - (pt + TACTILE_H + {PCB_T}) + 0.1, ch - 90.0]);"""'
orig = orig.replace(t3_new_old, t3_new_new)

with open("generate_scad.py", "w") as f:
    f.write(orig)
