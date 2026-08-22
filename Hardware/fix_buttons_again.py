import re

with open("generate_scad.py", "r") as f:
    text = f.read()

target = """    // 3. Keycap (Z=4.5 to Z=5.8)
    hull() {{
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) hull() {{
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }}
        translate([0, 0, 5.8]) hull() {{
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }}
    }}"""

replacement = """    // 3. Keycap (Z=4.5 to Z=5.8) - RETRO CIRCLES
    hull() {{
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.8]) cylinder(d=6.0, h=0.01, center=true);
    }}"""

text = text.replace(target, replacement)

with open("generate_scad.py", "w") as f:
    f.write(text)
