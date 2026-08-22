# Let's sketch out the key_button and button_pocket
btn_new = """module key_button(w, h, label) {
    // CYLINDRICAL PEG (Print-in-place)
    // Prints flat on the bed (Z=0) so it rests exactly on the tactile plunger in assembly.
    
    // 1. Bed adhesion & micro-support layer (Z=0 to Z=0.2)
    // We make a thin 0.2mm disc that connects to the faceplate wall.
    // The user wants "maybe just one thin line across the gap... like a brim"
    // Let's use a 0.2mm thick cylinder that bridges the gap.
    translate([0, 0, 0.1]) cylinder(d=5.0 + GAP*2, h=0.2, center=true);

    // 2. Base Peg (Z=0.2 to Z=1.0)
    translate([0, 0, 0.6]) cylinder(d=5.0, h=0.8, center=true);
    
    // 3. Flange (Z=1.0 to 1.6)
    // Prevents button from falling out the front.
    translate([0, 0, 1.3]) cylinder(d=6.5, h=0.6, center=true);
    
    // 4. Upper Shaft (Z=1.6 to Z=2.2)
    translate([0, 0, 1.9]) cylinder(d=5.0, h=0.6, center=true);
    
    // 5. Keycap (Z=2.2 to Z=3.5)
    // Note: The faceplate thickness pt=3.0. So keycap protrudes 0.5mm above faceplate.
    hull() {
        translate([0, 0, 2.21]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 2.85]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 3.5]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=0.8, h=0.01);
        }
    }
}
"""

pocket_new = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // 1. Bottom Shaft Hole (Z=-0.1 to Z=1.0)
        // Must clear the d=5.0 peg.
        translate([0, 0, 0.45]) cylinder(d=5.0 + GAP*2, h=1.1, center=true);
        
        // 2. Flange Cavity (Z=1.0 to Z=1.6)
        translate([0, 0, 1.3]) cylinder(d=6.5 + GAP*2, h=0.6, center=true);
        
        // 3. Roof Chamfer (Z=1.6 to Z=2.0)
        // Transitions from 6.5 back to 5.0 without overhangs.
        hull() {
            translate([0, 0, 1.6]) cylinder(d=6.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.0]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
        }
        
        // 4. Upper Shaft Hole (Z=2.0 to Z=2.5)
        translate([0, 0, 2.25]) cylinder(d=5.0 + GAP*2, h=0.5, center=true);
        
        // 5. Top Indentation (Z=2.5 to Z=3.1)
        // Clears the keycap.
        hull() {
            translate([0, 0, 2.5]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.6]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
            translate([0, 0, 3.1]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
        }
    }
}
"""
