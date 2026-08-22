import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. key_button
btn_pattern = r'module key_button\(w, h, label\) \{.*?(?=\n\nmodule)'
btn_new = """module key_button(w, h, label) {{
    // CYLINDRICAL PISTON (Print-in-place)
    // Tactile switch top is at Z = 1.5. Button rests exactly on it.
    // Flange (Z = 1.5 to 2.0)
    translate([0, 0, 1.75]) cylinder(d=6.5, h=0.5, center=true);
    
    // Shaft (Z = 2.0 to 3.2)
    translate([0, 0, 2.6]) cylinder(d=5.0, h=1.2, center=true);
    
    // Keycap (Z = 3.2 to 4.5)
    hull() {{
        translate([0, 0, 3.21]) cylinder(d=5.0, h=0.01, center=true);
        translate([0, 0, 3.85]) hull() {{
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }}
        translate([0, 0, 4.5]) hull() {{
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }}
    }}
}}"""
orig = re.sub(btn_pattern, btn_new, orig, flags=re.DOTALL)

# 2. button_pocket
pocket_pattern = r'module button_pocket\(x, y, w, h\) \{.*?(?=\n\nmodule)'
pocket_new = """module button_pocket(x, y, w, h) {{
    translate([x, y, 0]) {{
        // Switch & Flange Cavity (Z = -0.1 to 2.0)
        // Must clear the 6.0x3.5mm tactile switch, plus provide travel room for the 6.5mm flange.
        // d=7.5 easily clears everything.
        translate([0, 0, 0.95]) cylinder(d=7.5, h=2.1, center=true);
        
        // Roof Chamfer (Z = 2.0 to 2.5) to prevent overhangs in FDM
        hull() {{
            translate([0, 0, 2.0]) cylinder(d=7.5, h=0.01, center=true);
            translate([0, 0, 2.5]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
        }}
        
        // Shaft Hole (Z = 2.5 to 3.1)
        translate([0, 0, 2.8]) cylinder(d=5.0 + GAP*2, h=0.6, center=true);
        
        // Top Indentation (Z = 3.1 to 3.2)
        hull() {{
            translate([0, 0, 3.1]) cylinder(d=5.0 + GAP*2, h=0.01, center=true);
            translate([0, 0, 3.2]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
        }}
    }}
}}"""
orig = re.sub(pocket_pattern, pocket_new, orig, flags=re.DOTALL)

# 3. chassis_tapered bug fix
t3_orig = r'        hull\(\) \{\n            translate\(\[0, 0, 0\]\) cube\(\[3, 3, ch\]\);\n            translate\(\[cw-3, 0, 0\]\) cube\(\[3, 3, ch\]\);\n            translate\(\[3, D-3, 0\]\) cylinder\(r=3, h=ch\);\n            translate\(\[cw-3, D-3, 0\]\) cylinder\(r=3, h=ch\);\n        \}'
t3_new = """        hull() {{
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            // Taper back shell down to 4.5mm thickness at the bottom (Z=0)
            translate([3, 4.5, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 4.5, 0]) cylinder(r=3, h=0.1);
            // Full depth at Z=90
            translate([3, D-3, 90.0]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, 90.0]) cylinder(r=3, h=0.1);
            // Full depth at top
            translate([3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
        }}"""
orig = re.sub(t3_orig, t3_new, orig, flags=re.DOTALL)

# 4. Remove faceplate_tapered
tapered_fp_pattern = r'    # ═══════════════════════════════════════════════════════\n    # TAPERED FACEPLATE \(Matched bezel height\)\n    # ═══════════════════════════════════════════════════════.*?faceplate_tapered\(\);\n"""'
orig = re.sub(tapered_fp_pattern, '', orig, flags=re.DOTALL)
orig = re.sub(r'    with open\("designs/faceplate_tapered.scad", "w"\) as f:\n        f\.write\(faceplate_tapered\)\n', '', orig, flags=re.DOTALL)
orig = re.sub(r'        \("faceplate_tapered",  "designs/faceplate_tapered.scad",  "\.\./scratch/stl/faceplate_tapered.stl"\),\n', '', orig)

# 5. TPU Stretch Cover as C-Shape (based on sliding_cover without rails)
tpu_pattern = r'    tpu_stretch_cover = f"""\n// WatchCalc 32 TPU Stretch Cover.*?tpu_stretch_cover\(\);\n"""'
tpu_new = """    tpu_stretch_cover = f\"\"\"
// WatchCalc 32 TPU Stretch Cover (C-Shape Bumper)
// Wraps around back and sides, leaving front open.
$fn = 32;
cw       = {cw:.3f};   // chassis width
ch       = {fp_h:.3f}; // chassis height
D        = {CHASSIS_D:.3f};   // chassis depth
cov_wall = 2.0;
cov_clear= 0.4;
cov_h    = {fp_h + WALL + cap_t_val + 2*2.0 + 2*0.4:.3f};  // total height
cov_z_start = {-(cap_t_val + 2.0 + 0.4):.3f};
cov_y_start = {-(plate_t + 0.4):.3f};
cov_y_len   = {CHASSIS_D + plate_t + 2*0.4:.3f};

{top_fillet_cutter_scad()}

module tpu_stretch_cover() {{
    difference() {{
        // Outer body
        r = 3.0;
        hull() {{
            translate([-(cov_wall + cov_clear) + r, cov_y_start + r, cov_z_start])
                cylinder(r=r, h=cov_h, $fn=24);
            translate([cw + cov_clear + cov_wall - r, cov_y_start + r, cov_z_start])
                cylinder(r=r, h=cov_h, $fn=24);
            translate([-(cov_wall + cov_clear) + r, cov_y_start + cov_y_len - r, cov_z_start])
                cylinder(r=r, h=cov_h, $fn=24);
            translate([cw + cov_clear + cov_wall - r, cov_y_start + cov_y_len - r, cov_z_start])
                cylinder(r=r, h=cov_h, $fn=24);
        }}
        
        // Hollow inner space for chassis
        translate([-cov_clear, cov_y_start - 0.1, cov_z_start + cov_wall])
            cube([cw + 2*cov_clear, cov_y_len - cov_wall + 0.2, cov_h + 0.1]);
            
        // Top Corner Fillet
        translate([-(cov_wall + cov_clear), cov_y_start, cov_z_start])
            top_fillet_cutter(cw + 2 * (cov_wall + cov_clear), cov_y_len, cov_h, 3.0);
    }}
}}
tpu_stretch_cover();
\"\"\""""
orig = re.sub(tpu_pattern, tpu_new, orig, flags=re.DOTALL)

with open("generate_scad.py", "w") as f:
    f.write(orig)
