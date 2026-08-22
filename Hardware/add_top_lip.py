import re

with open("generate_scad.py", "r") as f:
    text = f.read()

target = """        // ── SCREW BOSSES (Drop down into chassis Tier 3 to Z=138) ─────────────────"""

replacement = """        // ── FRONT LIP (Drops down into bezel window to secure Faceplate) ──────
        // Completes the chassis O-frame since the chassis cannot have a bridged top lip
        translate([wall + 2.0, 0, ch - 3.7])
            cube([cw - 2*wall - 4.0, {FRONT_LIP}, 3.7]);

        // ── SCREW BOSSES (Drop down into chassis Tier 3 to Z=138) ─────────────────"""

text = text.replace(target, replacement)

with open("generate_scad.py", "w") as f:
    f.write(text)
