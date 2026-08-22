with open("generate_scad.py", "r") as f:
    orig = f.read()

# Fix the hull replacement in generate_scad.py!
orig = orig.replace("""    chassis_tapered = chassis
    # Pure Y Taper for hull
    hull_orig = \"\"\"hull() {
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }\"\"\"""",
"""    chassis_tapered = chassis
    # Pure Y Taper for hull
    hull_orig = \"\"\"hull() {{
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }}\"\"\"""")

hull_new_orig = """    hull_new = \"\"\"hull() {
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            // Tapered Y to 5.0 (center 2.0 with r 3.0)
            translate([3, 2.0, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 2.0, 0]) cylinder(r=3, h=0.1);
            // Full depth at Z=90
            translate([3, D-3, 90.0]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, 90.0]) cylinder(r=3, h=0.1);
            // Full depth at Z=ch
            translate([3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
        }\"\"\""""
        
hull_new_fixed = """    hull_new = \"\"\"hull() {{
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            // Tapered Y down to 4.5mm at bottom (Z=0)
            translate([3, 4.5, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 4.5, 0]) cylinder(r=3, h=0.1);
            // Full depth at Z=90
            translate([3, D-3, 90.0]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, 90.0]) cylinder(r=3, h=0.1);
            // Full depth at Z=ch
            translate([3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
        }}\"\"\""""
orig = orig.replace(hull_new_orig, hull_new_fixed)

with open("generate_scad.py", "w") as f:
    f.write(orig)
