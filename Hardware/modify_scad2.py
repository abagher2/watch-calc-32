import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# 1. Update chassis TPU to have NO railway grooves
groove_orig = """module railway_grooves() {{
    translate([-0.1, {GY:.1f}, -0.1])        cube([{s_GCD}+0.1, {s_GCW}, ch+0.2]);
    translate([cw-{s_GCD}, {GY:.1f}, -0.1])      cube([{s_GCD}+0.1, {s_GCW}, ch+0.2]);
    translate([-0.1, {GY + s_GCW/2}, 5.0]) rotate([0, 90, 0]) cylinder(d={s_GCW}, h={s_GCD}+0.5, $fn=16);
    translate([cw-{s_GCD}-0.4, {GY + s_GCW/2}, 5.0]) rotate([0, 90, 0]) cylinder(d={s_GCW}, h={s_GCD}+0.5, $fn=16);
}}"""

groove_new = """module railway_grooves() {{
    if style != "TPU":
        code = f\"\"\"
        translate([-0.1, {GY:.1f}, -0.1])        cube([{s_GCD}+0.1, {s_GCW}, ch+0.2]);
        translate([cw-{s_GCD}, {GY:.1f}, -0.1])      cube([{s_GCD}+0.1, {s_GCW}, ch+0.2]);
        translate([-0.1, {GY + s_GCW/2}, 5.0]) rotate([0, 90, 0]) cylinder(d={s_GCW}, h={s_GCD}+0.5, $fn=16);
        translate([cw-{s_GCD}-0.4, {GY + s_GCW/2}, 5.0]) rotate([0, 90, 0]) cylinder(d={s_GCW}, h={s_GCD}+0.5, $fn=16);
        \"\"\"
        return code
    return ""
}}
"""
# Wait, this is inside python string `build_chassis_scad` !
# Let's do it cleanly by putting the condition inside the Python code that generates the string!

