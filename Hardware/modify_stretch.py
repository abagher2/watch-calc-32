import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# Replace build_sliding_cover_scad completely
sc_orig_start = content.find('    def build_sliding_cover_scad(style="STANDARD"):')
sc_orig_end = content.find('sliding_cover_tpu = build_sliding_cover_scad("TPU")') + len('sliding_cover_tpu = build_sliding_cover_scad("TPU")')

if sc_orig_start != -1 and sc_orig_end != -1:
    func_str = """    def build_cover_scad(style="STANDARD"):
        code = ""
        if style == "STANDARD":
            code = f\"\"\"
// WatchCalc 32 Sliding Cover (STANDARD)
$fn = 32;
cw   = {cw:.3f};
D    = {CHASSIS_D:.3f};
wall = {WALL:.3f};
cover_t = 2.0;
module sliding_cover() {{
    difference() {{
        union() {{
            translate([-wall, -cover_t, 0]) cube([cw + 2*wall, cover_t, {fp_h + WALL:.3f}]);
            translate([-wall, -cover_t, 0]) cube([wall, {GY:.1f} + GCW + cover_t, {fp_h + WALL:.3f}]);
            translate([cw, -cover_t, 0]) cube([wall, {GY:.1f} + GCW + cover_t, {fp_h + WALL:.3f}]);
            translate([-0.1, {GY:.1f} + 0.4, 0]) cube([GCD - 0.4, GCW - 0.8, {fp_h + WALL:.3f}]);
            translate([cw - GCD + 0.5, {GY:.1f} + 0.4, 0]) cube([GCD - 0.4, GCW - 0.8, {fp_h + WALL:.3f}]);
        }}
        translate([cw/2, -cover_t - 0.1, {fp_h + WALL:.3f}]) rotate([-90, 0, 0]) cylinder(r=15, h=cover_t + 2.0);
    }}
}}
sliding_cover();
\"\"\"
        elif style == "TPU_STRETCH":
            # iPhone style bumper case covering the front (Z=0 to Z=fp_h)
            # Wraps around the sides by `wall` thickness, with a small inward lip
            # Since chassis is cw x D, and Z is fp_h+WALL.
            # We want to cover Y=0 (front), and wrap around X=0, X=cw, Z=0, Z=ch
            code = f\"\"\"
// WatchCalc 32 TPU Stretch Cover (Bumper style)
$fn = 32;
cw   = {cw:.3f};
D    = {CHASSIS_D:.3f};
ch   = {fp_h + WALL:.3f};
wall = {WALL:.3f};
cover_t = 2.0; // Thickness of the TPU cover

module tpu_stretch_cover() {{
    difference() {{
        // Outer shell
        translate([-cover_t, -cover_t, -cover_t])
            cube([cw + 2*cover_t, D/2 + cover_t, ch + 2*cover_t]);
            
        // Inner cavity (exactly matches chassis outer dimensions, minus 0.1mm for TPU grip!)
        // TPU needs negative clearance to snap tight
        grip = 0.1;
        translate([grip, 0, grip])
            cube([cw - 2*grip, D + 1.0, ch - 2*grip]);
            
        // Screen Cutout
        ACTIVE_W = 49.0; ACTIVE_H = 24.0;
        translate([{disp_x:.3f} - ACTIVE_W/2, -cover_t-0.1, ch - 30 - ACTIVE_H/2])
            cube([ACTIVE_W, cover_t+0.2, ACTIVE_H]);
            
        // Keypad Cutout (Open area for keys)
        translate([cover_t, -cover_t-0.1, cover_t])
            cube([cw - 2*cover_t, cover_t+0.2, ch - 50.0]);
    }}
}}
tpu_stretch_cover();
\"\"\"
        return code

    sliding_cover = build_cover_scad("STANDARD")
    tpu_stretch_cover = build_cover_scad("TPU_STRETCH")"""
    content = content[:sc_orig_start] + func_str + content[sc_orig_end:]

# Fix writes
write_sc_orig = """with open("designs/sliding_cover.scad", "w") as f:
        f.write(sliding_cover)
    with open("designs/sliding_cover_tpu.scad", "w") as f:
        f.write(sliding_cover_tpu)"""
write_sc_new = """with open("designs/sliding_cover.scad", "w") as f:
        f.write(sliding_cover)
    with open("designs/tpu_stretch_cover.scad", "w") as f:
        f.write(tpu_stretch_cover)"""
content = content.replace(write_sc_orig, write_sc_new)

# Fix tasks list
tasks_sc_orig = '("sliding_cover_tpu", "designs/sliding_cover_tpu.scad", "../scratch/stl/sliding_cover_tpu.stl"),'
tasks_sc_new = '("tpu_stretch_cover", "designs/tpu_stretch_cover.scad", "../scratch/stl/tpu_stretch_cover.stl"),'
content = content.replace(tasks_sc_orig, tasks_sc_new)

with open("generate_scad.py", "w") as f:
    f.write(content)
print("Updated stretch cover in generate_scad.py")
