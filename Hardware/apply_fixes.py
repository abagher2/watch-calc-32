import re
import sys

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. Update key_button and button_pocket
btn_old = """module key_button(w, h, label) {
    // Base Plunger (Z=0 to Z=0.4). Straight vertical walls for bed adhesion.
    translate([0, 0, 0.2]) cube([{pw}, {ph}, 0.4], center=true);
    
    // Bottom Chamfer (Z=0.4 to Z=1.4). Transitions from base to shaft.
    hull() {
        translate([0, 0, 0.41]) cube([{pw}, {ph}, 0.01], center=true);
        translate([0, 0, 1.39]) cube([{pw} - 2.0, {ph} - 2.0, 0.01], center=true);
    }
    
    // Shaft (Z=1.4 to Z=3.2). 
    translate([0, 0, 2.3]) cube([{pw} - 2.0, {ph} - 2.0, 1.8], center=true);
    
    // Top Keycap with 45-degree chamfered underside (Z=3.2 to Z=4.5). Height = 1.3mm
    hull() {
        // Bottom of keycap (matches shaft size to prevent overhangs!)
        translate([0, 0, 3.21]) cube([{pw} - 2.0, {ph} - 2.0, 0.01], center=true);
        // Middle of keycap (full size, 0.6mm up = ~45 degree chamfer!)
        translate([0, 0, 3.85]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        // Top of keycap (made wider and flatter so it is stable to print!)
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
if btn_old not in orig:
    print("Failed to find btn_old")
orig = orig.replace(btn_old, btn_new)

pocket_old = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // Bottom Cavity (Z=-0.1 to Z=0.5). Straight walls for base.
        translate([0, 0, 0.2])
            cube([{pw} + GAP*2, {ph} + GAP*2, 0.6], center=true);

        // Bottom Chamfer Roof (Z=0.5 to Z=1.5). Eliminates horizontal overhang!
        hull() {
            translate([0, 0, 0.5]) cube([{pw} + GAP*2, {ph} + GAP*2, 0.01], center=true);
            translate([0, 0, 1.5]) cube([{pw} - 2.0 + GAP*2, {ph} - 2.0 + GAP*2, 0.01], center=true);
        }

        // Shelf Hole (Z=1.5 to Z=2.0). 
        translate([0, 0, 1.75])
            cube([{pw} - 2.0 + GAP*2, {ph} - 2.0 + GAP*2, 0.5], center=true);

        // Top Indentation with 45-degree chamfered bottom!
        hull() {
            translate([0, 0, 2.0]) cube([{pw} - 2.0 + GAP*2, {ph} - 2.0 + GAP*2, 0.01], center=true);
            translate([0, 0, 2.6]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
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
if pocket_old not in orig:
    print("Failed to find pocket_old")
orig = orig.replace(pocket_old, pocket_new)

# 2. Fix the t3_orig in chassis_tapered
t3_orig = """    # Pure Y Taper for hull
    hull_orig = \"\"\"hull() {
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }\"\"\""""
# But wait, does t3_orig actually match what's in chassis_tapered? Let's check generate_scad.py directly!
