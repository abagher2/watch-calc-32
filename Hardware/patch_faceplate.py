import re

with open("generate_scad.py", "r") as f:
    content = f.read()

new_modules = """
module spiral_arm(r1, r2, w, a) {
    polygon([
        for (i=[0:15]) [ (r1 + (r2-r1)*(i/15)) * cos(a*(i/15)), (r1 + (r2-r1)*(i/15)) * sin(a*(i/15)) ],
        for (i=[15:-1:0]) [ (r1+w + (r2-r1)*(i/15)) * cos(a*(i/15)), (r1+w + (r2-r1)*(i/15)) * sin(a*(i/15)) ]
    ]);
}

module button_cavity(w, h) {
    spring_gap = 0.6;
    btn_gap = 0.25; 
    r_center = min(w,h)/2 - 1.2;
    
    // 1. Spring Air Cavity (Z=-0.1 to 0.7)
    translate([0, 0, -0.1]) cylinder(r=r_center + spring_gap, h=0.8, $fn=32);
    
    // 2. Button Body Air Cavity (Z=0.6 to 4.5)
    translate([0, 0, 0.6]) squircle_centered(w + 2*btn_gap, h + 2*btn_gap, 4.0, 1.5);
}

module button_solid(w, h, label="") {
    arm_w = 0.6;
    spring_gap = 0.6;
    r_center = min(w,h)/2 - 1.2;
    
    render() difference() {
        union() {
            // 1. Cruciform shaft (Z=0.0 to 0.6)
            linear_extrude(0.6) cross_profile(3.0, 3.0, 1.0, 1.2);
            
            // 2. Spiral arms (Z=0.0 to 1.0)
            for(i=[0:2]) rotate([0, 0, i*120]) translate([0,0,0]) linear_extrude(1.0) spiral_arm(r_center, r_center+spring_gap, arm_w, 90);
            
            // 3. Tapered support from cruciform to squircle (Z=0.6 to 1.5)
            hull() {
                translate([0, 0, 0.6]) linear_extrude(0.01) cross_profile(3.0, 3.0, 1.0, 1.2);
                translate([0, 0, 1.5]) squircle_centered(w, h, 0.01, 1.5);
            }
            
            // 4. Straight vertical section (inside the faceplate hole, Z=1.5 to Z=3.0)
            translate([0, 0, 1.5]) squircle_centered(w, h, 1.5, 1.5);
            
            // 5. Beveled top (HP-42S style, Z=3.0 to 4.2)
            hull() {
                translate([0, 0, 3.0]) squircle_centered(w, h, 0.01, 1.5);
                translate([0, -0.3, 4.2]) squircle_centered(w - 1.6, h - 1.6, 0.01, 1.0);
            }
        }
        
        // Label Text Cut (Z=3.8 to 4.3)
        if (len(label) > 0) {
            translate([0, -0.3, 4.2 - 0.4]) mirror([1,0,0]) linear_extrude(0.5) seg_word(label, w - 2.0);
        }
    }
}
"""

old_modules_regex = re.compile(r"module spiral_arm\(r1, r2, w, a\) \{.*?FP_CLR = 0\.1;\nmodule button_faceplate\(\) \{", re.DOTALL)
content = old_modules_regex.sub(new_modules + '\nFP_CLR = 0.1;\nmodule button_faceplate() {\n    union() {', content)

# Replace the single python loop with two loops
old_loop = """    for row in rows:
        for b in row:
            ox = fp_w - (pad_left + b['x'])
            oy = pad_bottom + b['y']
            lbl = b.get('label', '').replace('"', '\\\\"')
            label_arg = f', "{lbl}"' if lbl else ',""'
            unibody_scad += f"        translate([{ox:.3f}, {oy:.3f}, 0]) button_negative_cut({b['w']}, {b['h']}{label_arg});\\n"

    unibody_scad += f\"\"\"
    }
}"""

new_loop = """    for row in rows:
        for b in row:
            ox = fp_w - (pad_left + b['x'])
            oy = pad_bottom + b['y']
            unibody_scad += f"        translate([{ox:.3f}, {oy:.3f}, 0]) button_cavity({b['w']}, {b['h']});\\n"

    unibody_scad += "    }\\n"
    
    for row in rows:
        for b in row:
            ox = fp_w - (pad_left + b['x'])
            oy = pad_bottom + b['y']
            lbl = b.get('label', '').replace('"', '\\\\"')
            label_arg = f', "{lbl}"' if lbl else ',""'
            unibody_scad += f"        translate([{ox:.3f}, {oy:.3f}, 0]) button_solid({b['w']}, {b['h']}{label_arg});\\n"

    unibody_scad += f\"\"\"
    }}
}}"""

content = content.replace(old_loop, new_loop)

with open("generate_scad.py", "w") as f:
    f.write(content)

