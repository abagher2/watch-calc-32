import re

# Update generate_scad.py
with open("generate_scad.py", "r") as f:
    text = f.read()

target = """        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the FRONT_LIP to expose the faceplate.
        // Leaves a 2.0mm wide frame on left, right, and bottom.
        translate([wall + 2.0, -0.1, wall + 2.0])
            cube([cw - 2*wall - 4.0, {FRONT_LIP} + 0.2, ch - wall - 2.0 + 0.1]);"""

replacement = """        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the FRONT_LIP to expose the faceplate.
        // Leaves a 2.0mm wide frame on left, right, and bottom. And 3.0mm at top.
        translate([wall + 2.0, -0.1, wall + 2.0])
            cube([cw - 2*wall - 4.0, {FRONT_LIP} + 0.2, ch - wall - 2.0 - 3.0 + 0.1]);"""

text = text.replace(target, replacement)

with open("generate_scad.py", "w") as f:
    f.write(text)

# Update chassis_tapered.scad
with open("designs/chassis_tapered.scad", "r") as f:
    text = f.read()

target2 = """        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the FRONT_LIP to expose the faceplate.
        // Leaves a 2.0mm wide frame on left, right, and bottom.
        translate([wall + 2.0, -0.1, wall + 2.0])
            cube([cw - 2*wall - 4.0, FRONT_LIP + 0.2, ch - wall - 2.0 + 0.1]);"""

replacement2 = """        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the FRONT_LIP to expose the faceplate.
        // Leaves a 2.0mm wide frame on left, right, and bottom. And 3.0mm at top.
        translate([wall + 2.0, -0.1, wall + 2.0])
            cube([cw - 2*wall - 4.0, FRONT_LIP + 0.2, ch - wall - 2.0 - 3.0 + 0.1]);"""

text = text.replace(target2, replacement2)

with open("designs/chassis_tapered.scad", "w") as f:
    f.write(text)

