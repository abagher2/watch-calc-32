import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 2. Update key_button and button_pocket
btn_old = """module key_button(w, h, label) {
    // CYLINDRICAL PISTON
    // Top of tactile switch is at Z=1.5 (since PCB is at Z=3.0 and switch is 1.5mm tall).
    // The piston extends down to Z=1.0 (0.5mm clearance below the switch top, to allow travel!)
    // Wait, if it extends to Z=1.0, it will crush the switch? No, it's printed at Z=1.0 with a gap!
    // We will just print it starting at Z=0.0 (flush with back of faceplate). It will touch the switch.
    // The tactile switch body is 0.6mm, so from Z=0 to Z=1.5 is the switch plunger.
    // So the piston must go from Z=1.5 to Z=3.2.
    // Actually, to make it print-in-place with powder, we can go Z=-0.5 to Z=3.2!
    // The user requested it to go "below the faceplate" (Z<0). 
    // We'll set the bottom of the plunger at Z = -1.0.
    translate([0, 0, -0.25]) cylinder(d=5.0, h=1.5, center=true);
    
    // Flange at Z = 0.5 to 1.5 (prevents falling out the front)
    hull() {
        translate([0, 0, 0.51]) cylinder(d=6.5, h=0.01, center=true);
        translate([0, 0, 1.49]) cylinder(d=5.5, h=0.01, center=true);
    }
    
    // Shaft from Z = 1.5 to 3.2
    translate([0, 0, 2.35]) cylinder(d=5.5, h=1.7, center=true);
    
    // Keycap from Z = 3.2 to 4.5
    hull() {
        translate([0, 0, 3.21]) cylinder(d=5.5, h=0.01, center=true);
        translate([0, 0, 3.85]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 4.5]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}"""

btn_new = """module key_button(w, h, label) {
    // CYLINDRICAL PISTON (Print-in-place)
    // Tactile switch top is at Z = 1.5. Button rests exactly on it.
    // Flange (Z = 1.5 to 2.0)
    translate([0, 0, 1.75]) cylinder(d=6.5, h=0.5, center=true);
    
    // Shaft (Z = 2.0 to 3.2)
    translate([0, 0, 2.6]) cylinder(d=5.0, h=1.2, center=true);
    
    // Keycap (Z = 3.2 to 4.5)
    hull() {
        translate([0, 0, 3.21]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 3.85]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 4.5]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}"""
orig = orig.replace(btn_old, btn_new)

pocket_old = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // Bottom clearance for plunger (-1.0 to 0.5)
        translate([0, 0, -0.2]) cylinder(d=6.5 + GAP*2, h=1.6, center=true);
        
        // Flange roof (0.5 to 1.5)
        hull() {
            translate([0, 0, 0.5]) cylinder(d=6.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 1.5]) cylinder(d=5.5 + GAP*2, h=0.01, center=true);
        }
        
        // Shaft hole (1.5 to 2.3)
        translate([0, 0, 1.9]) cylinder(d=5.5 + GAP*2, h=0.8, center=true);
        
        // Top Indentation (2.3 to 3.1)
        hull() {
            translate([0, 0, 2.3]) cylinder(d=5.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.7]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
            translate([0, 0, 3.1]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
        }
    }
}"""
pocket_new = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // Switch & Flange Cavity (Z = -0.1 to 2.0)
        // Must clear the 6.0x3.5mm tactile switch, plus provide travel room for the 6.5mm flange.
        // d=7.5 easily clears everything.
        translate([0, 0, 0.95]) cylinder(d=7.5, h=2.1, center=true);
        
        // Roof Chamfer (Z = 2.0 to 2.5) to prevent overhangs in FDM
        hull() {
            translate([0, 0, 2.0]) cylinder(d=7.5, h=0.01, center=true);
            translate([0, 0, 2.5]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
        }
        
        // Shaft Hole (Z = 2.5 to 3.1)
        translate([0, 0, 2.8]) cylinder(d=5.0 + GAP*2, h=0.6, center=true);
        
        // Top Indentation (Z = 3.1 to 3.2)
        hull() {
            translate([0, 0, 3.1]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
            translate([0, 0, 3.2]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
        }
    }
}"""
orig = orig.replace(pocket_old, pocket_new)

with open("generate_scad.py", "w") as f:
    f.write(orig)
