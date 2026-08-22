with open("designs/chassis_tapered.scad", "r") as f:
    text = f.read()

text = text.replace(
"""            // Back face (Y = 14.9 at top, Y = 7.9 at bottom)
            translate([3, 7.9 - 3, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 7.9 - 3, 0]) cylinder(r=3, h=0.1);""",
"""            // Back face (Y = 16.4 at top, Y = 9.4 at bottom)
            translate([3, 9.4 - 3, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 9.4 - 3, 0]) cylinder(r=3, h=0.1);""")

with open("designs/chassis_tapered.scad", "w") as f:
    f.write(text)
