import re

with open("generate_scad.py", "r") as f:
    code = f.read()

# Fix button_cavity
cavity_old = """module button_cavity(w, h) {
    cavity_w = w - 0.8;
    cavity_h = h - 0.8;
    z_faceplate = 3.5;
    
    top_w = (w > 15) ? w - 1.5 : min(w-1.5, 7.8);
    top_h = min(h-1.5, 6.0);
    hole_top_w = top_w + 0.6; 
    hole_top_h = top_h + 0.6;"""

cavity_new = """module button_cavity(w, h) {
    cavity_w = w - 0.4; // 9.4mm for w=9.8
    cavity_h = h - 0.4;
    z_faceplate = 2.5; // Shorter faceplate
    
    top_w = (w > 15) ? w - 1.0 : w - 1.0; // 8.8mm for w=9.8
    top_h = h - 1.0; // 8.6mm for h=9.6
    hole_top_w = top_w + 0.4; // 9.2mm (0.2mm clearance)
    hole_top_h = top_h + 0.4;"""

if cavity_old in code:
    code = code.replace(cavity_old, cavity_new)
else:
    print("Could not find cavity_old")

# Fix button_solid
solid_old = """module button_solid(w, h, label="", label_left="", label_right="", label_alpha="") {
    arm_w = 0.6;
    z_spring_top = 0.8; // slightly thinner springs for more flex
    z_faceplate = 3.5; 
    z_top = 5.6; 
    
    top_w = (w > 15) ? w - 1.5 : min(w-1.5, 7.8);
    top_h = min(h-1.5, 6.0);
    
    cavity_w = w - 0.8;
    cavity_h = h - 0.8;
    
    render() difference() { 
        union() {
            // Straight shaft button
            squircle_centered(top_w, top_h, z_top, 1.0);
            
            // Suspension Springs attached to the base of the shaft
            intersection() {
                for(i=[0:2]) rotate([0, 0, i*120]) linear_extrude(z_spring_top) spiral_arm(1.5, cavity_w/2 - 0.3, arm_w, 180);
                squircle_centered(cavity_w - 0.4, cavity_h - 0.4, z_spring_top + 0.1, 1.5);
            }
        } 
        
        // Engraved Top Label"""

solid_new = """module button_solid(w, h, label="", label_left="", label_right="", label_alpha="") {
    z_spring_top = 0.4; // 2 layers thick for lattice springs
    z_faceplate = 2.5; 
    z_top = 5.6; 
    
    top_w = (w > 15) ? w - 1.0 : w - 1.0;
    top_h = h - 1.0;
    
    cavity_w = w - 0.4;
    cavity_h = h - 0.4;
    
    render() difference() { 
        union() {
            // Straight shaft button
            squircle_centered(top_w, top_h, z_top, 1.0);
            
            // Lattice Springs connecting the button to the ribs (N, S, E, W)
            intersection() {
                union() {
                    translate([-cavity_w/2, -1.0, 0]) cube([cavity_w, 2.0, z_spring_top]); // X tabs
                    translate([-1.0, -cavity_h/2, 0]) cube([2.0, cavity_h, z_spring_top]); // Y tabs
                }
                squircle_centered(cavity_w + 0.2, cavity_h + 0.2, z_spring_top + 0.1, 1.5);
            }
        } 
        
        // Pocket to clear 1.5mm tall tactile switch body (SKQGABE010 is 5.2x5.2mm)
        // 6.0 x 6.0 pocket leaves 4 solid corner legs for the button to adhere to the bed
        translate([0, 0, 1.5/2 - 0.1])
            cube([6.0, 6.0, 1.5 + 0.2], center=true);
            
        // Engraved Top Label"""

if solid_old in code:
    code = code.replace(solid_old, solid_new)
else:
    print("Could not find solid_old")

# Replace left/right side label rotation and the old pocket
labels_old = """        if (label_left != "") {
            translate([-top_w/2 + 0.4, 0, mid_z])
                rotate([0, -90, 0])
                rotate([0, 0, 90])
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_left, top_h - 2.0, min(top_w*0.13, top_h*0.16));
                }
        }
        
        if (label_right != "") {
            translate([top_w/2 - 0.4, 0, mid_z])
                rotate([0, 90, 0])
                rotate([0, 0, -90])
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_right, top_h - 2.0, min(top_w*0.13, top_h*0.16));
                }
        }
        
        // Pocket to clear 1.5mm tall tactile switch body (SKQGABE010 is 5.2x5.2mm)
        // Cuts through Y completely to avoid unprintable thin walls, leaving sturdy 1.1mm X-legs
        translate([0, 0, 1.5/2 - 0.1])
            cube([5.6, 10.0, 1.5 + 0.2], center=true);"""

labels_new = """        if (label_left != "") {
            translate([-top_w/2 + 0.4, 0, mid_z])
                rotate([0, -90, 0])
                rotate([0, 0, -90]) // Flipped 180 deg
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_left, top_h - 2.0, min(top_w*0.13, top_h*0.16));
                }
        }
        
        if (label_right != "") {
            translate([top_w/2 - 0.4, 0, mid_z])
                rotate([0, 90, 0])
                rotate([0, 0, 90]) // Flipped 180 deg
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_right, top_h - 2.0, min(top_w*0.13, top_h*0.16));
                }
        }"""

if labels_old in code:
    code = code.replace(labels_old, labels_new)
else:
    print("Could not find labels_old")

with open("generate_scad.py", "w") as f:
    f.write(code)

