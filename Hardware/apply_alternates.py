import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. Update tasks array at the bottom
tasks_orig = """    tasks = [
        ("faceplate_mjf",  "designs/faceplate_mjf.scad",  "../scratch/stl/faceplate_mjf.stl"),
        ("faceplate_fdm",  "designs/faceplate_fdm.scad",  "../scratch/stl/faceplate_fdm.stl"),
        ("chassis",        "designs/chassis.scad",        "../scratch/stl/chassis.stl"),
        ("top_cap",        "designs/top_cap.scad",        "../scratch/stl/top_cap.stl"),
        ("sliding_cover",  "designs/sliding_cover.scad",  "../scratch/stl/sliding_cover.stl"),
        ("buttons",        "designs/buttons.scad",        "../scratch/stl/buttons.stl"),
        ("dummy_pcb",      "designs/dummy_pcb.scad",      "../scratch/stl/dummy_pcb.stl"),
    ]"""
tasks_new = """    tasks = [
        ("faceplate_mjf",  "designs/faceplate_mjf.scad",  "../scratch/stl/faceplate_mjf.stl"),
        ("faceplate_fdm",  "designs/faceplate_fdm.scad",  "../scratch/stl/faceplate_fdm.stl"),
        ("faceplate_tapered","designs/faceplate_tapered.scad","../scratch/stl/faceplate_tapered.stl"),
        ("chassis",        "designs/chassis.scad",        "../scratch/stl/chassis.stl"),
        ("chassis_tpu",    "designs/chassis_tpu.scad",    "../scratch/stl/chassis_tpu.stl"),
        ("chassis_tapered","designs/chassis_tapered.scad","../scratch/stl/chassis_tapered.stl"),
        ("top_cap",        "designs/top_cap.scad",        "../scratch/stl/top_cap.stl"),
        ("sliding_cover",  "designs/sliding_cover.scad",  "../scratch/stl/sliding_cover.stl"),
        ("tpu_stretch_cover","designs/tpu_stretch_cover.scad","../scratch/stl/tpu_stretch_cover.stl"),
        ("buttons",        "designs/buttons.scad",        "../scratch/stl/buttons.stl"),
        ("dummy_pcb",      "designs/dummy_pcb.scad",      "../scratch/stl/dummy_pcb.stl"),
    ]"""
orig = orig.replace(tasks_orig, tasks_new)

# 2. Add Faceplate variants
fp_start = orig.find('    faceplate_mjf = faceplate')
fp_end = orig.find('    with open("designs/faceplate_mjf.scad", "w") as f:')
fp_code = orig[fp_start:fp_end]

fp_new = fp_code + """
    # --- FACEPLATE TAPERED ---
    # Replace faceplate_body with bezel
    fp_tapered = faceplate
    
    fp_body_orig = "cube([fp_w, fp_h, pt]);"
    fp_body_new = \"\"\"cube([fp_w, fp_h, pt]);
        bz_w_base = 64.0;
        bz_h_base = 39.0;
        bz_w_top  = 56.0;
        bz_h_top  = 31.0;
        bz_z      = 1.5;
        hull() {
            translate([fp_w/2 - bz_w_base/2, 123.0 - bz_h_base/2, pt])
                cube([bz_w_base, bz_h_base, 0.01]);
            translate([fp_w/2 - bz_w_top/2, 123.0 - bz_h_top/2, pt + bz_z])
                cube([bz_w_top, bz_h_top, 0.01]);
        }\"\"\"
    fp_tapered = fp_tapered.replace(fp_body_orig, fp_body_new)
    
    # Extend display window to clear bezel
    disp_cut_orig = "translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 3.0])"
    disp_cut_new = "translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 5.0])"
    # Wait, the original in the file is pt + 0.1 ! Let's replace that.
    disp_cut_orig2 = "translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 0.1])"
    fp_tapered = fp_tapered.replace(disp_cut_orig2, disp_cut_new)
    
    faceplate_tapered = fp_tapered
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            btn_str = f"    translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \\"{b['label']}\\");\\n"
            faceplate_tapered += btn_str
    faceplate_tapered += "}\\n"
"""
orig = orig.replace(fp_code, fp_new)

fp_write = """    with open("designs/faceplate_fdm.scad", "w") as f:
        f.write(faceplate_fdm)"""
fp_write_new = """    with open("designs/faceplate_fdm.scad", "w") as f:
        f.write(faceplate_fdm)
        
    with open("designs/faceplate_tapered.scad", "w") as f:
        f.write(faceplate_tapered)"""
orig = orig.replace(fp_write, fp_write_new)


# 3. Add Chassis variants
ch_start = orig.find('    with open("designs/chassis.scad", "w") as f:')
ch_new = """
    # --- CHASSIS TPU ---
    chassis_tpu = chassis
    # Remove railway grooves
    chassis_tpu = chassis_tpu.replace("railway_grooves();", "// railway_grooves();")
    # Add bumps
    chassis_tpu = chassis_tpu.replace("chassis();", \"\"\"
        translate([15, {D:.3f}, 10]) sphere(r=2.5);
        translate([{cw:.3f}-15, {D:.3f}, 10]) sphere(r=2.5);
        translate([15, {D:.3f}, {fp_h + WALL:.3f}-10]) sphere(r=2.5);
        translate([{cw:.3f}-15, {D:.3f}, {fp_h + WALL:.3f}-10]) sphere(r=2.5);
    }}
}}
chassis();
\"\"\")

    # --- CHASSIS TAPERED ---
    chassis_tapered = chassis
    # Pure Y Taper for hull
    hull_orig = \"\"\"hull() {
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }\"\"\"
    hull_new = \"\"\"hull() {
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            // Tapered Y to 5.0 (center 2.0 with r 3.0)
            translate([3, 2.0, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 2.0, 0]) cylinder(r=3, h=0.1);
            // Full depth at Z=90
            translate([3, D-3, 90.0]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, 90.0]) cylinder(r=3, h=0.1);
            // Full depth at Z=ch
            translate([3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
        }\"\"\"
    chassis_tapered = chassis_tapered.replace(hull_orig, hull_new)
    
    # Tier 3 depth restriction
    t3_orig = \"\"\"translate([wall + 5.5, pt + {PCB_T} - 0.1, -0.1])
            cube([cw - 2*wall - 11.0, D - wall - pt - {PCB_T} + 0.1, ch - wall + 0.2]);\"\"\"
    t3_new = \"\"\"translate([wall + 5.5, pt + {PCB_T} - 0.1, 90.0])
            cube([cw - 2*wall - 11.0, D - wall - pt - {PCB_T} + 0.1, ch - 90.0]);\"\"\"
    chassis_tapered = chassis_tapered.replace(t3_orig, t3_new)

    with open("designs/chassis.scad", "w") as f:
"""
orig = orig.replace('    with open("designs/chassis.scad", "w") as f:', ch_new)

ch_write = """    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)"""
ch_write_new = """    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)
        
    with open("designs/chassis_tpu.scad", "w") as f:
        f.write(chassis_tpu)
        
    with open("designs/chassis_tapered.scad", "w") as f:
        f.write(chassis_tapered)"""
orig = orig.replace(ch_write, ch_write_new)


# 4. Add TPU Stretch Cover
sc_write = """    with open("designs/sliding_cover.scad", "w") as f:
        f.write(cover)"""
        
sc_new = """
    # --- TPU STRETCH COVER ---
    tpu_stretch_cover = f\"\"\"
// WatchCalc 32 TPU Stretch Cover (Bumper style)
$fn = 32;
cw   = {cw:.3f};
D    = {CHASSIS_D:.3f};
ch   = {fp_h + WALL:.3f};
wall = {WALL:.3f};
cover_t = 2.0;

module tpu_stretch_cover() {{
    difference() {{
        translate([-cover_t, -cover_t, -cover_t])
            cube([cw + 2*cover_t, D/2 + cover_t, ch + 2*cover_t]);
        translate([0.1, 0, 0.1])
            cube([cw - 0.2, D + 1.0, ch - 0.2]);
            
        ACTIVE_W = 49.0; ACTIVE_H = 24.0;
        translate([{disp_x:.3f} - ACTIVE_W/2, -cover_t-0.1, ch - 30 - ACTIVE_H/2])
            cube([ACTIVE_W, cover_t+0.2, ACTIVE_H]);
            
        translate([cover_t, -cover_t-0.1, cover_t])
            cube([cw - 2*cover_t, cover_t+0.2, ch - 50.0]);
    }}
}}
tpu_stretch_cover();
\"\"\"
"""
orig = orig.replace(sc_write, sc_new + """    with open("designs/sliding_cover.scad", "w") as f:
        f.write(cover)
        
    with open("designs/tpu_stretch_cover.scad", "w") as f:
        f.write(tpu_stretch_cover)""")

with open("generate_scad.py", "w") as f:
    f.write(orig)
