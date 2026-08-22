import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# Replace faceplate_body
fp_body_orig = """module faceplate_body() {{
    // Base plate — rim walls are on chassis now (DM32 style protection)
    // 0.3mm clearance on all edges allows smooth slide-in from display end
    // Sharp rectangular corners to sit flush inside the chassis cavity
    cube([fp_w, fp_h, pt]);
}}"""

fp_body_new = """module faceplate_body(style="STANDARD") {{
    cube([fp_w, fp_h, pt]);
    if (style == "TAPERED") {{
        // Raised classic HP-style lip around the display
        hull() {{
            translate([0, 105, pt]) cube([fp_w, 0.01, 0.01]);
            translate([0, fp_h, pt]) cube([fp_w, 0.01, 2.0]);
        }}
    }}
}}"""
content = content.replace(fp_body_orig, fp_body_new)

# Update faceplate() module to take style
fp_mod_orig = """module faceplate() {{
    difference() {{
        faceplate_body();"""
fp_mod_new = """module faceplate(style="STANDARD") {{
    difference() {{
        faceplate_body(style);"""
content = content.replace(fp_mod_orig, fp_mod_new)

# Update the display window cutter in faceplate()
disp_cut_orig = """            // Front of faceplate (Z=pt+0.1) flares outward to form a visible bevel (100% support-free)
            translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 0.1])
                cube([POCKET_W, POCKET_H, 0.01]);
        }}"""
disp_cut_new = """            // Front of faceplate (Z=pt+3.0 to clear any raised lips)
            translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 3.0])
                cube([POCKET_W, POCKET_H, 0.01]);
        }}"""
content = content.replace(disp_cut_orig, disp_cut_new)

# In the python logic, generate faceplate_tapered
fp_call_orig = """    faceplate = f\"\"\"
// WatchCalc 32 Faceplate — Print FACE-UP
// Back of faceplate is on Z=0 (build plate). Keys face up."""

# Find where the faceplate string ends
fp_end = content.find('faceplate();\n"""\n    with open("designs/faceplate_mjf.scad", "w") as f:')
if fp_end != -1:
    fp_start = content.find('    faceplate = f"""')
    fp_orig_str = content[fp_start:fp_end]
    
    fp_new_str = fp_orig_str.replace("faceplate();", "faceplate(\"STANDARD\");")
    
    # Create the function
    func_str = """
    def build_faceplate_scad(style="STANDARD"):
        code = f\"\"\"
// WatchCalc 32 Faceplate ({style})
$fn = 24;
fp_w = {fp_w:.3f};
fp_h = {fp_h:.3f};
cr   = {corner};
pt   = {pt};    
GAP  = {gap};        

""" + fp_orig_str.split('GAP  = {gap};        ')[1].replace("faceplate();", f'faceplate("{style}");') + """
\"\"\"
        return code

    faceplate = build_faceplate_scad("STANDARD")
    faceplate_tapered = build_faceplate_scad("TAPERED")
"""
    content = content[:fp_start] + func_str + content[fp_end:]
    
    write_fp_orig = 'with open("designs/faceplate_mjf.scad", "w") as f:\n        f.write(faceplate)'
    write_fp_new = """with open("designs/faceplate_mjf.scad", "w") as f:
        f.write(faceplate)
    with open("designs/faceplate_tapered.scad", "w") as f:
        f.write(faceplate_tapered)"""
    content = content.replace(write_fp_orig, write_fp_new)

# Add to tasks
tasks_fpt_orig = '("chassis_tapered","designs/chassis_tapered.scad","../scratch/stl/chassis_tapered.stl"),'
tasks_fpt_new = '("chassis_tapered","designs/chassis_tapered.scad","../scratch/stl/chassis_tapered.stl"),\n        ("faceplate_tapered","designs/faceplate_tapered.scad","../scratch/stl/faceplate_tapered.stl"),'
content = content.replace(tasks_fpt_orig, tasks_fpt_new)

with open("generate_scad.py", "w") as f:
    f.write(content)
print("Updated faceplate in generate_scad.py")
