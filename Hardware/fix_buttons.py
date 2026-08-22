import re
with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. Update key_button
button_pattern = r'module key_button\(w, h, label\) \{.*?\}'
button_new = """module key_button(w, h, label) {
    // CYLINDRICAL PEG (Print-in-place)
    // Prints flat on the bed (Z=0) so it rests exactly on the tactile plunger.
    
    // 1. Base Peg (Z=0.0 to Z=1.0)
    // Removed bottom micro-supports per user request.
    translate([0, 0, 0.5]) cylinder(d=5.0, h=1.0, center=true);
    
    // 2. Flange (Z=1.0 to Z=1.6)
    // Prevents button from falling out the front.
    translate([0, 0, 1.3]) cylinder(d=6.5, h=0.6, center=true);
    
    // 3. Upper Shaft (Z=1.6 to Z=3.7)
    // Extended so the keycap is fully above the faceplate.
    translate([0, 0, 2.65]) cylinder(d=5.0, h=2.1, center=true);
    
    // 4. Top Micro-Supports (Z=2.8 to Z=3.0)
    // Strings even with the top of the faceplate to prevent wobbling during the rest of the print.
    for(a=[0, 90, 180, 270]) {
        rotate([0, 0, a]) translate([2.5 + GAP/2, 0, 2.9]) cube([GAP+0.1, 0.4, 0.2], center=true);
    }
    
    // 5. Keycap (Z=3.7 to Z=5.0)
    hull() {
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
}"""
orig = re.sub(button_pattern, button_new, orig, flags=re.DOTALL)

# 2. Update button_pocket
pocket_pattern = r'module button_pocket\(x, y, w, h\) \{.*?\}\n\}'
pocket_new = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
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
}"""
orig = re.sub(pocket_pattern, pocket_new, orig, flags=re.DOTALL)

with open("generate_scad.py", "w") as f:
    f.write(orig)

print("Updated generate_scad.py")
