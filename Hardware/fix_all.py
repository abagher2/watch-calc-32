import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# 1. Remove faceplate_tapered
orig = re.sub(r'    # ═══════════════════════════════════════════════════════\n    # TAPERED FACEPLATE \(Matched bezel height\)\n    # ═══════════════════════════════════════════════════════\n    faceplate_tapered = faceplate.*?with open\("designs/faceplate_tapered\.scad", "w"\) as f:\n        f\.write\(faceplate_tapered\)\n', '', orig, flags=re.DOTALL)

# 2. Update key_button and button_pocket
btn_old = """module key_button(w, h, label) {
    // Base Plunger (Z=0 to Z=0.4). Straight vertical walls for bed adhesion.
    translate([0, 0, 0.2]) cube([{pw}, {ph}, 0.4], center=true);
    
    // Bottom Chamfer (Z=0.4 to Z=1.4). Transitions from base to shaft.
    hull() {
        translate([0, 0, 0.41]) cube([{pw}, {ph}, 0.01], center=true);
        translate([0, 0, 1.39]) cube([{pw} - 2.0, {ph} - 2.0, 0.01], center=true);
    }
    
    // Shaft (Z=1.4 to Z=3.2). 
    translate([0, 0, 2.3]) cube([{pw} - 2.0, {ph} - 2.0, 1.8], center=true);
    
    // Top Keycap with 45-degree chamfered underside (Z=3.2 to Z=4.5). Height = 1.3mm
    hull() {
        // Bottom of keycap (matches shaft size to prevent overhangs!)
        translate([0, 0, 3.21]) cube([{pw} - 2.0, {ph} - 2.0, 0.01], center=true);
        // Middle of keycap (full size, 0.6mm up = ~45 degree chamfer!)
        translate([0, 0, 3.85]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        // Top of keycap (made wider and flatter so it is stable to print!)
        translate([0, 0, 4.5]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}"""

btn_new = """module key_button(w, h, label) {
    // CYLINDRICAL PISTON
    // Top of tactile switch is at Z=1.5 (since PCB is at Z=3.0 and switch is 1.5mm tall).
    // The piston extends down to Z=1.0 (0.5mm clearance below the switch top, to allow travel!)
    // Wait, if it extends to Z=1.0, it will crush the switch? No, it's printed at Z=1.0 with a gap!
    // We will just print it starting at Z=0.0 (flush with back of faceplate). It will touch the switch.
    // The tactile switch body is 0.6mm, so from Z=0 to Z=1.5 is the switch plunger.
    // So the piston must go from Z=1.5 to Z=3.2.
    // Actually, to make it print-in-place with powder, we can go Z=-0.5 to Z=3.2!
    // The user requested it to go "below the faceplate" (Z<0). 
    // We'll set the bottom of the plunger at Z = -1.0.
    translate([0, 0, -0.25]) cylinder(d=5.0, h=1.5, center=true);
    
    // Flange at Z = 0.5 to 1.5 (prevents falling out the front)
    hull() {
        translate([0, 0, 0.51]) cylinder(d=6.5, h=0.01, center=true);
        translate([0, 0, 1.49]) cylinder(d=5.5, h=0.01, center=true);
    }
    
    // Shaft from Z = 1.5 to 3.2
    translate([0, 0, 2.35]) cylinder(d=5.5, h=1.7, center=true);
    
    // Keycap from Z = 3.2 to 4.5
    hull() {
        translate([0, 0, 3.21]) cylinder(d=5.5, h=0.01, center=true);
        translate([0, 0, 3.85]) hull() {
            for(x=[-w/2+1.0, w/2-1.0], y=[-h/2+1.0, h/2-1.0])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
        translate([0, 0, 4.5]) hull() {
            for(x=[-w/2+1.5, w/2-1.5], y=[-h/2+1.5, h/2-1.5])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
        }
    }
}"""
orig = orig.replace(btn_old, btn_new)

pocket_old = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // Bottom Cavity (Z=-0.1 to Z=0.5). Straight walls for base.
        translate([0, 0, 0.2])
            cube([{pw} + GAP*2, {ph} + GAP*2, 0.6], center=true);

        // Bottom Chamfer Roof (Z=0.5 to Z=1.5). Eliminates horizontal overhang!
        hull() {
            translate([0, 0, 0.5]) cube([{pw} + GAP*2, {ph} + GAP*2, 0.01], center=true);
            translate([0, 0, 1.5]) cube([{pw} - 2.0 + GAP*2, {ph} - 2.0 + GAP*2, 0.01], center=true);
        }

        // Shelf Hole (Z=1.5 to Z=2.0). 
        translate([0, 0, 1.75])
            cube([{pw} - 2.0 + GAP*2, {ph} - 2.0 + GAP*2, 0.5], center=true);

        // Top Indentation with 45-degree chamfered bottom!
        hull() {
            translate([0, 0, 2.0]) cube([{pw} - 2.0 + GAP*2, {ph} - 2.0 + GAP*2, 0.01], center=true);
            translate([0, 0, 2.6]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
            translate([0, 0, 3.1]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
        }
    }
}"""
pocket_new = """module button_pocket(x, y, w, h) {
    translate([x, y, 0]) {
        // Bottom clearance for plunger (-1.0 to 0.5)
        translate([0, 0, -0.2]) cylinder(d=6.5 + GAP*2, h=1.6, center=true);
        
        // Flange roof (0.5 to 1.5)
        hull() {
            translate([0, 0, 0.5]) cylinder(d=6.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 1.5]) cylinder(d=5.5 + GAP*2, h=0.01, center=true);
        }
        
        // Shaft hole (1.5 to 2.3)
        translate([0, 0, 1.9]) cylinder(d=5.5 + GAP*2, h=0.8, center=true);
        
        // Top Indentation (2.3 to 3.1)
        hull() {
            translate([0, 0, 2.3]) cylinder(d=5.5 + GAP*2, h=0.01, center=true);
            translate([0, 0, 2.7]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
            translate([0, 0, 3.1]) cube([w + GAP*2, h + GAP*2, 0.01], center=true);
        }
    }
}"""
orig = orig.replace(pocket_old, pocket_new)

# 3. Modify chassis.scad template to use offset_x and offset_z
chassis_start = """chassis = f\"\"\"
// WatchCalc 32 Chassis — v8 (Closed Top, Bottom-Loading)
$fn = 24;
pt   = {pt:.3f};
cw   = {cw:.3f};
ch   = {fp_h + WALL:.3f};
D    = {D:.3f};
wall = {WALL:.3f};"""
chassis_start_new = """chassis = f\"\"\"
// WatchCalc 32 Chassis — v8 (Closed Top, Bottom-Loading)
$fn = 24;
pt   = {pt:.3f};
cw   = {cw:.3f};
ch   = {fp_h + WALL:.3f};
D    = {D:.3f};
wall = {WALL:.3f};
fp_w = {fp_w:.3f};
fp_h = {fp_h:.3f};
offset_x = (cw - fp_w) / 2;
offset_z = (ch - fp_h) / 2;"""
orig = orig.replace(chassis_start, chassis_start_new)

orig = orig.replace("translate([wall, -0.1, -0.1])\n            cube([cw - 2*wall, pt + TACTILE_H + {PCB_T} + 0.1, ch - wall + 0.1]);", 
                    "translate([offset_x, -0.1, offset_z - 0.1])\n            cube([fp_w, pt + TACTILE_H + {PCB_T} + 0.1, fp_h + 0.1]);")

orig = orig.replace("translate([wall + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, -0.1])\n            cube([cw - 2*wall - 11.0, D - wall - (pt + TACTILE_H + {PCB_T}) + 0.1, ch - wall + 0.2]);",
                    "translate([offset_x + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, offset_z - 0.1])\n            cube([fp_w - 11.0, D - wall - (pt + TACTILE_H + {PCB_T}) + 0.1, fp_h + 0.2]);")

orig = orig.replace("translate([wall + sx - 3.0, pt + {PCB_T}, sy - 3.0])",
                    "translate([offset_x + sx - 3.0, pt + {PCB_T}, offset_z + sy - 3.0])")
orig = orig.replace("translate([wall + sx, pt, sy])",
                    "translate([offset_x + sx, pt, offset_z + sy])")
orig = orig.replace("translate([wall + {sx:.3f}, D + 0.1, {sy:.3f}])",
                    "translate([offset_x + {sx:.3f}, D + 0.1, offset_z + {sy:.3f}])")

# Now apply tapered dimension override
tapered_orig = """    chassis_tapered = chassis
    # Pure Y Taper for hull"""
tapered_new = """    chassis_tapered = chassis.replace("cw   = {cw:.3f};", "cw   = 81.0;").replace("ch   = {fp_h + WALL:.3f};", "ch   = 152.0;")
    # Pure Y Taper for hull"""
orig = orig.replace(tapered_orig, tapered_new)


# 4. Modify TPU stretch cover to remove cutouts and set cover_t = 3.0 (which it already is in original? Actually let's just rewrite the whole tpu_stretch_cover string)
tpu_old_pattern = r'    tpu_stretch_cover = f"""\n// WatchCalc 32 TPU Stretch Cover.*?tpu_stretch_cover\(\);\n"""'
tpu_new = """    tpu_stretch_cover = f\"\"\"
// WatchCalc 32 TPU Stretch Folio Cover (Reversible)
$fn = 32;
cw   = {cw:.3f};
D    = {CHASSIS_D:.3f};
ch   = {fp_h + WALL:.3f};
wall = 1.800;
cover_t = 3.0;

module tpu_stretch_cover() {{
    difference() {{
        // Outer Body
        translate([-cover_t, -cover_t, -cover_t])
            cube([cw + 2*cover_t, D/2 + cover_t, ch + 2*cover_t]);
            
        // Inner Cavity for Chassis
        translate([0.1, 0, 0.1])
            cube([cw - 0.2, D + 1.0, ch - 0.2]);
            
        // Solid Front Face with deep internal cavity to clear keys
        // The keys extend up to 4.5mm from the faceplate (Z=0).
        // Since the faceplate is flush with the chassis rim, we need an internal 2.0mm cavity in the TPU.
        // The TPU is 3.0mm thick, leaving a 1.0mm solid outer shell.
        translate([wall, -2.0, wall])
            cube([cw - 2*wall, 2.1, ch - 2*wall]);
    }}
}}
tpu_stretch_cover();
\"\"\""""
orig = re.sub(tpu_old_pattern, tpu_new, orig, flags=re.DOTALL)

with open("generate_scad.py", "w") as f:
    f.write(orig)
