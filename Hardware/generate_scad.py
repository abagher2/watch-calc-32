import os
import sys
import wx
app = wx.App(False)
import pcbnew
import subprocess

# ─────────────────────────────────────────────────────────
# KiCad Board – read PCB dimensions and component positions
# ─────────────────────────────────────────────────────────
board_path = "output/pcbs/calculator.kicad_pcb"
board = pcbnew.LoadBoard(board_path)

bbox   = board.GetBoardEdgesBoundingBox()
x_min  = bbox.GetX()       / 1e6
y_min  = bbox.GetY()       / 1e6
x_max  = bbox.GetRight()   / 1e6
y_max  = bbox.GetBottom()  / 1e6

pcb_width  = x_max - x_min
pcb_height = y_max - y_min

# OpenSCAD Origin: Bottom-Left of the calculator (when viewing Faceplate from the front, keys facing UP)
# KiCad Y increases downward. So: scad_x = KiCad_x - x_min, scad_y = y_max - KiCad_y
buttons   = []
soft_keys = []
disp      = None

for fp in board.GetFootprints():
    ref = fp.GetReference()
    pos = fp.GetPosition()
    sx  = pos.x / 1e6 - x_min
    sy  = y_max - pos.y / 1e6

    if ref.startswith("SOFT"):
        soft_keys.append({'ref': ref, 'x': sx, 'y': sy})
    elif ref.startswith("B") and len(ref) <= 3 and ref[1:].isdigit():
        buttons.append({'ref': ref, 'x': sx, 'y': sy})
    elif "Disp" in ref:
        disp = {'ref': ref, 'x': sx, 'y': sy}

all_buttons = soft_keys + buttons
all_buttons.sort(key=lambda b: b['y'], reverse=True)

rows, cur_row, cur_y = [], [], (all_buttons[0]['y'] if all_buttons else 0)
for b in all_buttons:
    if abs(b['y'] - cur_y) > 5:
        cur_row.sort(key=lambda b: b['x'])
        rows.append(cur_row)
        cur_row, cur_y = [], b['y']
    cur_row.append(b)
if cur_row:
    cur_row.sort(key=lambda b: b['x'])
    rows.append(cur_row)

labels = [
    ["", "", "", "", "", ""],
    ["√𝑥", "𝑒ˣ", "LN", "𝑦ˣ", "1/𝑥", "Σ+"],
    ["STO", "RCL", "R↓", "SIN", "COS", "TAN"],
    ["ENTER", "𝑥≷𝑦", "+/-", "E", "<-"],
    ["XEQ", "7", "8", "9", "÷"],
    ["f", "4", "5", "6", "×"],
    ["g", "1", "2", "3", "-"],
    ["C", "0", ".", "PLOT", "+"],
]
for r_idx, row in enumerate(rows):
    for c_idx, b in enumerate(row):
        lbl = (labels[r_idx][c_idx]
               if r_idx < len(labels) and c_idx < len(labels[r_idx]) else "")
        b['label'] = lbl
        b['w']     = 7.5 if r_idx == 0 else (16.0 if lbl == "ENTER" else 8.0 if lbl in ("f","g","C") else 7.5)
        b['h']     = 6.0

# ─────────────────────────────────────────────────────────
# Global constants & Component Geometry
# ─────────────────────────────────────────────────────────
WALL   = 1.8   # Base wall thickness (slimmed down for premium look)
fp_w   = pcb_width + 4.0             # faceplate width (expanded by 4mm to create a 2mm inner rail!)
fp_h   = pcb_height + 4.0            # faceplate height (expanded by 4mm to create a 2mm inner rail!)
cw     = fp_w + 2*WALL + 0.4         # chassis outer width
corner = 6.0

# Internal Component Heights (mm)
TACTILE_H = 0.0   # Eliminated! Buttons have built-in travel, faceplate sits flush on PCB
PCB_T     = 1.6   # PCB thickness
BATT_H    = 7.0   # Clearance for wired CR2450 battery holder (Z)
plate_t   = 3.0   # Faceplate base thickness (Reduced for DM32 matching)
FRONT_LIP = 0.8   # Structural retaining bezel

# Calculate required chassis depth to securely fit all components
CHASSIS_D = FRONT_LIP + plate_t + TACTILE_H + PCB_T + BATT_H + WALL

EINK_W = 65.0   # module width  (mm)
EINK_H = 30.2   # module height (mm)
pad_x = (fp_w - pcb_width) / 2
pad_y = (fp_h - pcb_height) / 2
disp_x = fp_w / 2
disp_y = (disp['y'] + pad_y + 4) if disp else (fp_h - EINK_H / 2 - 5)
PCB_SCREW_INSET = 7.0
chassis_screws = [
    (pad_x + 7.0, pad_y + 5.0), (pad_x + pcb_width - 7.0, pad_y + 5.0),
    (pad_x + 7.0, pad_y + pcb_height - 5.0), (pad_x + pcb_width - 7.0, pad_y + pcb_height - 5.0),
]

def top_fillet_cutter_scad():
    return """
module top_fillet_cutter(w, d, h, r) {
    difference() {
        translate([-r-1, -r-1, h-r]) cube([w+2*r+2, d+2*r+2, r+1]);
        hull() {
            translate([r, r, h-r]) sphere(r=r, $fn=24);
            translate([w-r, r, h-r]) sphere(r=r, $fn=24);
            translate([r, d-r, h-r]) sphere(r=r, $fn=24);
            translate([w-r, d-r, h-r]) sphere(r=r, $fn=24);
        }
        translate([-r-1, -r-1, -1]) cube([w+2*r+2, d+2*r+2, h-r+1]);
    }
}
"""

def generate_scad():
    os.makedirs("../scratch/stl", exist_ok=True)

    # ═══════════════════════════════════════════════════════
    # FACEPLATE — printed FACE-UP
    # Z=0 is the BACK of the faceplate (flat on build plate).
    # Keys face UP. 
    # Plungers are at Z=0 (printing directly on bed).
    # Micro-supports bridge plunger and faceplate wall at Z=0.
    # ═══════════════════════════════════════════════════════
    gap         = 0.60   # print-in-place clearance (0.60mm for 0.4mm nozzle to guarantee no bridging)
    pt          = 3.0    # Faceplate overall thickness
    
    # Plunger dimensions (Base of the button)
    pw = 6.0
    ph = 4.0

    faceplate = f"""
// WatchCalc 32 Faceplate — Print FACE-UP
// Back of faceplate is on Z=0 (build plate). Keys face up.
// Hourglass/I-Beam print-in-place buttons perfectly constrained by faceplate shelves.
$fn = 24;
fp_w = {fp_w:.3f};
fp_h = {fp_h:.3f};
cr   = {corner};
pt   = {pt};    
GAP  = {gap};        

module key_button(w, h, label) {{
    union() {{
        // 1. Massive Piston Base (Z=0.0 to Z=1.3)
        // Double-chamfered to create a 0.3mm mechanical hard stop and retain the button 
        // from falling out the back during assembly!
        hull() {{
            translate([0, 0, 0.20]) cylinder(d=6.2, h=0.4, center=true);
            translate([0, 0, 0.60]) cylinder(d=7.0, h=0.4, center=true);
        }}
        translate([0, 0, 1.05]) cylinder(d=7.0, h=0.5, center=true);

        // 2. Triangular Shaft (Z=1.3 to Z=3.7) to prevent rotation!
        translate([0, 0, 2.5]) cylinder(d=6.0, h=2.4, center=true, $fn=3);
        
        // 3. Top Keycap (Z=3.7 to Z=5.0)
        // Replaced hull with primitive overlapping cylinders to prevent OpenSCAD CGAL freezing!
        translate([0, 0, 4.0]) cylinder(d1=6.0, d2=5.0, h=0.6, center=true, $fn=24);
        translate([0, 0, 4.65]) cylinder(d1=5.0, d2=4.0, h=0.7, center=true, $fn=24);
    }}
}}

module button_pocket(x, y, w, h) {{
    // 1a. Bottom Retaining Lip & Hard Stop (Z=-0.1 to Z=0.5)
    // Matches the button chamfer perfectly when pressed by exactly 0.3mm!
    translate([x, y, 0.15]) cylinder(d1=6.6, d2=7.4, h=0.5, center=true, $fn=24);
    
    // 1b. Main Piston Cavity (Z=0.5 to Z=1.6)
    translate([x, y, 1.0]) cylinder(d=7.4, h=1.0, center=true);

    // 2. Triangular Shaft Hole (Z=1.6 to Z=2.8)
    translate([x, y, 1.9]) cylinder(d1=7.4, d2=6.6, h=0.6, center=true, $fn=3);
    translate([x, y, 2.5]) cylinder(d=6.6, h=0.6, center=true, $fn=3);
}}

module faceplate_body() {{
    cube([fp_w, fp_h, pt]);
}}


module faceplate() {{
    difference() {{
        faceplate_body();

        // 65x30 E-Ink Module Base Pocket (Z=-0.1 to Z=1.0)
        translate([{disp_x:.3f} - 65.4/2, {disp_y:.3f} - 30.6/2, -0.1])
            cube([65.4, 30.6, 1.1]);

        ACTIVE_W = 49.0;
        ACTIVE_H = 24.0;
        POCKET_W = ACTIVE_W + pt;
        POCKET_H = ACTIVE_H + pt;
        hull() {{
            translate([{disp_x:.3f} - ACTIVE_W/2, {disp_y:.3f} - ACTIVE_H/2, 1.0])
                cube([ACTIVE_W, ACTIVE_H, 0.01]);
            translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 0.1])
                cube([POCKET_W, POCKET_H, 0.01]);
        }}

        // Button pockets
"""
    pad_x = (fp_w - pcb_width) / 2
    pad_y = (fp_h - pcb_height) / 2
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            faceplate += f"        button_pocket({ox:.3f}, {oy:.3f}, {b['w']}, {b['h']});\n"

    for sx, sy in chassis_screws:
        faceplate += f"        translate([{sx:.3f}, {sy:.3f}, -0.1]) cylinder(d=1.6, h=1.6, $fn=16);\n"

    faceplate += """
    }
}

// Render faceplate
faceplate();

// Render buttons and micro-supports
color("Silver") {
"""
    faceplate_mjf = faceplate
    faceplate_fdm = faceplate

    pad_x = (fp_w - pcb_width) / 2
    pad_y = (fp_h - pcb_height) / 2
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            btn_str = f"    translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \"{b['label']}\");\n"
            
            faceplate_mjf += btn_str
            faceplate_fdm += btn_str

    faceplate_mjf += "}\n"
    faceplate_fdm += "}\n"


    # --- FACEPLATE TAPERED ---
    # Replace faceplate_body with bezel
    fp_tapered = faceplate
    
    fp_body_orig = "cube([fp_w, fp_h, pt]);"
    fp_body_new = """cube([fp_w, fp_h, pt]);
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
        }"""
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
            btn_str = f"    translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \"{b['label']}\");\n"
            faceplate_tapered += btn_str
    faceplate_tapered += "}\n"
    with open("designs/faceplate_mjf.scad", "w") as f:
        f.write(faceplate_mjf)
        
    with open("designs/faceplate_fdm.scad", "w") as f:
        f.write(faceplate_fdm)
        
    with open("designs/faceplate_tapered.scad", "w") as f:
        f.write(faceplate_tapered)

    import math
    D        = CHASSIS_D
    GCW = 2.0; GCD = 1.5; GR = 1.5; GY = 3.0
    junc_z = fp_h / 3.0
    batt_w = 40; batt_h = 25
    batt_z = fp_h - WALL - 30

    chassis = f"""
// WatchCalc 32 Chassis — v8 (Closed Top, Bottom-Loading)
$fn = 24;
pt   = {pt:.3f};
cw   = {cw:.3f};
ch   = {fp_h + WALL:.3f};
D    = {D:.3f};
wall = {WALL:.3f};
fp_w = {fp_w:.3f};
fp_h = {fp_h:.3f};
pcb_w = {pcb_width:.3f};
pcb_h = {pcb_height:.3f};
offset_x = (cw - fp_w) / 2;
offset_z = (ch - fp_h) / 2;
batt_w = {batt_w}; batt_h = {batt_h}; batt_z = {batt_z:.2f};
GCW = {GCW:.1f}; GCD = {GCD:.1f}; GR = {GR:.1f}; GY = {GY:.1f};
junc = {junc_z:.2f};

{top_fillet_cutter_scad()}

module chassis_shell() {{
    difference() {{
        hull() {{
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }}
        
        // Tier 1: Faceplate Cavity (Slides in from Z=0)
        translate([offset_x, -0.1, -0.1])
            cube([fp_w, pt + 0.1, ch - wall + 0.1]);
            
        // Tier 2: PCB Cavity (Slides in from Z=0)
        // Shifted by 1.5mm to create a physical rail for the faceplate and clear the tactile switches
        translate([(cw - pcb_w)/2, pt + 1.5 - 0.1, -0.1])
            cube([pcb_w, {PCB_T} + 0.2, ch - wall + 0.1]);
            
        // Tier 3: Back Components Clearance (Deepest)
        // Starts at Y = pt + 1.5 + PCB_T - 0.1 (overlap with Tier 2).
        // Ends exactly at Y = D - wall. Depth = (D - wall) - (pt + 1.5 + PCB_T - 0.1).
        translate([(cw - pcb_w)/2 + 2.0, pt + 1.5 + {PCB_T} - 0.1, -0.1])
            cube([pcb_w - 4.0, D - wall - pt - 1.5 - {PCB_T} + 0.1, ch - wall + 0.2]);
    }}
}}

module screw_bosses() {{
    for (sx = [7.0, cw - 2*wall - 7.0]) {{
        for (sy = [ch - wall - 5.0]) {{
            translate([offset_x + sx - 3.0, pt + 1.5 + {PCB_T}, offset_z + sy - 3.0])
                cube([6.0, D - wall - pt - 1.5 - {PCB_T} + 0.1, 6.0]);
            translate([offset_x + sx, pt + 1.5, offset_z + sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h={PCB_T} + 0.1);
        }}
    }}
}}
module railway_grooves() {{
    translate([-0.1, GY, -0.1])        cube([GCD+0.1, GCW, ch+0.2]);
    translate([cw-GCD, GY, -0.1])      cube([GCD+0.1, GCW, ch+0.2]);
    translate([-0.1, GY + GCW/2, 5.0]) rotate([0, 90, 0]) cylinder(d=GCW, h=GCD+0.5, $fn=16);
    translate([cw-GCD-0.4, GY + GCW/2, 5.0]) rotate([0, 90, 0]) cylinder(d=GCW, h=GCD+0.5, $fn=16);
}}
module chassis() {{
    difference() {{
        union() {{
            chassis_shell();
            screw_bosses();
        }}
        
        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the FRONT_LIP to expose the faceplate.
        // Leaves a 4.0mm wide frame on left, right, bottom, AND TOP!
        translate([wall + 4.0, -0.1, wall + 4.0])
            cube([cw - 2*wall - 8.0, {FRONT_LIP} + 0.2, ch - wall - 8.0]);
            
        // ── CHASSIS SCREW CLEARANCE HOLES ────────────────────────────────
"""
    for sx, sy in chassis_screws:
        # Screws come from the back and stop at the faceplate. They don't punch through the front!
        chassis += f"        translate([offset_x + {sx:.3f}, D + 0.1, offset_z + {sy:.3f}]) rotate([90, 0, 0]) cylinder(d=2.2, h=D - pt + 0.2);\n"
        chassis += f"        translate([offset_x + {sx:.3f}, D + 0.1, offset_z + {sy:.3f}]) rotate([90, 0, 0]) cylinder(d=4.0, h=0.8); // Head recess\n"
        
    chassis += f"""
        
        // ── RAILWAY GROOVES ──────────────────────────────────────────────
        // 2 straight grooves for the sliding cover
        railway_grooves();
        
        // ── TOP CORNER FILLET ─────────────────────────────────────────────
        translate([0, 0, 0]) top_fillet_cutter(cw, D, ch, 3.0);
    }}
}}
chassis();
"""


    # --- CHASSIS TPU ---
    chassis_tpu = chassis
    # Remove railway grooves
    chassis_tpu = chassis_tpu.replace("railway_grooves();", "// railway_grooves();")
    # Add bumps
    chassis_tpu = chassis_tpu.replace("chassis();", """
        translate([15, {D:.3f}, 10]) sphere(r=2.5);
        translate([{cw:.3f}-15, {D:.3f}, 10]) sphere(r=2.5);
        translate([15, {D:.3f}, {fp_h + WALL:.3f}-10]) sphere(r=2.5);
        translate([{cw:.3f}-15, {D:.3f}, {fp_h + WALL:.3f}-10]) sphere(r=2.5);
    }}
}}
chassis();
""")

    # --- CHASSIS TAPERED ---
    chassis_tapered = chassis
    # Pure Y Taper for hull
    hull_orig = """hull() {
            translate([0, 0, 0]) cube([3, 3, ch]);
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }"""
    hull_new = """hull() {
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
        }"""
    chassis_tapered = chassis_tapered.replace(hull_orig, hull_new)
    
    # Tier 3 depth restriction
    t3_orig = f"""        translate([(cw - pcb_w)/2 + 2.0, pt + 1.5 + {{PCB_T}} - 0.1, -0.1])
            cube([pcb_w - 4.0, D - wall - pt - 1.5 - {{PCB_T}} + 0.1, ch - wall + 0.2]);"""
    t3_new = f"""        translate([(cw - pcb_w)/2 + 2.0, pt + 1.5 + {{PCB_T}} - 0.1, 90.0])
            cube([pcb_w - 4.0, D - wall - pt - 1.5 - {{PCB_T}} + 0.1, ch - 90.0]);"""
    chassis_tapered = chassis_tapered.replace(t3_orig, t3_new)

    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)

    with open("designs/chassis_tapered.scad", "w") as f:
        f.write(chassis_tapered)


    # ═══════════════════════════════════════════════════════
    # TOP CAP — at keypad end (Z=0), seals faceplate + PCB
    # ═══════════════════════════════════════════════════════
    # The cap is placed at the KEYPAD END (bottom of device, Z=0).
    # Faceplate and PCB slide UP from Z=0, cap seals them in.
    # 2× M3 screws through cap plate in +Z direction into chassis cap posts.
    # Retention lips on front (Y=0) and back (Y=D) edges grip the edges
    # of the faceplate and PCB to prevent them sliding back out.

    cap_t_val = 3.0      # end cap plate thickness
    bezel_lip = plate_t   # front lip extends 4mm forward to match bezel

    top_cap = f"""
// WatchCalc 32 End Cap — v8 (FLUSH PLUG inside chassis)
// Cap extends from Z=ch-cap_t to Z=ch. 
// Secured by lateral M3 screws at Z=138.550.
$fn = 24;
cw    = {cw:.3f};
D     = {CHASSIS_D:.3f}; // 14.9
wall  = {WALL:.3f};
cap_t = {cap_t_val};
ch    = {fp_h + WALL:.3f}; // 145.350

module top_cap() {{
    union() {{
        // ── MAIN PLATE (Flush Plug, Z=ch-cap_t to Z=ch) ─────────
        // Fits perfectly inside Tier 1/2/3 cavity
        translate([wall, {FRONT_LIP}, ch - cap_t])
            cube([cw - 2*wall, D - wall - {FRONT_LIP}, cap_t]);

        // ── FRONT LIP (Drops down into bezel window to secure Faceplate) ──────
        // Completes the chassis O-frame since the chassis cannot have a bridged top lip.
        // Drops down to Z=139 to trap the Faceplate (which ends at Z=140).
        translate([wall + 2.0, 0, 139.0])
            cube([cw - 2*wall - 4.0, {FRONT_LIP}, ch - 139.0]);

        // ── SCREW BOSSES (Drop down into chassis Tier 3 to Z=135) ─────────────────
        // The top two chassis screws (at Z=138.550) pass through the rear wall, 
        // through these blocks, then into the PCB and Faceplate.
        // NOTE: The horizontal pegs have been removed so the cap can drop in straight from above!
        
        // Left Standoff
        difference() {{
            // Thick Base: From back wall to PCB (Y = pt + 1.5 + PCB_T)
            translate([wall + 7.0 - 3.0, {pt} + 1.5 + {PCB_T}, 135.0]) 
                cube([6.0, D - wall - {pt} - 1.5 - {PCB_T} + 0.1, ch - cap_t - 135.0 + 0.1]);
            // Clearance hole for M2 screw (d=2.2)
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // Right Standoff
        difference() {{
            translate([cw - wall - 7.0 - 3.0, {pt} + 1.5 + {PCB_T}, 135.0]) 
                cube([6.0, D - wall - {pt} - 1.5 - {PCB_T} + 0.1, ch - cap_t - 135.0 + 0.1]);
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // ── BATTERY BUCKET (hangs down into Tier 3 cavity) ─────
        // Designed to hold a wired CR2450 battery (approx 26x26x6mm)
        // Positioned in the Y dimension within the Tier 3 cavity (Y={pt}+1.5+{PCB_T} to Y=D-wall)
        // Z hangs down from ch.
        translate([(cw - 28)/2, {pt} + 1.5 + {PCB_T}, ch - 26]) {{
            difference() {{
                // Outer block
                cube([28, D - wall - ({pt} + 1.5 + {PCB_T}) - 0.2, 26]);
                // Inner hollow (1.2mm walls on sides and bottom, open on front and top)
                translate([1.2, -0.1, 1.2])
                    cube([28 - 2.4, D - wall - ({pt} + 1.5 + {PCB_T}), 26]);
            }}
        }}
    }}
}}
top_cap();
"""
    with open("designs/top_cap.scad", "w") as f:
        f.write(top_cap)




    # ═══════════════════════════════════════════════════════
    # C-COVER (back panel + two side flanges, open front)
    # ═══════════════════════════════════════════════════════
    # Full-height PLA cover. Protects back + sides of calculator.
    # In pencil case: snaps over the back (rail tabs in chassis grooves).
    # On desk: wedge foot at keypad end tilts calculator ~10° toward user.
    # Screen is protected by chassis rim walls (recessed 4mm).

    import math
    cov_wall  = 2.0        # wall thickness (PLA)
    cov_clear = 0.4        # fit clearance per side
    cov_h     = fp_h + 4   # 155mm — 2mm overhang each end
    GROOVE_W  = 2.0;  GROOVE_D = 1.5;  GROOVE_Z = 3.0
    rail_w    = GROOVE_W - 0.2   # rail tab width (0.2mm total clearance)
    rail_d    = GROOVE_D - 0.1   # rail tab depth (0.1mm clearance)
    wedge_len = 30
    wedge_rise = wedge_len * math.tan(math.radians(10))  # 5.29mm at 10°
    cov_ow    = cw + 2 * (cov_wall + cov_clear)          # total outer width
    cov_z_start = -(cap_t_val + cov_wall + cov_clear)
    cov_h     = fp_h + WALL + cap_t_val + 2*cov_wall + 2*cov_clear
    cov_y_start = -(plate_t + cov_clear)
    cov_y_len = CHASSIS_D + plate_t + 2*cov_clear

    cover = f"""
// WatchCalc 32 C-Cover — v3 PLA BACK COVER
// C-shaped: back panel + two side flanges. Open FRONT (buttons/screen accessible).
// Full height {cov_h:.1f}mm — slides onto chassis from display end.
// Wedge foot at keypad end (Z=0) creates 10° desk tilt.
// Rail tabs inside flanges engage chassis side grooves.
$fn = 24;
cw       = {cw:.3f};   // chassis width
ch       = {fp_h:.3f};   // chassis height
D        = {CHASSIS_D:.3f};   // chassis depth
cov_wall = {cov_wall:.1f};
cov_clear= {cov_clear:.1f};
cov_ow   = {cov_ow:.3f};  // total outer width (including flanges)
cov_h    = {cov_h:.3f};  // total height
rail_w   = {rail_w:.2f};  // rail tab width
rail_d   = {rail_d:.2f};  // rail tab depth
GROOVE_Z = {GROOVE_Z:.1f};  // groove Y-offset from front face
cov_z_start = {cov_z_start:.3f};
cov_y_start = {cov_y_start:.3f};
cov_y_len   = {cov_y_len:.3f};
wedge_len  = {wedge_len};
wedge_rise = {wedge_rise:.3f};

{top_fillet_cutter_scad()}

module c_cover() {{
    difference() {{
        union() {{
            // ── C-SHELL (Rounded outer body) ───────────────────────────────────
            // A fully rounded hull replaces the sharp individual flange/panel cubes.
            r = 3.0;
            difference() {{
                hull() {{
                    // Front-left
                    translate([-(cov_wall + cov_clear) + r, cov_y_start + r, cov_z_start])
                        cylinder(r=r, h=cov_h, $fn=24);
                    // Front-right
                    translate([cw + cov_clear + cov_wall - r, cov_y_start + r, cov_z_start])
                        cylinder(r=r, h=cov_h, $fn=24);
                    // Back-left
                    translate([-(cov_wall + cov_clear) + r, cov_y_start + cov_y_len - r, cov_z_start])
                        cylinder(r=r, h=cov_h, $fn=24);
                    // Back-right
                    translate([cw + cov_clear + cov_wall - r, cov_y_start + cov_y_len - r, cov_z_start])
                        cylinder(r=r, h=cov_h, $fn=24);
                }}
                
                // Hollow inner space for chassis
                translate([-cov_clear, cov_y_start - 0.1, cov_z_start + cov_wall])
                    cube([cw + 2*cov_clear, cov_y_len - cov_wall + 0.2, cov_h + 0.1]);
            }}
                
            // ── RAIL TABS (inside flanges, engage chassis side grooves) ──────────
            // Left flange rail tab
            union() {{
                translate([-cov_clear - 0.1, GROOVE_Z - cov_clear, cov_z_start + cov_wall])
                    cube([rail_d + 0.1, rail_w, cov_h - cov_wall]);
                // Lock bump at Z=5
                translate([-cov_clear - 0.1, GROOVE_Z - cov_clear + rail_w/2, 5.0]) 
                    rotate([0, 90, 0]) 
                    cylinder(d=rail_w, h=rail_d + 0.35, $fn=16);
            }}
            // Right flange rail tab (translated inwards by rail_d)
            union() {{
                translate([cw + cov_clear - rail_d, GROOVE_Z - cov_clear, cov_z_start + cov_wall])
                    cube([rail_d + 0.1, rail_w, cov_h - cov_wall]);
                // Lock bump at Z=5
                translate([cw + cov_clear + 0.1, GROOVE_Z - cov_clear + rail_w/2, 5.0]) 
                    rotate([0, -90, 0]) 
                    cylinder(d=rail_w, h=rail_d + 0.35, $fn=16);
            }}
        }}

        // ── WEDGE FOOT BEVEL ────────────────────────────────────────────────
        // 10° bevel cut from BACK face of end cap only.
        translate([-(cov_wall + cov_clear + 1),
                   D + cov_clear - 0.1,
                   cov_z_start - 0.1])
            rotate([-atan(wedge_rise / wedge_len), 0, 0])
                cube([cov_ow + 2, wedge_rise + 2, wedge_len + 3]);
                
        // ── TOP CORNER FILLET ─────────────────────────────────────────────
        translate([-(cov_wall + cov_clear), cov_y_start, cov_z_start])
            top_fillet_cutter(cov_ow, cov_y_len, cov_h, 3.0);
    }}

}}
c_cover();
"""

    # --- TPU STRETCH COVER ---
    tpu_stretch_cover = f"""
// WatchCalc 32 TPU Stretch Cover (Protective Sleeve)
$fn = 32;
cw   = {cw:.3f};
D    = {CHASSIS_D:.3f};
ch   = {fp_h + WALL:.3f};
cover_t = 2.0;

module tpu_stretch_cover() {{
    difference() {{
        // Outer Box (Left, Right, Bottom, Front)
        // Top is open (Z=ch). Back is open (Y=D).
        translate([-cover_t, -cover_t, -cover_t])
            cube([cw + 2*cover_t, D + cover_t, ch + cover_t]);
            
        // Inner Chassis Cavity
        // X=0 to cw. Y=0 to D+0.1 (open back). Z=0 to ch+0.1 (open top).
        translate([0, 0, 0])
            cube([cw, D + 0.1, ch + 0.1]);
    }}
}}
tpu_stretch_cover();
"""
    with open("designs/sliding_cover.scad", "w") as f:
        f.write(cover)
        
    with open("designs/tpu_stretch_cover.scad", "w") as f:
        f.write(tpu_stretch_cover)





    # ═══════════════════════════════════════════════════════
    # STANDALONE KEYCAPS 
    # ═══════════════════════════════════════════════════════
    buttons_scad = f"""
// Standalone Keycaps
$fn = 24;
module keycap(w, h, label) {{
    // Plunger (Z=-1 to 0)
    translate([0, 0, -0.5]) cube([w - 1.0, h - 1.0, 1.0], center=true);

    // Flange (Z=0 to 1.0)
    translate([0, 0, 0.5]) cube([w + 1.5, h + 1.5, 1.0], center=true);

    // Keycap (Z=1.0 to 6.7)
    hull() {{
        translate([-w/2+1.0, -h/2+1.0, 1.0])   cylinder(r=1.0, h=0.01);
        translate([ w/2-1.0, -h/2+1.0, 1.0])   cylinder(r=1.0, h=0.01);
        translate([-w/2+1.0,  h/2-1.0, 1.0])   cylinder(r=1.0, h=0.01);
        translate([ w/2-1.0,  h/2-1.0, 1.0])   cylinder(r=1.0, h=0.01);
        
        translate([-w/2+1.0, -h/2+1.0, 6.7]) cylinder(r=0.8, h=0.01);
        translate([ w/2-1.0, -h/2+1.0, 6.7]) cylinder(r=0.8, h=0.01);
        translate([-w/2+1.0,  h/2-1.0, 6.7]) cylinder(r=0.8, h=0.01);
        translate([ w/2-1.0,  h/2-1.0, 6.7]) cylinder(r=0.8, h=0.01);
    }}
}}
"""
    for row in rows:
        for b in row:
            buttons_scad += f"translate([{b['x']:.1f}, {b['y']:.1f}, 0]) keycap({b['w']}, {b['h']}, \"{b['label']}\");\n"

    with open("designs/buttons.scad", "w") as f:
        f.write(buttons_scad)

    # ---------------------------------------------------------
    # DUMMY PCB FOR ALIGNMENT
    # ---------------------------------------------------------
    dummy_scad = f"""
// ── DUMMY PCB FOR ALIGNMENT TESTING ──────────────────────────────
$fn=24;
module dummy_pcb() {{
    // Main FR4 Board
    color("DarkGreen") {{
        difference() {{
            translate([{pad_x:.3f}, {pad_y:.3f}, 0]) cube([{pcb_width:.3f}, {pcb_height:.3f}, 1.6]);
"""
    for sx, sy in chassis_screws:
        dummy_scad += f"            translate([{sx:.3f}, {sy:.3f}, -0.1]) cylinder(d=3.2, h=2.0, $fn=16);\n"
        
    dummy_scad += f"""
        }}
    }}


    // E-Ink Display Module Base (White)
    color("White") {{
        translate([{disp_x:.3f}, {disp_y:.3f}, 1.6]) 
            translate([-{EINK_W:.3f}/2, -{EINK_H:.3f}/2, 0])
            cube([{EINK_W:.3f}, {EINK_H:.3f}, 1.0]);
    }}

    // E-Ink Display Active Glass Area (Black)
    color("Black") {{
        translate([{disp_x:.3f}, {disp_y:.3f}, 2.6]) 
            translate([-49.0/2, -24.0/2, 0])
            cube([49.0, 24.0, 0.4]);
    }}

    // Tactile Switches (6.0 x 3.5 x 1.5mm body + 3.0x0.5mm plunger)
    color("Silver") {{
"""
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            dummy_scad += f"""        translate([{ox:.3f}, {oy:.3f}, 1.6]) {{
            translate([-3.0, -1.75, 0]) cube([6.0, 3.5, 1.5]);
            translate([0, 0, 1.5]) cylinder(d=3.0, h=0.5);
        }}
"""
            
    dummy_scad += f"""    }}
    
    // Components on the back (MCU and Battery JST)
    color("Black") {{
        // RP2350 / ProMicro (35x18x4mm)
        translate([{34.575 + pad_x:.3f}, {130.075 + pad_y:.3f}, 0]) 
            translate([-35.0/2, -18.0/2, -4.0])
            cube([35.0, 18.0, 4.0]);
    }}
    
    color("White") {{
        // JST-PH 2-Pin SMD Right-Angle Connector (6x7.8x4.8mm) - MOVED TO TOP
        translate([{35.0 + pad_x:.3f}, {140.0 + pad_y:.3f}, 0]) 
            translate([-6.0/2, -7.8/2, -4.8])
            cube([6.0, 7.8, 4.8]);
    }}
}}
dummy_pcb();
"""
    with open("designs/dummy_pcb.scad", "w") as f:
        f.write(dummy_scad)

    print(f"SCAD files generated:")
    print(f"  Faceplate (MJF): FACE-UP print. Keys face up, Z=0 on bed. NO micro-supports (powder supported).")
    print(f"  Faceplate (FDM): FACE-UP print. Keys face up, Z=0 on bed. Has 0.4mm micro-supports.")
    print(f"  Chassis:        STANDING on keypad edge. Flat 10mm uniform depth. Side grooves for cover.")
    print(f"  Top Cap:        FLAT print. Seals display end. Incorporates battery holder.")
    print(f"  Sliding Cover:  FLAT on front wall face. Print in PLA (v1). TPU for v2.")
    print(f"  Buttons:        As-is.")
    print(f"  Dummy PCB:      For physical alignment testing.")

if __name__ == "__main__":
    generate_scad()

    print("\nCompiling STLs...")
    tasks = [
        ("faceplate_mjf",  "designs/faceplate_mjf.scad",  "../scratch/stl/faceplate_mjf.stl"),
        ("faceplate_fdm",  "designs/faceplate_fdm.scad",  "../scratch/stl/faceplate_fdm.stl"),
        ("chassis_tapered","designs/chassis_tapered.scad","../scratch/stl/chassis_tapered.stl"),
        ("top_cap",        "designs/top_cap.scad",        "../scratch/stl/top_cap.stl"),
        ("tpu_stretch_cover","designs/tpu_stretch_cover.scad","../scratch/stl/tpu_stretch_cover.stl"),
        ("buttons",        "designs/buttons.scad",        "../scratch/stl/buttons.stl"),
        ("dummy_pcb",      "designs/dummy_pcb.scad",      "../scratch/stl/dummy_pcb.stl"),
    ]

    for label, src, dst in tasks:
        print(f"  Building {label} ...")
        res = subprocess.run(["openscad", "-o", dst, src], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            print(f"  ✓ {label}.stl")
        else:
            print(f"  ✗ {label} ERRORS:\n{res.stderr[-800:]}")

    mfg_3d = "output/WatchCalc32_PCBWay_Manufacturing/3D_Printing_Files"
    os.makedirs(mfg_3d, exist_ok=True)
    for name, scad_file, stl_file in tasks:
        # print(f"  Building {name} ...")
        # subprocess.run(["openscad", "-o", stl_file, scad_file], check=True)
        pass
    print("Done generating SCAD files!")
