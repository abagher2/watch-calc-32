import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# Replace chassis string definition with a function
# Find where chassis starts
start_idx = content.find('    chassis = f"""')
end_idx = content.find('chassis();\n"""\n    with open("designs/chassis.scad", "w") as f:')

if start_idx != -1 and end_idx != -1:
    chassis_orig = content[start_idx:end_idx]
    
    # We will replace it with a function
    func_str = """
    def build_chassis_scad(style="STANDARD"):
        # TPU Settings
        extra_gap = 0.6 if style == "TPU" else 0.0
        s_GCW = GCW + extra_gap
        s_GCD = GCD + extra_gap
        
        # Tapered Settings
        hull_code = ""
        if style == "TAPERED":
            # Tapered: Thin at Z=0, thick at Z=ch.
            # Also chamfered back corners (boat hull).
            # We keep front face at cw x ch.
            hull_code = f\"\"\"
            hull() {{
                // Front face (Y=0)
                translate([0, 0, 0]) cube([3, 3, ch]);
                translate([{cw}-3, 0, 0]) cube([3, 3, ch]);
                // Back face at bottom (Z=0) - thinner Y and X
                translate([8, {D}-5.5, 0]) cylinder(r=3, h=0.1);
                translate([{cw}-8, {D}-5.5, 0]) cylinder(r=3, h=0.1);
                // Back face at top (Z=ch) - full Y and X
                translate([4, {D}-3, ch-0.1]) cylinder(r=3, h=0.1);
                translate([{cw}-4, {D}-3, ch-0.1]) cylinder(r=3, h=0.1);
            }}\"\"\"
        else:
            # Standard Hull
            hull_code = f\"\"\"
            hull() {{
                translate([0, 0, 0]) cube([3, 3, ch]);
                translate([{cw}-3, 0, 0]) cube([3, 3, ch]);
                translate([3, {D}-3, 0]) cylinder(r=3, h=ch);
                translate([{cw}-3, {D}-3, 0]) cylinder(r=3, h=ch);
            }}\"\"\"

        tpu_feet = ""
        if style == "TPU":
            tpu_feet = f\"\"\"
            // Integrated TPU Bumps
            translate([15, {D}, 10]) sphere(r=2.5);
            translate([{cw}-15, {D}, 10]) sphere(r=2.5);
            translate([15, {D}, ch-10]) sphere(r=2.5);
            translate([{cw}-15, {D}, ch-10]) sphere(r=2.5);
            \"\"\"

        boss_h_extra = 0.2 if style == "TPU" else 0.0

        boss_code = ""
        for sx in [7.0, cw - 2*WALL - 7.0]:
            for sy in [ch - WALL - 5.0]:
                if style == "TAPERED":
                    # Extend bosses backward to reach sloped wall
                    boss_code += f\"\"\"
                    translate([{WALL + sx - 3.0}, {pt + PCB_T}, {sy - 3.0}])
                        cube([6.0, {D - WALL - pt - PCB_T + 0.1}, 6.0]);
                    translate([{WALL + sx}, {pt}, {sy}]) rotate([-90, 0, 0])
                        cylinder(d=3.0, h={PCB_T + 0.1 + boss_h_extra});
                    \"\"\"
                else:
                    boss_code += f\"\"\"
                    translate([{WALL + sx - 3.0}, {pt + PCB_T}, {sy - 3.0}])
                        cube([6.0, {D - WALL - pt - PCB_T + 0.1}, 6.0]);
                    translate([{WALL + sx}, {pt}, {sy}]) rotate([-90, 0, 0])
                        cylinder(d=3.0, h={PCB_T + 0.1 + boss_h_extra});
                    \"\"\"

        screw_holes = ""
        for sx, sy in chassis_screws:
            screw_holes += f"        translate([{WALL + sx:.3f}, {D + 0.1}, {sy:.3f}]) rotate([90, 0, 0]) cylinder(d=2.2, h={D + 2.0});\\n"
            if style != "TPU":
                # Recess for standard
                screw_holes += f"        translate([{WALL + sx:.3f}, {D + 0.1}, {sy:.3f}]) rotate([90, 0, 0]) cylinder(d=4.0, h=0.8); // Head recess\\n"
            else:
                # Flat for washer in TPU
                screw_holes += f"        translate([{WALL + sx:.3f}, {D + 0.1}, {sy:.3f}]) rotate([90, 0, 0]) cylinder(d=5.0, h=0.01); // Washer flat\\n"

        code = f\"\"\"
// WatchCalc 32 Chassis ({style})
$fn = 24;
pt   = {pt:.3f};
cw   = {cw:.3f};
ch   = {fp_h + WALL:.3f};
D    = {D:.3f};
wall = {WALL:.3f};

{top_fillet_cutter_scad()}

module chassis_shell() {{
    difference() {{
        {hull_code}
        
        translate([wall, -0.1, -0.1])
            cube([cw - 2*wall, pt + 0.1, ch - wall + 0.1]);
            
        translate([wall + 2.5, pt - 0.1, -0.1])
            cube([cw - 2*wall - 5.0, {PCB_T} + 0.2, ch - wall + 0.1]);
            
        // Tier 3: Back Components Clearance (Deepest)
        translate([wall + 5.5, pt + {PCB_T} - 0.1, -0.1])
            cube([cw - 2*wall - 11.0, D - wall - pt - {PCB_T} + 0.1, ch - wall + 0.2]);
    }}
}}

module screw_bosses() {{
    {boss_code}
}}
module railway_grooves() {{
    translate([-0.1, {GY:.1f}, -0.1])        cube([{s_GCD}+0.1, {s_GCW}, ch+0.2]);
    translate([cw-{s_GCD}, {GY:.1f}, -0.1])      cube([{s_GCD}+0.1, {s_GCW}, ch+0.2]);
    translate([-0.1, {GY + s_GCW/2}, 5.0]) rotate([0, 90, 0]) cylinder(d={s_GCW}, h={s_GCD}+0.5, $fn=16);
    translate([cw-{s_GCD}-0.4, {GY + s_GCW/2}, 5.0]) rotate([0, 90, 0]) cylinder(d={s_GCW}, h={s_GCD}+0.5, $fn=16);
}}
module chassis() {{
    union() {{
        difference() {{
            union() {{
                chassis_shell();
                screw_bosses();
            }}
            
            // ── CHASSIS SCREW CLEARANCE HOLES ────────────────────────────────
{screw_holes}
            
            // ── RAILWAY GROOVES ──────────────────────────────────────────────
            railway_grooves();
            
            // ── TOP CORNER FILLET ─────────────────────────────────────────────
            translate([0, 0, 0]) top_fillet_cutter(cw, D, ch, 3.0);
        }}
        {tpu_feet}
    }}
}}
chassis();
\"\"\"
        return code

    chassis = build_chassis_scad("STANDARD")
    chassis_tpu = build_chassis_scad("TPU")
    chassis_tapered = build_chassis_scad("TAPERED")
"""
    content = content[:start_idx] + func_str + content[end_idx:]
    
    # Update the writes
    write_orig = 'with open("designs/chassis.scad", "w") as f:\n        f.write(chassis)'
    write_new = """with open("designs/chassis.scad", "w") as f:
        f.write(chassis)
    with open("designs/chassis_tpu.scad", "w") as f:
        f.write(chassis_tpu)
    with open("designs/chassis_tapered.scad", "w") as f:
        f.write(chassis_tapered)"""
    content = content.replace(write_orig, write_new)

# Sliding Cover TPU variant
# Find sliding cover logic
sc_start = content.find('    sliding_cover = f"""')
sc_end = content.find('sliding_cover();\n"""\n    with open("designs/sliding_cover.scad", "w") as f:')

if sc_start != -1 and sc_end != -1:
    func_str_sc = """
    def build_sliding_cover_scad(style="STANDARD"):
        extra_gap = 0.6 if style == "TPU" else 0.0
        s_GCW = GCW + extra_gap
        s_GCD = GCD + extra_gap
        s_GD  = 0.4 # Gap for sliding cover rail
        
        code = f\"\"\"
// WatchCalc 32 Sliding Cover ({style})
$fn = 32;
cw   = {cw:.3f};
D    = {CHASSIS_D:.3f};
wall = {WALL:.3f};
cover_t = 2.0;

module sliding_cover() {{
    difference() {{
        union() {{
            // Main front plate (covers faceplate)
            translate([-wall, -cover_t, 0])
                cube([cw + 2*wall, cover_t, {fp_h + WALL:.3f}]);
                
            // Side wrap-around walls
            // Left wall
            translate([-wall, -cover_t, 0])
                cube([wall, {GY:.1f} + {s_GCW} + cover_t, {fp_h + WALL:.3f}]);
            // Right wall
            translate([cw, -cover_t, 0])
                cube([wall, {GY:.1f} + {s_GCW} + cover_t, {fp_h + WALL:.3f}]);
                
            // Rails that lock into the chassis grooves
            translate([-0.1, {GY:.1f} + {s_GD}, 0])
                cube([{s_GCD} - {s_GD}, {s_GCW} - 2*{s_GD}, {fp_h + WALL:.3f}]);
            translate([cw - {s_GCD} + {s_GD} + 0.1, {GY:.1f} + {s_GD}, 0])
                cube([{s_GCD} - {s_GD}, {s_GCW} - 2*{s_GD}, {fp_h + WALL:.3f}]);
        }}
        
        // Thumb notch at the top for easy removal
        translate([cw/2, -cover_t - 0.1, {fp_h + WALL:.3f}])
            rotate([-90, 0, 0]) cylinder(r=15, h=cover_t + 2.0);
    }}
}}
sliding_cover();
\"\"\"
        return code

    sliding_cover = build_sliding_cover_scad("STANDARD")
    sliding_cover_tpu = build_sliding_cover_scad("TPU")
"""
    content = content[:sc_start] + func_str_sc + content[sc_end:]

    write_orig_sc = 'with open("designs/sliding_cover.scad", "w") as f:\n        f.write(sliding_cover)'
    write_new_sc = """with open("designs/sliding_cover.scad", "w") as f:
        f.write(sliding_cover)
    with open("designs/sliding_cover_tpu.scad", "w") as f:
        f.write(sliding_cover_tpu)"""
    content = content.replace(write_orig_sc, write_new_sc)
    
# Update tasks list in __main__
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
        ("chassis",        "designs/chassis.scad",        "../scratch/stl/chassis.stl"),
        ("chassis_tpu",    "designs/chassis_tpu.scad",    "../scratch/stl/chassis_tpu.stl"),
        ("chassis_tapered","designs/chassis_tapered.scad","../scratch/stl/chassis_tapered.stl"),
        ("top_cap",        "designs/top_cap.scad",        "../scratch/stl/top_cap.stl"),
        ("sliding_cover",  "designs/sliding_cover.scad",  "../scratch/stl/sliding_cover.stl"),
        ("sliding_cover_tpu", "designs/sliding_cover_tpu.scad", "../scratch/stl/sliding_cover_tpu.stl"),
        ("buttons",        "designs/buttons.scad",        "../scratch/stl/buttons.stl"),
        ("dummy_pcb",      "designs/dummy_pcb.scad",      "../scratch/stl/dummy_pcb.stl"),
    ]"""
content = content.replace(tasks_orig, tasks_new)

with open("generate_scad.py", "w") as f:
    f.write(content)
print("Updated generate_scad.py")
