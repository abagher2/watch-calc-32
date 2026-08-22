import re

with open("designs/chassis_tapered.scad", "r") as f:
    orig = f.read()

# 1. Update the cavities to be Top-Loading (open at top, closed at bottom)
cavities_pattern = r'        translate\(\[wall, -0\.1, -0\.1\]\).*?0\.1\]\);\n        \}'
cavities_new = """        // Tier 1: Faceplate (Closed bottom, Open top)
        translate([wall, -0.1, wall])
            cube([cw - 2*wall, pt + 0.1, ch + 0.2]);
            
        // Tier 2: PCB
        translate([wall + 2.5, pt - 0.1, wall])
            cube([cw - 2*wall - 5.0, 1.6 + 0.2, ch + 0.2]);
            
        // Tier 3: Back Components Clearance (Deepest)
        // Sloped to follow the outer wedge hull!
        hull() {
            // Bottom (Z=wall) - Cavity depth is 0 here since chassis is thin.
            translate([wall + 5.5, pt + 1.6 - 0.1, wall]) 
                cube([cw - 2*wall - 11.0, 0.1, 0.1]);
            // Top (Z=ch+0.1) - Cavity depth is full here.
            translate([wall + 5.5, pt + 1.6 - 0.1, ch + 0.1]) 
                cube([cw - 2*wall - 11.0, D - wall - pt - 1.6 + 0.1, 0.1]);
        }"""
orig = re.sub(cavities_pattern, cavities_new, orig, flags=re.DOTALL)

# 2. Update screw bosses to provide the BOTTOM bosses (Z=5) since top_cap will provide top bosses
bosses_pattern = r'module screw_bosses\(\) \{.*?\}'
bosses_new = """module screw_bosses() {
    for (sx = [7.0, cw - 2*wall - 7.0]) {
        for (sy = [5.0]) { // Bottom screw position (was at ch-wall-5.0)
            // Peg that passes through the PCB 1.6mm thickness
            translate([wall + sx, pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h=1.6 + 0.1);
        }
    }
}"""
orig = re.sub(bosses_pattern, bosses_new, orig, flags=re.DOTALL)

# 3. Rename header comment to Top-Loading
orig = orig.replace("(Closed Top, Bottom-Loading)", "(Closed Bottom, Top-Loading)")

with open("designs/chassis_tapered.scad", "w") as f:
    f.write(orig)

print("Updated chassis_tapered.scad to Top-Loading")
