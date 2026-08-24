import os
import sys
import wx
app = wx.App(False)
import pcbnew
import math
import subprocess

# ─────────────────────────────────────────────────────────
# KiCad Board – read PCB dimensions and component positions
# ─────────────────────────────────────────────────────────
board_path = "output/pcbs/calculator.kicad_pcb"
board = pcbnew.LoadBoard(board_path)

bbox   = board.GetBoardEdgesBoundingBox()
x_min  = bbox.GetX()       / 1e6
jst_x = 56.15 # fallback
jst_fp = board.FindFootprintByReference('JST1')
if jst_fp:
    jst_x = (jst_fp.GetPosition().x / 1e6) - x_min
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
TACTILE_H = 1.6   # 1.5mm switches + 0.1mm gap for sliding clearance
PCB_T     = 1.6   # PCB thickness
BATT_H    = 7.0   # Clearance for wired CR2450 battery holder (Z)
plate_t   = 3.0   # Faceplate base thickness (Reduced for DM32 matching)
FRONT_LIP = 0.8   # Structural retaining bezel

# Calculate required chassis depth to securely fit all components
CHASSIS_D = FRONT_LIP + plate_t + TACTILE_H + PCB_T + BATT_H + WALL

DISP_W = 62.8
DISP_H = 42.82
DISP_T = 1.50 # Shimmed to exactly match tactile switches for coplanarity and sliding clearance
ACTIVE_W = 58.80
ACTIVE_H = 35.28

pad_x = (fp_w - pcb_width) / 2
pad_y = (fp_h - pcb_height) / 2
disp_x = fp_w / 2
disp_y = 121.575 # Vertically centered between Top edge (143.15) and Soft Keys (100.0)
PCB_SCREW_INSET = 7.0
chassis_screws = [
    # Bottom screws (keypad end)
    (pad_x + 9.0, pad_y + pcb_height - 8.0), 
    (pad_x + pcb_width - 9.0, pad_y + pcb_height - 8.0),
    # Top screws (display end, used by Top Cap)
    (pad_x + 9.0, pad_y + 8.0),
    (pad_x + pcb_width - 9.0, pad_y + 8.0),
]

def top_fillet_cutter_scad():
    return """

"""

def generate_scad():
    os.makedirs("../scratch/stl", exist_ok=True)

    # Calculate dimensions needed in python
    py_fp_w = 74.650
    py_fp_h = 147.150
    py_WALL = 1.800
    py_ch = py_fp_h + py_WALL
    py_cw = py_fp_w + 2*py_WALL
    py_offset_x = (py_cw - py_fp_w) / 2
    py_offset_z = (py_ch - py_fp_h) / 2

    # ═══════════════════════════════════════════════════════
    # FACEPLATE — printed FACE-DOWN
    # Z=3.0 is the FRONT of the faceplate (flat on build plate).
    # Keys face DOWN. 
    # ═══════════════════════════════════════════════════════
    gap         = 0.60   # print-in-place clearance
    pt          = 3.0    # Faceplate overall thickness
    
    # Plunger dimensions (Base of the button)
    pw = 6.0
    ph = 4.0

    faceplate = f"""
// WatchCalc 32 Faceplate — Print FACE-DOWN
// Front of faceplate is on Z=3.0 (build plate). Keys face down.
$fn = 24;
fp_w = {fp_w:.3f};
fp_h = {fp_h:.3f};
cr   = {corner};
pt   = {pt};    
GAP  = {gap};        

module squircle_centered(w, h, depth, r) {{
    translate([-w/2, -h/2, 0]) hull() {{
        translate([r, r, 0]) cylinder(r=r, h=depth, $fn=24);
        translate([w-r, r, 0]) cylinder(r=r, h=depth, $fn=24);
        translate([r, h-r, 0]) cylinder(r=r, h=depth, $fn=24);
        translate([w-r, h-r, 0]) cylinder(r=r, h=depth, $fn=24);
    }}
}}

module key_button(w, h) {{
    // Base plunger (touches tactile switch)
    squircle_centered(w, h, 1.0, 1.5);
    // Taper Up (45-degree overhang transition)
    // Taller shaft: 2.4mm tall instead of 2.0mm
    translate([0, 0, 1.0]) hull() {{
        squircle_centered(w, h, 0.01, 1.5);
        translate([0, 0, 2.4]) rotate([0, 0, 90]) cylinder(d=min(w, h) - 1.5, h=0.01, $fn=3);
    }}
    // Taper Out (45-degree overhang transition)
    // Shifted up by 0.4mm
    translate([0, 0, 3.4]) hull() {{
        rotate([0, 0, 90]) cylinder(d=min(w, h) - 1.5, h=0.01, $fn=3);
        translate([0, 0, 2.0]) squircle_centered(w, h, 0.01, 1.5);
    }}
    // Top piston - Squircle
    // Shifted up by 0.4mm
    translate([0, 0, 5.4]) squircle_centered(w, h, 1.0, 1.5);
}}

module button_pocket(w, h) {{
    // Front wide pocket (with 0.4mm vertical gap)
    translate([0, 0, -0.1]) squircle_centered(w + 1.2, h + 1.2, 1.5, 1.5);
    // Taper pocket (45-degree overhang transition)
    translate([0, 0, 1.4]) hull() {{
        squircle_centered(w + 1.2, h + 1.2, 0.01, 1.5);
        translate([0, 0, 2.0]) rotate([0, 0, 90]) cylinder(d=min(w, h) - 0.3, h=0.01, $fn=3);
    }}
    // Triangular Waist
    translate([0, 0, 3.4]) rotate([0, 0, 90]) cylinder(d=min(w, h) - 0.3, h=0.01, $fn=3);
}}

module faceplate_body() {{
    cube([fp_w, fp_h - 0.8, pt]);
}}


module faceplate() {{
    difference() {{
        faceplate_body();

        // Bezel Window: Starts small (ACTIVE_W x ACTIVE_H) at the FRONT (Z=-0.1).
        // Expands smoothly to the full screen bounds (DISP_W x DISP_H) at the BACK (Z=pt+0.1).
        // Because it EXPANDS as it goes up (when printed Face Up at Z=0), it requires ZERO SUPPORTS!
        hull() {{
            translate([{disp_x:.3f} - {ACTIVE_W:.3f}/2, {disp_y:.3f} - {ACTIVE_H:.3f}/2, -0.1])
                cube([{ACTIVE_W:.3f}, {ACTIVE_H:.3f}, 0.01]);
            translate([{disp_x:.3f} - {DISP_W:.3f}/2, {disp_y:.3f} - {DISP_H:.3f}/2, pt + 0.1])
                cube([{DISP_W:.3f}, {DISP_H:.3f}, 0.01]);
        }}

        // Button pockets
"""
    pad_x = (fp_w - pcb_width) / 2
    pad_y = (fp_h - pcb_height) / 2
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            faceplate += f"        translate([{ox:.3f}, {oy:.3f}, 0]) button_pocket({b['w']}, {b['h']});\n"

    # Only generate faceplate holes for bottom screws to avoid hitting the LCD
    for sx, sy in []: # No screws in faceplate or dummy PCB!
        faceplate += f"        translate([{sx:.3f}, {sy:.3f}, -0.1]) cylinder(d=1.6, h=1.6, $fn=16);\n"

    faceplate += """
    }
}

// Group into an assembly for easy rotation
module faceplate_assembly() {
    faceplate();
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
            btn_str = f"        translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']});\n"
            faceplate_mjf += btn_str
            faceplate_fdm += btn_str

    closing_str = f"""    }}
}}
// Render Faceplate Assembly perfectly FACE UP on the bed (Z=0 on bed)
translate([0, 0, {pt:.3f}]) rotate([180, 0, 0]) faceplate_assembly();
"""
    faceplate_mjf += closing_str
    faceplate_fdm += closing_str

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
            btn_str = f"        translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']});\n"
            faceplate_tapered += btn_str
    faceplate_tapered += closing_str
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
ACTIVE_W = {ACTIVE_W:.3f};
ACTIVE_H = {ACTIVE_H:.3f};
DISP_W = {DISP_W:.3f};
DISP_H = {DISP_H:.3f};
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
            translate([3, 3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, 3, 0]) cylinder(r=3, h=ch);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }}
        
        // Tier 1: Faceplate Cavity (Slides in from Z=ch, stopped by bottom lip at Z=wall)
        translate([offset_x, {FRONT_LIP} - 0.1, wall])
            cube([fp_w, pt + 0.1, ch + 0.1]);
            
        // Middle Cavity: Hollows out the center for the 65.4mm E-Ink Display to slide down!
        // We make this cavity 66.4mm wide, which leaves ~2.1mm solid rails on the left and right
        // to securely hold the Faceplate in place!
        translate([(cw - 66.4)/2, {FRONT_LIP} + pt - 0.1, wall])
            cube([66.4, {TACTILE_H} + 0.2, ch + 0.1]);
            
        // Tier 2: PCB Cavity (Slides in from Z=ch)
        // Shifted by 1.5mm to create a physical rail for the faceplate and clear the tactile switches
        translate([(cw - pcb_w)/2, {FRONT_LIP} + pt + {TACTILE_H} - 0.1, wall])
            cube([pcb_w, {PCB_T} + 0.2, ch + 0.1]);
            
        // Tier 2.5: PCB Trace Clearance
        // Hollows out 0.5mm behind the PCB so traces/vias don't scratch against the solid wedge back when sliding in.
        // We cannot hollow out more than 0.5mm here because the chassis is only 7.9mm thick at the bottom!
        translate([(cw - pcb_w + 4.0)/2, {FRONT_LIP} + pt + {TACTILE_H} + {PCB_T} - 0.1, wall])
            cube([pcb_w - 4.0, 0.5 + 0.1, ch + 0.1]);
            
        // Tier 3: Back Components Clearance (Deepest)
        // Starts at Z=90. Tapers to match the chassis back wall to avoid punching through!
        // At Z=90, max Y is 9.8. At Z=ch, max Y is 12.2.
        hull() {{
            translate([(cw - pcb_w)/2 + 2.0, {FRONT_LIP} + pt + {TACTILE_H} + {PCB_T} - 0.1, 90.0])
                cube([pcb_w - 4.0, 9.8 - ({FRONT_LIP} + pt + {TACTILE_H} + {PCB_T}), 0.1]);
            translate([(cw - pcb_w)/2 + 2.0, {FRONT_LIP} + pt + {TACTILE_H} + {PCB_T} - 0.1, ch - 0.1])
                cube([pcb_w - 4.0, 12.2 - ({FRONT_LIP} + pt + {TACTILE_H} + {PCB_T}), 0.1]);
        }}
    }}
}}

module chassis() {{
    difference() {{
        union() {{
            chassis_shell();
        }}

        
        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the front to expose the faceplate.
        // Leaves a 4.0mm wide frame on left, right, and bottom.
        // Leaves left, right, and bottom frames. Top is completely open for Faceplate slide-in.
        translate([wall + 4.0, -0.1, wall + 4.0])
            cube([cw - 2*wall - 8.0, {FRONT_LIP} + 0.2, ch + 0.1]);
            
        // ── CHASSIS SCREW CLEARANCE HOLES ────────────────────────────────
"""
    for sx, sy in chassis_screws:
        # Faceplate Y (sy) is inverted relative to Chassis Z!
        cz = py_ch - py_offset_z - sy
        chassis += f"        translate([offset_x + {sx:.3f}, D + 0.1, {cz:.3f}]) rotate([90, 0, 0]) cylinder(d=2.2, h=D - pt + 0.2);\n"
        chassis += f"        translate([offset_x + {sx:.3f}, D + 0.1, {cz:.3f}]) rotate([90, 0, 0]) cylinder(d=4.0, h=0.8); // Head recess\n"

    chassis += f"""
        // ── RAILWAY GROOVES ──────────────────────────────────────────────
        // Removed! TPU stretch cover is used instead.
        // railway_grooves();
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
    hull_orig = """        hull() {
            translate([3, 3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, 3, 0]) cylinder(r=3, h=ch);
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }"""
    hull_new = """        hull() {
            // Front edge (rounded)
            translate([3, 3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, 3, 0]) cylinder(r=3, h=ch);
            
            // Back edge (tapered)
            // At Z=0 (keypad), minimum depth is 7.9mm to clear the back cutouts.
            // (Center of r=3 cylinder is at Y=7.9 - 3.0 = 4.9)
            translate([3, 4.9, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 4.9, 0]) cylinder(r=3, h=0.1);
            
            // At Z=ch (display), depth is D (14.2). (Center is at Y=D - 3.0)
            translate([3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
            translate([cw-3, D-3, ch-0.1]) cylinder(r=3, h=0.1);
        }"""
    chassis_tapered = chassis_tapered.replace(hull_orig, hull_new)
    


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

module top_cap_profile(h_val) {{
    hull() {{
        translate([3, 3, 0]) cylinder(r=3, h=h_val);
        translate([cw-3, 3, 0]) cylinder(r=3, h=h_val);
        translate([3, D-3, 0]) cylinder(r=3, h=h_val);
        translate([cw-3, D-3, 0]) cylinder(r=3, h=h_val);
    }}
}}

module top_cap() {{
    union() {{
        // ── OVERHANG ARMOR (Sits completely flush ON TOP of chassis) ─────
        translate([0, 0, ch])
            top_cap_profile(cap_t);

        // ── MAIN PLATE (Tiered Plugs, Z=ch-cap_t to Z=ch) ─────────
        // Perfect fit into the chassis cavities!
        // Middle Cavity Plug
        translate([{(cw - 66.4)/2:.3f}, 0.8 + {pt:.3f}, ch - cap_t])
            cube([66.4, 1.6, cap_t]);
            
        // PCB Cavity Plug
        translate([{(cw - pcb_width)/2:.3f}, 0.8 + {pt:.3f} + 1.6, ch - cap_t])
            cube([{pcb_width:.3f}, 1.6, cap_t]);
            
        // Trace Clearance & Back Components Cavity Plug
        translate([{(cw - pcb_width + 4.0)/2:.3f}, 0.8 + {pt:.3f} + 3.2, ch - cap_t])
            cube([{pcb_width - 4.0:.3f}, D - wall - (0.8 + {pt:.3f} + 3.2), cap_t]);

        // ── FRONT LIP ROOF (Bridges across Faceplate to create the upper lip) ──────
        // Drops down to Z=ch-0.8 at the front to cover the faceplate
        translate([wall + 4.0, 0, ch - 0.8])
            cube([cw - 2*wall - 8.0, {FRONT_LIP} + pt, 0.8 + cap_t]);

        // ── SCREW BOSSES (Drop down into chassis Tier 3) ─────────────────
        // Left Standoff (Widened to 10.0mm to brace laterally against chassis wall!)
"""
    cz_top_screw = py_WALL + py_fp_h - 12.0
    cz_boss_bottom = cz_top_screw - 3.55
    # Calculate exact X coordinates to match chassis holes!
    lx = (cw - pcb_width)/2 + 9.0
    rx = (cw - pcb_width)/2 + pcb_width - 9.0
    top_cap += f"""
        difference() {{
            hull() {{
                translate([{lx:.3f} - 7.0, 0.8 + {pt} + {TACTILE_H} + {PCB_T} + 1.5, {cz_boss_bottom:.3f}]) 
                    cube([10.0, 11.7 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 1.5), 0.1]);
                translate([{lx:.3f} - 7.0, 0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5, ch - cap_t]) 
                    cube([10.0, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5), 0.1]);
            }}
            // Receiver hole for M2 self-tapping screw (d=1.8)
            translate([{lx:.3f}, D + 0.1, 138.050]) rotate([90, 0, 0]) cylinder(d=1.8, h=D + 2.0);
        }}
        
        // Right Standoff (Widened to 10.0mm to brace laterally against chassis wall!)
        difference() {{
            hull() {{
                translate([{rx:.3f} - 3.0, 0.8 + {pt} + {TACTILE_H} + {PCB_T} + 1.5, {cz_boss_bottom:.3f}]) 
                    cube([10.0, 11.7 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 1.5), 0.1]);
                translate([{rx:.3f} - 3.0, 0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5, ch - cap_t]) 
                    cube([10.0, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5), 0.1]);
            }}
            translate([{rx:.3f}, D + 0.1, 138.050]) rotate([90, 0, 0]) cylinder(d=1.8, h=D + 2.0);
        }}
        
        // ── BATTERY BUCKET (hangs down into Tier 3 cavity) ─────
        // Restored to CR2450 coin cell (24.5mm diameter x 5.0mm thick) + wire clearance.
        // Tapered to perfectly respect the 2.0mm back chassis wall without punching through!
        // The coin cell's round edge perfectly avoids the thinnest part of the taper at the bottom.
        // Aligned with JST1 connector at X=68.0 (KiCad) -> X=56.15 (PCB relative)
        translate([{(cw - pcb_width)/2 + jst_x - 14.0:.3f}, 0.8 + {pt:.3f} + {TACTILE_H} + {PCB_T}, ch - 26]) {{
            difference() {{
                // Outer block (Tapered)
                hull() {{
                    cube([28, 11.0 - ({pt} + {TACTILE_H} + {PCB_T}), 0.1]);
                    translate([0, 0, 26 + 0.1]) cube([28, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5), 0.1]); // Goes ALL THE WAY UP through the cap to let wires out!
                }}
                // Inner hollow (1.2mm walls on sides, back, and bottom. OPEN on front to PCB and OPEN on top for wires!)
                translate([1.2, -0.1, 1.2])
                    hull() {{
                        cube([28 - 2.4, 11.0 - ({pt} + {TACTILE_H} + {PCB_T}) - 1.2, 0.1]);
                        translate([0, 0, 26 + 0.2]) cube([28 - 2.4, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5) - 1.2, 0.1]);
                    }}
                    
                // Wire exit channel cutting through the front lip to reach the JST connector!
                translate([28 - 2.4 - 5.0, -10.0, 26 - cap_t])
                    cube([5.0, 10.0, cap_t + 1.0]);
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
btn_clearance = 3.2; // Buttons stick out ~3.0mm, give 0.2mm extra

module tpu_stretch_cover() {{
    difference() {{
        // Outer Box with rounded corners (r = 3 + cover_t)
        hull() {{
            translate([-cover_t + (3 + cover_t), -btn_clearance - cover_t + (3 + cover_t), -cover_t])
                cylinder(r=3+cover_t, h=ch + cover_t);
            translate([cw + cover_t - (3 + cover_t), -btn_clearance - cover_t + (3 + cover_t), -cover_t])
                cylinder(r=3+cover_t, h=ch + cover_t);
                
            // Back edges (not fully rounded because the chassis is flat on the back, but let's round them a bit)
            translate([-cover_t + (3 + cover_t), D - (3 + cover_t), -cover_t])
                cylinder(r=3+cover_t, h=ch + cover_t);
            translate([cw + cover_t - (3 + cover_t), D - (3 + cover_t), -cover_t])
                cylinder(r=3+cover_t, h=ch + cover_t);
        }}
        
        // Inner Chassis Cavity (Also rounded to match chassis perfectly)
        hull() {{
            translate([3, -btn_clearance + 3, 0])
                cylinder(r=3, h=ch + 0.1);
            translate([cw - 3, -btn_clearance + 3, 0])
                cylinder(r=3, h=ch + 0.1);
                
            translate([3, D - 3, 0])
                cylinder(r=3, h=ch + 0.1);
            translate([cw - 3, D - 3, 0])
                cylinder(r=3, h=ch + 0.1);
        }}
        
        // Cut off the back face so it's a U-shape (Open at Y = D)
        // We cut from Y = D to Y = D + 10 to ensure it's completely open
        translate([-cover_t - 5, D, -cover_t - 5])
            cube([cw + 2*cover_t + 10, 10, ch + cover_t + 10]);
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
    for sx, sy in []: # No screws in faceplate or dummy PCB!
        dummy_scad += f"            translate([{sx:.3f}, {sy:.3f}, -0.1]) cylinder(d=3.2, h=2.0, $fn=16);\n"
        
    dummy_scad += f"""
        }}
    }}


    // Sharp Memory LCD Base (White)
    color("White") {{
        translate([{disp_x:.3f}, {disp_y:.3f}, 1.6]) 
            translate([-{DISP_W:.3f}/2, -{DISP_H:.3f}/2, 0])
            cube([{DISP_W:.3f}, {DISP_H:.3f}, {DISP_T - 0.4:.3f}]);
    }}

    // Sharp LCD Active Glass Area (Black)
    color("Black") {{
        translate([{disp_x:.3f}, {disp_y:.3f}, 1.6 + {DISP_T - 0.4:.3f}]) 
            translate([-{ACTIVE_W:.3f}/2, -{ACTIVE_H:.3f}/2, 0])
            cube([{ACTIVE_W:.3f}, {ACTIVE_H:.3f}, 0.4]);
    }}

    // Tactile Switches (6.0 x 3.5 x 1.0mm body + 3.0x0.5mm plunger -> 1.5mm total Z-height)
    color("Silver") {{
"""
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            dummy_scad += f"""        translate([{ox:.3f}, {oy:.3f}, 1.6]) {{
            translate([-3.0, -1.75, 0]) cube([6.0, 3.5, 1.0]);
            translate([0, 0, 1.0]) cylinder(d=3.0, h=0.5);
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

    print("SCAD files generated:")
    print("  Faceplate (MJF): FACE-DOWN print (Z=3.0 on bed). ZERO overhangs.")
    print("  Faceplate (FDM): FACE-DOWN print (Z=3.0 on bed). ZERO overhangs (no supports needed!).")
    print("  Chassis:        STANDING on keypad edge. Flat 10mm uniform depth. Side grooves for cover.")
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
        res = subprocess.run(["/usr/local/bin/openscad", "-o", dst, src], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            print(f"  ✓ {label}.stl")
        else:
            print(f"  ✗ {label} ERRORS:\n{res.stderr[-800:]}")

    mfg_3d = "output/WatchCalc32_PCBWay_Manufacturing/3D_Printing_Files"
    os.makedirs(mfg_3d, exist_ok=True)
    for name, scad_file, stl_file in tasks:
        # print(f"  Building {name} ...")
        # print(["/usr/local/bin/openscad", "-o", stl_file, scad_file], check=True)
        pass
    print("Done generating SCAD files!")
