import re

with open("generate_scad.py", "r") as f:
    code = f.read()

# Replace button_solid
sol_pattern = re.compile(r'module button_solid\(w, h, label="", label_left="", label_right="", label_alpha=""\) \{.*?(?=FP_CLR = 0\.1;)', re.DOTALL)
sol_new = """module button_solid(w, h, label="", label_left="", label_right="", label_alpha="") {
    arm_w = 0.5; // Spring width
    z_spring_top = 0.4; // 2 FDM layers thick
    z_faceplate = 2.5; 
    z_top = 5.6; 
    
    // Top exposed chiclet
    top_w = (w > 15) ? w - 1.0 : w - 1.0;
    top_h = h - 1.0;
    
    // Bottom narrow base for springs and switch
    base_w = 6.0;
    base_h = 6.0;
    
    cavity_w = w - 0.4;
    cavity_h = h - 0.4;
    
    render() difference() { 
        union() {
            // Narrow base (Z = 0.0 to 1.5)
            squircle_centered(base_w, base_h, 1.5, 1.0);
            
            // 45-degree chamfer expansion (Z = 1.5 to 2.9)
            // (top_w - base_w)/2 = (8.8 - 6.0)/2 = 1.4mm. So height needed is 1.4mm for 45 deg.
            translate([0, 0, 1.5])
                hull() {
                    squircle_centered(base_w, base_h, 0.01, 1.0);
                    translate([0, 0, 1.4]) squircle_centered(top_w, top_h, 0.01, 1.0);
                }
                
            // Straight shaft (Z = 2.9 to 5.6)
            translate([0, 0, 2.9])
                squircle_centered(top_w, top_h, z_top - 2.9, 1.0);
            
            // Spiral Springs connecting the narrow base to the cavity walls
            intersection() {
                for(i=[0:2]) rotate([0, 0, i*120]) linear_extrude(z_spring_top) spiral_arm(2.0, cavity_w/2 + 0.1, arm_w, 180);
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
        
        // Engraved Side Labels (Front, Left, Right) - on the straight shaft section
        mid_z = 2.9 + (z_top - 2.9)/2; 
        
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
        // 5.2 x 5.2mm pocket inside the 6.0x6.0 base leaves 0.4mm walls for the springs to attach!
        translate([0, 0, -0.01])
            cube([5.2, 5.2, 1.5 + 0.01], center=true); // Wait, center=true means it goes up to 1.5/2. I need it from 0 to 1.5!
    }
}
"""
code = sol_pattern.sub(sol_new, code)

# Fix the pocket subtraction to correctly go from Z=-0.1 to 1.5!
# If cube is 5.2x5.2x1.6 and translated to Z = 1.6/2 - 0.1, it spans Z=-0.1 to 1.5!
pocket_old = """translate([0, 0, -0.01])
            cube([5.2, 5.2, 1.5 + 0.01], center=true); // Wait, center=true means it goes up to 1.5/2. I need it from 0 to 1.5!"""
pocket_new = """translate([0, 0, 1.6/2 - 0.1])
            cube([5.2, 5.2, 1.6], center=true);"""
code = code.replace(pocket_old, pocket_new)

# Apply braces doubling!
pattern2 = re.compile(r'(module button_solid\(w, h, label="", label_left="", label_right="", label_alpha=""\) \{.*?cube\(\[5\.2, 5\.2, 1\.6\], center=true\);\n    \})', re.DOTALL)
def fix_braces(match):
    text = match.group(1)
    text = text.replace('{', '{{').replace('}', '}}')
    return text

code = pattern2.sub(fix_braces, code)

with open("generate_scad.py", "w") as f:
    f.write(code)

