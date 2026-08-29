import re

with open("generate_scad.py", "r") as f:
    code = f.read()

# Replace button_cavity
cav_pattern = re.compile(r'module button_cavity\(w, h\) \{.*?(?=module button_solid)', re.DOTALL)
cav_new = """module button_cavity(w, h) {
    cavity_w = w - 0.4;
    cavity_h = h - 0.4;
    z_faceplate = 2.5;
    
    top_w = (w > 15) ? w - 1.0 : w - 1.0;
    top_h = h - 1.0;
    hole_top_w = top_w + 0.4; 
    hole_top_h = top_h + 0.4;
    
    // Tapered hole
    hull() {
        translate([0, 0, 0.0]) squircle_centered(cavity_w, cavity_h, 0.01, 1.5);
        translate([0, 0, z_faceplate]) squircle_centered(hole_top_w, hole_top_h, 0.01, 1.5);
    }
    translate([0, 0, z_faceplate - 0.01]) squircle_centered(hole_top_w, hole_top_h, 10.0, 1.5);
}

"""
code = cav_pattern.sub(cav_new, code)

# Replace button_solid
sol_pattern = re.compile(r'module button_solid\(w, h, label="", label_left="", label_right="", label_alpha=""\) \{.*?(?=FP_CLR = 0\.1;)', re.DOTALL)
sol_new = """module button_solid(w, h, label="", label_left="", label_right="", label_alpha="") {
    z_spring_top = 0.4; // 2 FDM layers thick
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
            
            // Lattice Springs (North, South, East, West tabs connecting to ribs)
            intersection() {
                union() {
                    translate([-cavity_w/2, -0.6, 0]) cube([cavity_w, 1.2, z_spring_top]);
                    translate([-0.6, -cavity_h/2, 0]) cube([1.2, cavity_h, z_spring_top]);
                }
                squircle_centered(cavity_w + 0.2, cavity_h + 0.2, z_spring_top + 0.1, 1.5);
            }
        } 
        
        // Engraved Top Label
        if (label != "") {
            translate([0, 0, z_top - 0.4]) 
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label, top_w - 1.5, min(top_w*0.3, top_h*0.35));
                }
        }
        
        // Engraved Side Labels (Front, Left, Right)
        mid_z = z_faceplate + (z_top - z_faceplate)/2; 
        
        if (label_alpha != "") {
            translate([0, -top_h/2 + 0.4, mid_z])
                rotate([90, 0, 0])
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_alpha, top_w - 2.0, min(top_w*0.16, top_h*0.18));
                }
        }
        
        if (label_left != "") {
            translate([-top_w/2 + 0.4, 0, mid_z])
                rotate([0, -90, 0])
                rotate([0, 0, -90]) // Flipped 180 degrees
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_left, top_h - 2.0, min(top_w*0.13, top_h*0.16));
                }
        }
        
        if (label_right != "") {
            translate([top_w/2 - 0.4, 0, mid_z])
                rotate([0, 90, 0])
                rotate([0, 0, 90]) // Flipped 180 degrees
                linear_extrude(1.0) {
                    offset(delta=0.01) offset(delta=-0.01) sf_word(label_right, top_h - 2.0, min(top_w*0.13, top_h*0.16));
                }
        }
        
        // Pocket to clear 1.5mm tall tactile switch body (SKQGABE010 is 5.2x5.2mm)
        // 6.0 x 6.0mm pocket leaves 4 solid corner legs for the button to adhere to the bed
        translate([0, 0, 1.5/2 - 0.1])
            cube([6.0, 6.0, 1.5 + 0.2], center=true);
    }
}
"""
code = sol_pattern.sub(sol_new, code)

# Replace button_faceplate z_faceplate logic
fp_pattern = re.compile(r'// Front Solid Block \(Z = 1\.0 to 3\.5\)\n\s+translate\(\[1\.5 \+ FP_CLR, 0, 1\.0\]\) cube\(\[fp_w - 3\.0 - 2\*FP_CLR, \{split_y:\.3f\} - FP_CLR, 2\.5\]\);')
fp_new = """// Front Solid Block (Z = 1.0 to 2.5) -> Total thickness 2.5mm
            translate([1.5 + FP_CLR, 0, 1.0]) cube([fp_w - 3.0 - 2*FP_CLR, {split_y:.3f} - FP_CLR, 1.5]);"""
code = fp_pattern.sub(fp_new, code)

with open("generate_scad.py", "w") as f:
    f.write(code)

