import re

with open("generate_scad.py", "r") as f:
    content = f.read()

fp_body_old = """module faceplate_body(style="STANDARD") {{
    cube([fp_w, fp_h, pt]);
    if (style == "TAPERED") {{
        // Raised classic HP-style lip around the display
        hull() {{
            translate([0, 105, pt]) cube([fp_w, 0.01, 0.01]);
            translate([0, fp_h, pt]) cube([fp_w, 0.01, 2.0]);
        }}
    }}
}}"""

fp_body_new = """module faceplate_body(style="STANDARD") {{
    cube([fp_w, fp_h, pt]);
    if (style == "TAPERED") {{
        // Raised classic HP-style bezel perfectly framing the display
        // Display center is at [disp_x, disp_y]
        // Display pocket at surface is POCKET_W = 52.0, POCKET_H = 27.0
        // We will make a bezel that surrounds this pocket and slopes down to the keypad plane.
        bz_w_base = 52.0 + 12.0; // 64 wide at base
        bz_h_base = 27.0 + 12.0; // 39 high at base
        bz_w_top  = 52.0 + 4.0;  // 56 wide at top
        bz_h_top  = 27.0 + 4.0;  // 31 high at top
        bz_z      = 1.5;         // 1.5mm raised
        
        hull() {{
            // Base of the bezel
            translate([{disp_x:.3f} - bz_w_base/2, {disp_y:.3f} - bz_h_base/2, pt])
                cube([bz_w_base, bz_h_base, 0.01]);
            // Top of the bezel
            translate([{disp_x:.3f} - bz_w_top/2, {disp_y:.3f} - bz_h_top/2, pt + bz_z])
                cube([bz_w_top, bz_h_top, 0.01]);
        }}
    }}
}}"""
content = content.replace(fp_body_old, fp_body_new)

with open("generate_scad.py", "w") as f:
    f.write(content)
print("Fixed faceplate bezel.")
