import re

with open("generate_scad.py", "r") as f:
    content = f.read()

hull_old = """            hull_code = f\"\"\"
            hull() {{
                // Front face (Y=0)
                translate([0, 0, 0]) cube([3, 3, ch]);
                translate([{cw}-3, 0, 0]) cube([3, 3, ch]);
                
                // Back face at bottom (Z=0) - Extremely tapered Y (D is 10, pt is 1.0, PCB_T is 1.6)
                // Let's taper Y to just 5.0 at the bottom! (r=3 means center at 2.0). 
                // X tapered heavily to 15!
                translate([15, 2.0, 0]) cylinder(r=3, h=0.1);
                translate([{cw}-15, 2.0, 0]) cylinder(r=3, h=0.1);
                
                // Back face middle-top (where Pico 2 starts, Z=90) - Full depth
                translate([5, {D}-3, 90.0]) cylinder(r=3, h=0.1);
                translate([{cw}-5, {D}-3, 90.0]) cylinder(r=3, h=0.1);
                
                // Back face at top (Z=ch) - Full depth, less X taper
                translate([3, {D}-3, ch-0.1]) cylinder(r=3, h=0.1);
                translate([{cw}-3, {D}-3, ch-0.1]) cylinder(r=3, h=0.1);
            }}\"\"\""""

hull_new = """            hull_code = f\"\"\"
            hull() {{
                // Front face (Y=0)
                translate([0, 0, 0]) cube([3, 3, ch]);
                translate([{cw}-3, 0, 0]) cube([3, 3, ch]);
                
                // Back face at bottom (Z=0) - Pure Wedge (Y-taper only)
                // Y tapers down to 5.0mm (r=3 means center at Y=2.0)
                // X remains straight, keeping the standard width.
                translate([3, 2.0, 0]) cylinder(r=3, h=0.1);
                translate([{cw}-3, 2.0, 0]) cylinder(r=3, h=0.1);
                
                // Back face middle-top (where Pico 2 starts, Z=90) - Full depth
                translate([3, {D}-3, 90.0]) cylinder(r=3, h=0.1);
                translate([{cw}-3, {D}-3, 90.0]) cylinder(r=3, h=0.1);
                
                // Back face at top (Z=ch) - Full depth
                translate([3, {D}-3, ch-0.1]) cylinder(r=3, h=0.1);
                translate([{cw}-3, {D}-3, ch-0.1]) cylinder(r=3, h=0.1);
            }}\"\"\""""

content = content.replace(hull_old, hull_new)

with open("generate_scad.py", "w") as f:
    f.write(content)
print("Fixed chassis X taper.")
