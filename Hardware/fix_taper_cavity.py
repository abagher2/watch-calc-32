import re

# Read chassis.scad to get the correct structure, then apply the wedge taper
with open("designs/chassis.scad", "r") as f:
    orig = f.read()

# 1. We replace the hull() in chassis_shell to be a single perfect wedge
hull_pattern = r'        hull\(\) \{.*?\n        \}'
hull_new = """        hull() {
            // Front face (Y=0 to 3) is perfectly straight and parallel to Faceplate
            translate([3, 3, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 3, 0]) cylinder(r=3, h=0.1);
            translate([3, 3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, 3, ch-0.1]) cylinder(r=3, h=0.1);

            // Back face (Y = 14.9 at top, Y = 7.9 at bottom)
            translate([3, 7.9 - 3, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 7.9 - 3, 0]) cylinder(r=3, h=0.1);
            translate([3, D - 3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, D - 3, ch-0.1]) cylinder(r=3, h=0.1);
        }"""
orig = re.sub(hull_pattern, hull_new, orig, flags=re.DOTALL)

# 2. We replace Tier 3 cavity to be sloped so we don't cut through the back wall!
t3_pattern = r'        // Tier 3:.*?cube\(\[cw - 2\*wall - 11.0, D - wall - pt - 1.6 \+ 0.1, ch - wall \+ 0.2\]\);'
t3_new = """        // Tier 3: Back Components Clearance (Deepest)
        // Sloped to follow the outer wedge hull!
        hull() {
            // Bottom (Z=-0.1) - Cavity depth is 0 here since chassis is thin.
            translate([wall + 5.5, pt + 1.6 - 0.1, -0.1]) 
                cube([cw - 2*wall - 11.0, 0.1, 0.1]);
            // Top (Z=ch) - Cavity depth is full here.
            translate([wall + 5.5, pt + 1.6 - 0.1, ch - wall + 0.2]) 
                cube([cw - 2*wall - 11.0, D - wall - pt - 1.6 + 0.1, 0.1]);
        }"""
orig = re.sub(t3_pattern, t3_new, orig, flags=re.DOTALL)

# 3. We remove railway_grooves entirely for the tapered design
orig = orig.replace("        railway_grooves();", "")

with open("designs/chassis_tapered.scad", "w") as f:
    f.write(orig)
