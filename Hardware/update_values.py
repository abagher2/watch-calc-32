import re

# Update generate_scad.py FRONT_LIP
with open("generate_scad.py", "r") as f:
    text = f.read()

text = text.replace("FRONT_LIP = 1.5", "FRONT_LIP = 0.5")

# Update button shape to retro circles
text = text.replace(
"""    // 3. Keycap (Z=4.5 to Z=5.8)
    hull() {
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(d=2.0, h=1.3, center=true);
        }
    }""",
"""    // 3. Keycap (Z=4.5 to Z=5.8) - RETRO CIRCLES
    hull() {
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) cylinder(d=6.0, h=1.3, center=true);
    }""")

# Handle double brace version just in case
text = text.replace(
"""    // 3. Keycap (Z=4.5 to Z=5.8)
    hull() {{
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) hull() {{
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(d=2.0, h=1.3, center=true);
        }}
    }}""",
"""    // 3. Keycap (Z=4.5 to Z=5.8) - RETRO CIRCLES
    hull() {{
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) cylinder(d=6.0, h=1.3, center=true);
    }}""")

with open("generate_scad.py", "w") as f:
    f.write(text)

# Update chassis_tapered.scad
with open("designs/chassis_tapered.scad", "r") as f:
    taper_text = f.read()

taper_text = taper_text.replace("FRONT_LIP = 1.500;", "FRONT_LIP = 0.500;")
taper_text = taper_text.replace("D    = 16.400;", "D    = 15.400;")

with open("designs/chassis_tapered.scad", "w") as f:
    f.write(taper_text)

