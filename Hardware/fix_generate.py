import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

btn_old = """    // 0. Bed Adhesion Micro-Supports (Z=0.0 to Z=0.2)
    // Connects the d=7.0 base to the d=7.6 hole in the faceplate to anchor the button during printing.
    // Extremely thin (0.2mm) so they break easily on first press.
    for(a=[0, 90, 180, 270]) {
        rotate([0, 0, a]) translate([3.5 + GAP/2, 0, 0.1]) cube([GAP+0.1, 0.6, 0.2], center=true);
    }"""

orig = orig.replace(btn_old.replace("{", "{{").replace("}", "}}"), "")

with open("generate_scad.py", "w") as f:
    f.write(orig)

