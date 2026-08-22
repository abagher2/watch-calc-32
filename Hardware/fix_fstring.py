with open("generate_scad.py", "r") as f:
    orig = f.read()

# I used { instead of {{ in my replacement string for hull() and for loops
orig = orig.replace("""    for(a=[0, 90, 180, 270]) {
        rotate([0, 0, a]) translate([2.5 + GAP/2, 0, 2.9]) cube([GAP+0.1, 0.4, 0.2], center=true);
    }""", """    for(a=[0, 90, 180, 270]) {{
        rotate([0, 0, a]) translate([2.5 + GAP/2, 0, 2.9]) cube([GAP+0.1, 0.4, 0.2], center=true);
    }}""")

orig = orig.replace("""    hull() {
        translate([0, 0, 3.71]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 4.35]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 5.0]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}""", """    hull() {{
        translate([0, 0, 3.71]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 4.35]) hull() {{
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }}
        translate([0, 0, 5.0]) hull() {{
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }}
    }}
}}""")

orig = orig.replace("""    translate([x, y, 0]) {
        // 1. Bottom Shaft Hole (Z=-0.1 to Z=1.0)
        translate([0, 0, 0.45]) cylinder(d=5.0 + GAP*2, h=1.1, center=true);
        
        // 2. Flange Cavity (Z=1.0 to Z=1.6)
        translate([0, 0, 1.3]) cylinder(d=6.5 + GAP*2, h=0.6, center=true);
        
        // 3. Roof Chamfer (Z=1.6 to Z=2.0)
        // Transitions from 6.5 back to 5.0 without overhangs.
        hull() {
            translate([0, 0, 1.6]) cylinder(d=6.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.0]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
        }
        
        // 4. Upper Shaft Hole (Z=2.0 to Z=3.1)
        // Punches cleanly through the top of the faceplate (Z=3.0).
        // Since keycap is entirely above Z=3.7, we don't need a rectangular indentation.
        translate([0, 0, 2.55]) cylinder(d=5.0 + GAP*2, h=1.1, center=true);
    }
}""", """    translate([x, y, 0]) {{
        // 1. Bottom Shaft Hole (Z=-0.1 to Z=1.0)
        translate([0, 0, 0.45]) cylinder(d=5.0 + GAP*2, h=1.1, center=true);
        
        // 2. Flange Cavity (Z=1.0 to Z=1.6)
        translate([0, 0, 1.3]) cylinder(d=6.5 + GAP*2, h=0.6, center=true);
        
        // 3. Roof Chamfer (Z=1.6 to Z=2.0)
        // Transitions from 6.5 back to 5.0 without overhangs.
        hull() {{
            translate([0, 0, 1.6]) cylinder(d=6.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.0]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
        }}
        
        // 4. Upper Shaft Hole (Z=2.0 to Z=3.1)
        // Punches cleanly through the top of the faceplate (Z=3.0).
        // Since keycap is entirely above Z=3.7, we don't need a rectangular indentation.
        translate([0, 0, 2.55]) cylinder(d=5.0 + GAP*2, h=1.1, center=true);
    }}
}}""")

orig = orig.replace("""module key_button(w, h, label) {""", """module key_button(w, h, label) {{""")
orig = orig.replace("""module button_pocket(x, y, w, h) {""", """module button_pocket(x, y, w, h) {{""")

with open("generate_scad.py", "w") as f:
    f.write(orig)
