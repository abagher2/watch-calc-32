import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. Fix key_button and button_pocket
btn_old = """module key_button(w, h, label) {
    // CYLINDRICAL PEG (Print-in-place)
    // Prints flat on the bed (Z=0) so it rests exactly on the tactile plunger.
    
    // 1. Massive Piston Base (Z=0.0 to Z=1.3)
    // d=7.0 base provides extreme stability on the bed.
    // Cannot fall out of faceplate since it is wider than the d=5.0 upper hole.
    // NOTE: Base stops at Z=1.3 to leave a 0.3mm vertical gap below the faceplate's Z=1.6 roof!
    translate([0, 0, 0.65]) cylinder(d=7.0, h=1.3, center=true);
    
    // 2. Extra Tall Upper Shaft (Z=1.3 to Z=4.5)
    // Extended so the keycap is fully above the faceplate (Z=3.0) with plenty of travel.
    translate([0, 0, 2.9]) cylinder(d=5.0, h=3.2, center=true);
    
    // 3. Keycap (Z=4.5 to Z=5.8)
    hull() {
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 5.8]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}

module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // 1. Piston Cavity (Z=-0.1 to Z=1.6)
        translate([0, 0, 0.75]) cylinder(d=7.0 + GAP*2, h=1.7, center=true);
        
        // 2. Roof Chamfer (Z=1.6 to Z=2.0)
        // Transitions from 7.0 back to 5.0 without overhangs.
        hull() {
            translate([0, 0, 1.6]) cylinder(d=7.0 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.0]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
        }
        
        // 3. Upper Shaft Hole (Z=2.0 to Z=3.1)
        // Punches cleanly through the top of the faceplate (Z=3.0).
        translate([0, 0, 2.55]) cylinder(d=5.0 + GAP*2, h=1.1, center=true);
    }
}"""

btn_new = """module key_button(w, h, label) {
    // CYLINDRICAL PEG (Print-in-place)
    // Prints flat on the bed (Z=0) so it rests exactly on the tactile plunger.
    
    // 1. Base Peg (Z=0.0 to Z=1.0)
    // Fits inside the faceplate's bottom retaining lip (d=5.6).
    translate([0, 0, 0.5]) cylinder(d=5.0, h=1.0, center=true);
    
    // 2. Retaining Flange (Z=1.3 to Z=1.7)
    // Wider than the bottom lip (d=7.0). Leaves 0.3mm vertical gap over the Z=1.0 lip to avoid fusing.
    translate([0, 0, 1.5]) cylinder(d=7.0, h=0.4, center=true);
    
    // 3. Extra Tall Upper Shaft (Z=1.7 to Z=4.5)
    // Extended so the keycap is fully above the faceplate (Z=3.0) with plenty of travel.
    translate([0, 0, 3.1]) cylinder(d=5.0, h=2.8, center=true);
    
    // 4. Keycap (Z=4.5 to Z=5.8)
    hull() {
        translate([0, 0, 4.51]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 5.15]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 5.8]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}

module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // 1. Bottom Retaining Lip Hole (Z=-0.1 to Z=1.0)
        // Traps the button from falling out the back.
        translate([0, 0, 0.45]) cylinder(d=5.6, h=1.1, center=true);
        
        // 2. Flange Cavity (Z=1.0 to Z=2.0)
        translate([0, 0, 1.5]) cylinder(d=7.6, h=1.0, center=true);
        
        // 3. Roof Chamfer (Z=2.0 to Z=2.4)
        hull() {
            translate([0, 0, 2.0]) cylinder(d=7.6, h=0.01, center=true);
            translate([0, 0, 2.4]) cylinder(d=5.6, h=0.01, center=true);
        }
        
        // 4. Upper Shaft Hole (Z=2.4 to Z=3.1)
        translate([0, 0, 2.75]) cylinder(d=5.6, h=0.7, center=true);
    }
}"""

orig = orig.replace(btn_old.replace("{", "{{").replace("}", "}}"), btn_new.replace("{", "{{").replace("}", "}}"))

# 2. Fix top_cap (remove railway grooves)
rail_old = """            // ── RAILWAY GROOVES ─────────────────────────────────────────────
            translate([-0.1, {GY:.1f}, ch - 0.1])   cube([{GCD:.1f} + 0.1, {GCW:.1f}, cap_t + 0.2]);
            translate([cw-{GCD:.1f}, {GY:.1f}, ch - 0.1]) cube([{GCD:.1f} + 0.1, {GCW:.1f}, cap_t + 0.2]);"""
orig = orig.replace(rail_old, "")

# 3. Fix dummy_pcb battery location
jst_old = """        // JST-PH 2-Pin SMD Right-Angle Connector (6x7.8x4.8mm)
        translate([{35.0 + pad_x:.3f}, {8.0 + pad_y:.3f}, 0]) """
jst_new = """        // JST-PH 2-Pin SMD Right-Angle Connector (6x7.8x4.8mm) - MOVED TO TOP
        translate([{35.0 + pad_x:.3f}, {140.0 + pad_y:.3f}, 0]) """
orig = orig.replace(jst_old, jst_new)

with open("generate_scad.py", "w") as f:
    f.write(orig)

