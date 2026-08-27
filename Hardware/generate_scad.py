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

    sy = y_max - (fp.GetPosition().y / 1e6)
    if ref.startswith("SOFT"):
        soft_keys.append({'ref': ref, 'x': sx, 'y': sy})
    elif ref.startswith("B") and len(ref) <= 3 and ref[1:].isdigit():
        buttons.append({'ref': ref, 'x': sx, 'y': sy})
    elif "Disp" in ref or "OLED" in ref or ref == "J1":
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
    # Row 0: Soft keys (blank — function shown on vinyl sticker only)
    ["", "", "", "", "", ""],
    # Row 1: Math functions (≤2 chars each for 0.4mm nozzle)
    ["Sx", "ex", "LN", "yx", "1x", "S+"],
    # Row 2: Store/Recall/Trig
    ["ST", "RC", "Rv", "SI", "CO", "TA"],
    # Row 3: ENTER (full word — spans ST+RC width), then 2-char labels
    ["ENTER", "xy", "+-", "E", "<-"],
    # Rows 4–7: Numpad
    ["XQ", "7", "8", "9", "/"],
    ["f", "4", "5", "6", "x"],
    ["g", "1", "2", "3", "-"],
    ["C", "0", ".", "PT", "+"],
]
for r_idx, row in enumerate(rows):
    for c_idx, b in enumerate(row):
        lbl = (labels[r_idx][c_idx]
               if r_idx < len(labels) and c_idx < len(labels[r_idx]) else "")
        b['label'] = lbl
        if r_idx < 4:
            b['w'] = 7.5
            b['h'] = 6.0
        else:
            b['w'] = 8.5
            b['h'] = 6.5

# --- Compute ENTER width to span ST (row2[0]) + RC (row2[1]) ---
# After X-mirror: ox = fp_w - (b['x'] + pad_x). The mirrored positions of
# ST and RC determine the left/right edges that ENTER must span.
# We do this AFTER pad_x is computed (below in generate_scad), so store the
# raw PCB x values now for later use.
_enter_btn = None
_st_btn    = None
_rc_btn    = None
if len(rows) >= 4 and len(rows[3]) >= 1:
    _enter_btn = rows[3][0]   # ENTER = first in row 3 (sorted by PCB x)
if len(rows) >= 3 and len(rows[2]) >= 2:
    _st_btn = rows[2][0]      # ST = first in row 2
    _rc_btn = rows[2][1]      # RC = second in row 2

# ─────────────────────────────────────────────────────────
# Global constants & Component Geometry
# ─────────────────────────────────────────────────────────
WALL   = 1.4   # Base wall thickness (slimmed down for premium look)
# Target Assembled Width = 80.0mm. TPU cover adds 2.4mm, so bare chassis must be 77.6mm.
cw = 74.4
fp_w = cw - 2*WALL - 0.4

# The PCB should have a 5mm border from the outer chassis wall.
# That means pcb_width should ideally be 70.0mm (80.0 - 10.0).
# pad_left is the distance from fp_w to pcb_width.
pad_left = (fp_w - pcb_width) / 2
pad_right = pad_left

# Target Assembled Length = 148.0mm. TPU bottom adds 1.2mm. Bare chassis = 146.8mm.
# Bare chassis = ch + cap_t_val = (fp_h + WALL) + 2.0 = fp_h + 1.4 + 2.0 = fp_h + 3.4.
# 146.8 = fp_h + 3.4 -> fp_h = 143.4mm.
fp_h = 143.4

# pcb_height is 137.0mm. Total padding = 143.4 - 137.0 = 6.4mm.
pad_bottom = 3.2

J1_Y_OFFSET = 0

corner = 6.0

# Internal Component Heights (mm)
TACTILE_H = 1.6   # 1.5mm switches + 0.1mm gap for sliding clearance
PCB_T     = 1.6   # PCB thickness
BATT_H    = 4.0   # Clearance for CR2032 battery holder
plate_t   = 2.0   # Faceplate base thickness (Reduced for slim profile)
FRONT_LIP = 1.0   # Structural retaining bezel

CHASSIS_D = 15.0  # Set explicitly to 15.0mm (matches HP-32SII limit) for extra internal room

# Display Geometry: EastRising 2.5" ERC13265FS-1
ACTIVE_W = 56.73
ACTIVE_H = 27.92
DISP_W   = 69.00
DISP_H   = 41.50
DISP_T   = 2.80     # Reduced from 5.20 to 2.80 for bare COG display without backlight

pad_x = pad_left
pad_y = pad_bottom
# The J1 footprint is at X=35.075 on the PCB.
# Because the faceplate's front face points toward -Z, +X points LEFT when viewed from the front.
# To place the display correctly from the left edge, we must mirror it: fp_w - distance_from_left.
disp_x = fp_w - (pad_left + 35.075)
# Plan faceplate display window perfectly from the PCB Display/J1 header
if disp:
    disp_y = disp['y'] + J1_Y_OFFSET + pad_bottom + 5.35 # J1 is 5.35mm below the center of the OLED screen window
else:
    disp_y = 123.50
PCB_SCREW_INSET = 7.0
chassis_screws = [
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
    py_fp_w = fp_w
    py_fp_h = fp_h
    py_WALL = WALL
    py_ch = py_fp_h + 0.85
    py_cw = py_fp_w + 2*py_WALL
    py_offset_x = (py_cw - py_fp_w) / 2
    py_offset_z = (py_ch - py_fp_h) / 2

    # ═══════════════════════════════════════════════════════
    # FACEPLATE — printed FACE-DOWN
    # Z=3.0 is the FRONT of the faceplate (flat on build plate).
    # Keys face DOWN. 
    # ═══════════════════════════════════════════════════════
    gap         = 0.60   # print-in-place clearance
    pt          = 2.0    # Faceplate overall thickness
    
    # Plunger dimensions (Base of the button)
    pw = 6.0
    ph = 4.0

    faceplate = f"""
// WatchCalc 32 Faceplate — Print FACE-UP on the bed (Z=0 on bed)
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

module cross_profile(w, h, depth, r) {{
    translate([-w/2, -3.2/2, 0]) cube([w, 3.2, depth]);
    translate([-3.2/2, -h/2, 0]) cube([3.2, h, depth]);
}}

// ─────────────────────────────────────────────────────────────────────────────
// SEGMENT BAR FONT — LCD / 7-segment style. Every glyph is composed of
// thick rectangular bars only (NO pixels, NO curves, NO diagonals).
// Each bar = one cube → printer makes 4 direction changes per stroke max.
// Character grid: H=4.0mm tall, W=2.8mm wide, T=0.60mm stroke, G=0.12mm gap.
// ─────────────────────────────────────────────────────────────────────────────
SH = 4.2;   // segment char height — slightly taller for legibility
SW = 3.0;   // segment char width
ST = 0.70;  // stroke thickness — 1.75× nozzle, clean print
SG = 0;     // NO gap — corners intentionally overlap so letters are one connected body
SD = 0.65;  // tool cut depth (cap is 0.8mm; 0.65mm leaves 0.15mm floor)

// Segments — corners overlap so each letter is fully connected (one slicer island per letter)
module s_top()  {{ translate([0,       SH-ST,     0]) cube([SW,    ST,   SD]); }}
module s_mid()  {{ translate([0,       SH/2-ST/2, 0]) cube([SW,    ST,   SD]); }}
module s_bot()  {{ translate([0,       0,         0]) cube([SW,    ST,   SD]); }}
module s_tl()   {{ translate([0,       SH/2,      0]) cube([ST, SH/2,   SD]); }}  // upper-left vert
module s_tr()   {{ translate([SW-ST,   SH/2,      0]) cube([ST, SH/2,   SD]); }}  // upper-right vert
module s_bl()   {{ translate([0,       0,         0]) cube([ST, SH/2,   SD]); }}  // lower-left vert
module s_br()   {{ translate([SW-ST,   0,         0]) cube([ST, SH/2,   SD]); }}  // lower-right vert
module s_cv()   {{ translate([SW/2-ST/2, 0,       0]) cube([ST, SH,     SD]); }}  // full center vert
module s_lv()   {{ translate([0,       0,         0]) cube([ST, SH,     SD]); }}  // full left vert
module s_rv()   {{ translate([SW-ST,   0,         0]) cube([ST, SH,     SD]); }}  // full right vert
module s_dot()  {{ translate([SW/2-ST/2, 0,       0]) cube([ST, ST,     SD]); }}

// ── Glyph modules ───────────────────────────────────────────────────────────
module g_0()  {{ s_top(); s_tl(); s_tr(); s_bl(); s_br(); s_bot(); }}
module g_1()  {{ s_tr(); s_br(); }}
module g_2()  {{ s_top(); s_tr(); s_mid(); s_bl(); s_bot(); }}
module g_3()  {{ s_top(); s_tr(); s_mid(); s_br(); s_bot(); }}
module g_4()  {{ s_tl(); s_tr(); s_mid(); s_br(); }}
module g_5()  {{ s_top(); s_tl(); s_mid(); s_br(); s_bot(); }}
module g_6()  {{ s_top(); s_tl(); s_mid(); s_bl(); s_br(); s_bot(); }}
module g_7()  {{ s_top(); s_tr(); s_br(); }}
module g_8()  {{ s_top(); s_tl(); s_tr(); s_mid(); s_bl(); s_br(); s_bot(); }}
module g_9()  {{ s_top(); s_tl(); s_tr(); s_mid(); s_br(); s_bot(); }}
module g_A()  {{ s_top(); s_tl(); s_tr(); s_mid(); s_bl(); s_br(); }}
module g_C()  {{ s_top(); s_tl(); s_bl(); s_bot(); }}
module g_E()  {{ s_top(); s_tl(); s_mid(); s_bl(); s_bot(); }}
module g_F()  {{ s_top(); s_tl(); s_mid(); s_bl(); }}
module g_G()  {{ s_top(); s_tl(); s_bl(); s_br(); s_mid(); s_bot(); }}
module g_H()  {{ s_tl(); s_tr(); s_mid(); s_bl(); s_br(); }}
module g_I()  {{ s_top(); s_cv(); s_bot(); }}
module g_J()  {{ s_tr(); s_br(); s_bl(); s_bot(); }}
module g_L()  {{ s_tl(); s_bl(); s_bot(); }}
module g_N()  {{ s_top(); s_lv(); s_rv(); s_bot(); }}  // box-N
module g_O()  {{ g_0(); }}
module g_P()  {{ s_top(); s_tl(); s_tr(); s_mid(); s_bl(); }}
module g_Q()  {{ g_9(); }}  // 9-style Q
module g_R()  {{ s_top(); s_tl(); s_tr(); s_mid(); s_bl(); s_br(); }}  // like A
module g_S()  {{ g_5(); }}
module g_T()  {{ s_top(); s_cv(); }}
module g_U()  {{ s_tl(); s_tr(); s_bl(); s_br(); s_bot(); }}
module g_V()  {{ s_bl(); s_br(); s_bot(); }}
module g_X()  {{ s_tl(); s_tr(); s_mid(); s_bl(); s_br(); }}  // H-style X
module g_Y()  {{ s_tl(); s_tr(); s_mid(); s_br(); s_bot(); }}
module g_plus()  {{ s_cv(); s_mid(); }}
module g_minus() {{ s_mid(); }}
module g_slash() {{ s_tr(); s_mid(); s_bl(); }}
module g_dot()   {{ s_dot(); }}
module g_lt()    {{ s_tr(); s_mid(); s_br(); }}  // arrow left ‹
module g_pm()    {{ s_cv(); s_mid(); s_bot(); }} // ±

// ── Dispatcher ──────────────────────────────────────────────────────────────
module seg_char(c) {{
    if      (c=="0") g_0();  else if (c=="1") g_1();  else if (c=="2") g_2();
    else if (c=="3") g_3();  else if (c=="4") g_4();  else if (c=="5") g_5();
    else if (c=="6") g_6();  else if (c=="7") g_7();  else if (c=="8") g_8();
    else if (c=="9") g_9();  else if (c=="A") g_A();  else if (c=="C") g_C();
    else if (c=="E") g_E();  else if (c=="F") g_F();  else if (c=="G") g_G();
    else if (c=="H") g_H();  else if (c=="I") g_I();  else if (c=="J") g_J();
    else if (c=="L") g_L();  else if (c=="O") g_O();  else if (c=="P") g_P();
    else if (c=="Q") g_Q();  else if (c=="R") g_R();  else if (c=="S") g_S();
    else if (c=="U") g_U();  else if (c=="T") g_T();
    else if (c=="+") g_plus(); else if (c=="-") g_minus(); else if (c=="/") g_slash();
    else if (c==".") g_dot();  else if (c=="<") g_lt();    else if (c=="±") g_pm();
    // lowercase aliases (same shape at this scale)
    else if (c=="v") g_V();     else if (c=="x") g_X();
    else if (c=="f") g_F();     else if (c=="g") g_9();
    else if (c=="y") g_Y();     else if (c=="e") g_E();
    else if (c=="s") g_S();     else if (c=="n") g_N();
    else if (c=="r") {{ s_top(); s_tl(); s_mid(); s_bl(); }}  // small r
    else if (c=="t") g_T();
}}

// ── Word renderer — centers up to 5 chars, auto-scales for ENTER ────────────
module seg_word(word, avail_w=7.0) {{
    n = len(word);
    // For ENTER (5 chars), compress horizontally to fit
    char_w = (n <= 2) ? SW : (n == 3) ? SW * 0.85 : (n == 4) ? SW * 0.75 : SW * 0.62;
    gap    = (n <= 2) ? 0.5 : 0.35;
    total_w = n * char_w + (n-1) * gap;
    sx = (total_w > avail_w) ? (avail_w / total_w) : 1.0;
    sy = (n > 3) ? ((char_w / SW) * 1.0) : 1.0;  // keep aspect ratio
    scale([sx, sy, 1])
    translate([-total_w/2, -SH/2, 0])
    for (i = [0 : n-1]) {{
        translate([i * (char_w + gap), 0, 0])
        scale([char_w / SW, 1, 1])
            seg_char(word[i]);
    }}
}}

// ── Button cap with sunken 7-segment label ───────────────────────────────────
// Local Z mapping to Final Print Z: Final_Z = 2.0 - Local_Z
module key_button(w, h, label="") {{
    difference() {{
        union() {{
            // Cap (Local Z=-0.6..0.0 -> Final Z=2.0..2.6)
            translate([0, 0, -0.6]) squircle_centered(w, h, 0.6, 1.5);
            
            // Taper 2 (Local Z=0.0..0.6 -> Final Z=1.4..2.0)
            hull() {{
                translate([0, 0, 0.0]) squircle_centered(w + 1.2, h + 1.2, 0.01, 1.5);
                translate([0, 0, 0.6]) cross_profile(w + 1.2, h + 1.2, 0.01, 1.5);
            }}

            // Shaft (Local Z=0.6..1.0 -> Final Z=1.0..1.4)
            translate([0, 0, 0.6]) cross_profile(w + 1.2, h + 1.2, 0.4, 1.5);
            
            // Taper 1 (Local Z=1.0..1.6 -> Final Z=0.4..1.0)
            hull() {{
                translate([0, 0, 1.0]) cross_profile(w + 1.2, h + 1.2, 0.01, 1.5);
                translate([0, 0, 1.6]) squircle_centered(w + 1.2, h + 1.2, 0.01, 1.5);
            }}
            
            // Base Squircle (Local Z=1.6..2.0 -> Final Z=0.0..0.4)
            translate([0, 0, 1.6]) squircle_centered(w + 1.2, h + 1.2, 0.4, 1.5);
        }}
        // Sunken label on top of cap (Local Z=-0.6 to -0.6+SD)
        // Since it's rotated 180 over X, we MUST mirror the text in Local space
        if (label != "") {{
            translate([0, 0, -0.6 - 0.01])
                mirror([1, 0, 0])
                    seg_word(label, w - 1.5);
        }}
        
        // Chamfered guide hole at the bottom (Local Z=2.0 down to 0.5)
        // 3.0mm diameter at Local Z=2.0 (Final Z=0.0), tapering to 0 at Local Z=0.5 (Final Z=1.5)
        translate([0, 0, 0.5])
            cylinder(d1=0, d2=3.0, h=1.5 + 0.01, $fn=16);
    }}
}}

module button_pocket(w, h) {{
    // We add 0.4mm clearance per side -> width + 0.8mm
    // Base cavity (Local Z=1.59..2.01 -> Final Z=-0.01..0.41)
    translate([0, 0, 1.59]) squircle_centered(w + 2.0, h + 2.0, 0.42, 1.7);
    
    // Taper 1 cavity (Local Z=1.0..1.6)
    hull() {{
        translate([0, 0, 1.0]) cross_profile(w + 1.2, h + 1.2, 0.01, 1.7);
        translate([0, 0, 1.6]) squircle_centered(w + 2.0, h + 2.0, 0.01, 1.7);
    }}

    // Shaft cavity (Local Z=0.6..1.0)
    translate([0, 0, 0.6]) cross_profile(w + 1.2, h + 1.2, 0.4, 1.7);
    
    // Taper 2 cavity (Local Z=-0.01..0.6)
    hull() {{
        translate([0, 0, -0.01]) squircle_centered(w + 0.8, h + 0.8, 0.01, 1.7);
        translate([0, 0, 0.6]) cross_profile(w + 1.2, h + 1.2, 0.01, 1.7);
    }}
}}

module faceplate_body() {{
    // Faceplate body shrunk by 0.1mm each side (X) and 0.1mm front (Y=0) for sliding clearance.
    // A 1mm chamfer on the leading edge (Y=fp_h side = top when printed face-up) guides it in.
    FP_CLR = 0.20;  // clearance per side — increased 0.1→0.2mm for easier faceplate removal
    translate([FP_CLR, FP_CLR, 0])
        difference() {{
            cube([fp_w - 2*FP_CLR, {fp_h + 0.85:.3f} - FP_CLR, pt]);
            // Chamfer on leading edge (the end that slides into chassis first)
            translate([0, {fp_h + 0.85:.3f} - FP_CLR - 1.0, 0])
                rotate([45, 0, 0])
                    cube([fp_w - 2*FP_CLR, 1.5, 1.5]);
        }}
}}


module faceplate() {{
    difference() {{
        faceplate_body();

        // Bezel Window — chamfer visible from the front, LCD flush at the front face.
        // FRONT face (Z=-0.1 assembly = top of face-up print): LARGE = DISP_W x DISP_H.
        //   The full LCD module footprint is visible through the front opening.
        //   Chamfer wall angles INWARD going toward the back — faces the viewer → visible from front.
        // BACK face (Z=pt+0.1 assembly = build plate): SMALL = ACTIVE_W x ACTIVE_H.
        //   Active-area ledge: positions the LCD and hides the PCB border behind the faceplate.
        // Chamfer wall angle ≈ 33.7° — printable without supports.
        hull() {{
            translate([{disp_x:.3f} - {DISP_W:.3f}/2, {disp_y:.3f} - {DISP_H:.3f}/2, -0.1])
                cube([{DISP_W:.3f}, {DISP_H:.3f}, 0.01]);
            translate([{disp_x:.3f} - {ACTIVE_W:.3f}/2, {disp_y:.3f} - {ACTIVE_H:.3f}/2, pt + 0.1])
                cube([{ACTIVE_W:.3f}, {ACTIVE_H:.3f}, 0.01]);
        }}

        // Button pockets
"""
    fp_pad_x = (fp_w - pcb_width) / 2
    fp_pad_y = (fp_h - pcb_height) / 2

    # ── ENTER width: span exactly from ST's outer-left to RC's outer-right
    if _enter_btn is not None and _st_btn is not None and _rc_btn is not None:
        cx_st = _st_btn['x']
        cx_rc = _rc_btn['x']
        st_half = _st_btn['w'] / 2
        rc_half = _rc_btn['w'] / 2
        enter_left  = min(cx_st, cx_rc) - st_half
        enter_right = max(cx_st, cx_rc) + rc_half
        _enter_btn['w'] = enter_right - enter_left
        # We do NOT set _enter_cx. We just use b['x'] which is already perfectly centered at 13.10.

    for row in rows:
        for b in row:
            ox = fp_w - (pad_left + b['x'])
            oy = pad_bottom + b['y']
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

    for row in rows:
        for b in row:
            ox = fp_w - (pad_left + b['x'])
            oy = pad_bottom + b['y']
            lbl = b.get('label', '').replace('"', '\\"')
            btn_str = f"        translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \"{lbl}\");\n"
            faceplate_mjf += btn_str
            faceplate_fdm += btn_str

    closing_str = f"""    }}
}}
// Render faceplate face-UP on the bed. translate([fp_w,0,pt]) cancels the X-flip from
// rotate([0, 180, 0]) so the model lands at X=0..fp_w, Z=0..pt (all positive coords).
// This specific rotation keeps Y upright so it opens in the slicer with the Display at the top,
// ENTER on the left, and Text completely readable and upright!
translate([{fp_w:.3f}, 0, {pt:.3f}]) rotate([0, 180, 0]) faceplate_assembly();
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
            ox = pad_left + b['x']
            oy = pad_bottom + b['y']
            lbl = b.get('label', '').replace('"', '\\"')
            btn_str = f"        translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \"{lbl}\");\n"
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
ch   = {fp_h + 0.85:.3f};  // trimmed height: fp_h+0.85 = 148.000mm (HP32SII limit)
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
            translate([8, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-8, D-3, 0]) cylinder(r=3, h=ch);
        }}
        
        // Tier 1: Faceplate Cavity — +0.4mm wider (0.2mm/side) for removable faceplate clearance
        translate([offset_x - 0.2, {FRONT_LIP} - 0.2, wall])
            cube([fp_w + 0.4, pt + 0.2, ch + 0.1]);
            
        // Middle Cavity: Hollows out the center for the Display to slide down!
        // The display glass is 71.2mm wide, so we need a 72.0mm cavity!
        translate([(cw - 72.0)/2, {FRONT_LIP} + pt - 0.1, wall])
            cube([72.0, {TACTILE_H} + 0.2, ch + 0.1]);
            
        // Tier 2: PCB Cavity — +0.4mm wider (0.2mm/side) so PCB slides in without sanding.
        // +0.2mm deeper for top-face clearance.
        translate([(cw - pcb_w)/2 - 0.2, {FRONT_LIP} + pt + {TACTILE_H} - 0.2, wall])
            cube([pcb_w + 0.4, {PCB_T} + 0.4, ch + 0.1]);
            
        // Tier 2.5: PCB Trace Clearance
        // Hollows out 0.5mm behind the PCB so traces/vias don't scratch the back wall.
        translate([(cw - pcb_w + 4.0)/2 - 0.1, {FRONT_LIP} + pt + {TACTILE_H} + {PCB_T} - 0.1, wall])
            cube([pcb_w - 4.0 + 0.2, 0.5 + 0.1, ch + 0.1]);
            
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
        // Uses a hull() of two cutouts to create a 45-degree chamfered slope on the inner edge of the bezel rails
        // This eliminates the sharp 90-degree cliff, allowing fingers to smoothly slide off the rails.
        hull() {{
            // Inner cutout (narrower, at the faceplate surface)
            // Leaves a 1.0mm wide bezel overhang holding the faceplate in
            translate([offset_x + 1.0, {FRONT_LIP} - 0.1, wall + 1.0])
                cube([fp_w - 2.0, 0.4, ch + 0.1]);
            
            // Outer cutout (wider, at the top surface of the chassis)
            // By expanding it by FRONT_LIP on each side, it creates a precise 45-degree chamfer
            translate([offset_x + 1.0 - {FRONT_LIP}, -0.1, wall + 1.0 - {FRONT_LIP}])
                cube([fp_w - 2.0 + 2*{FRONT_LIP}, 0.2, ch + 0.1]);
        }}
            
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

        // ── TITLE ETCHING (Back of Chassis) ──────────────────────────────
        translate([cw/2, D + 0.1, ch * 0.75])
            rotate([90, 0, 180])
                linear_extrude(1.0)
                    text("StackCalc 32", size=6, font="Arial:style=Bold", halign="center", valign="center");
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
            translate([8, D-3, 0]) cylinder(r=3, h=ch);
            translate([cw-8, D-3, 0]) cylinder(r=3, h=ch);
        }"""
    hull_new = """        hull() {
            // Front edge (rounded corners, full height)
            translate([3, 3, 0]) cylinder(r=3, h=ch);
            translate([cw-3, 3, 0]) cylinder(r=3, h=ch);
            
            // Back edge (tapered — shallower at keypad end to save material)
            // Minimum depth at Z=0 must clear all internal cuts:
            //   Tier 2.5 ends at Y = FRONT_LIP + pt + TACTILE_H + PCB_T + 0.5
            //                     = 1.0 + 2.0 + 1.6 + 1.6 + 0.5 = 6.7mm
            // So back wall must be at least Y=9.5mm (center at Y=6.5, r=3)
            translate([3, 6.5, 0]) cylinder(r=3, h=0.1);
            translate([cw-3, 6.5, 0]) cylinder(r=3, h=0.1);
            
            // At Z=ch (display end), full depth D (center at Y=D-3)
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

    cap_t_val = 2.0      # end cap plate thickness (thinned down to save length)
    bezel_lip = plate_t   # front lip extends 4mm forward to match bezel

    top_cap = f"""
// WatchCalc 32 End Cap — v8 (FLUSH PLUG inside chassis)
// Cap extends from Z=ch-cap_t to Z=ch. 
// Secured by lateral M3 screws at Z=138.550.
$fn = 24;
cw    = {cw:.3f};
D     = {CHASSIS_D:.3f};
wall  = {WALL:.3f};
pt    = {pt:.3f};
cap_t = {cap_t_val};
ch    = {py_ch:.3f}; // Exact physical height of the chassis!

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
        // The main roof sits flush on top of the chassis bezel and faceplate.
        translate([wall + 4.0, 0, ch])
            cube([cw - 2*wall - 8.0, {FRONT_LIP} + pt, cap_t]);
            
        // Uses a hull to create a 45-degree wedge that perfectly mates with the Faceplate's chamfer!
        // This female wedge locks into the faceplate's male chamfer, holding it firmly in place against the bezel.
        hull() {{
            translate([wall + 4.0, {FRONT_LIP}, ch])
                cube([cw - 2*wall - 8.0, 1.0, 0.01]);
            translate([wall + 4.0, {FRONT_LIP}, ch - 1.0])
                cube([cw - 2*wall - 8.0, 0.01, 0.01]);
        }}

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
        // Restored to CR2032 coin cell (20.0mm diameter x 3.2mm thick) + wire clearance.
        // Tapered to perfectly respect the 2.0mm back chassis wall without punching through!
        // The coin cell's round edge perfectly avoids the thinnest part of the taper at the bottom.
        // Attached to the Right Screw Boss to print as one solid piece and clear the Pico MCU
        translate([{rx:.3f} - 3.0 - 24.0, 0.8 + {pt:.3f} + {TACTILE_H} + {PCB_T}, ch - 28.5]) {{
            difference() {{
                // Outer block (Tapered)
                hull() {{
                    cube([24, 11.0 - ({pt} + {TACTILE_H} + {PCB_T}), 0.1]);
                    translate([0, 0, 26 + 0.1]) cube([24, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5), 0.1]); // Goes ALL THE WAY UP through the cap to let wires out!
                }}
                // Inner hollow (1.2mm walls on sides, back, and bottom. OPEN on front to PCB and OPEN on top for wires!)
                translate([1.2, -0.1, 1.2])
                    hull() {{
                        cube([24 - 2.4, 11.0 - ({pt} + {TACTILE_H} + {PCB_T}) - 1.2, 0.1]);
                        translate([0, 0, 26 + 0.2]) cube([24 - 2.4, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5) - 1.2, 0.1]);
                    }}
                    
                // Wire exit channel on the RIGHT side to route to the JST connector!
                translate([24 - 2.4, -0.1, 26 - cap_t - 5.0])
                    cube([5.0, 10.0, cap_t + 5.0]);
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
cover_t = 1.2;
btn_clearance = 1.2; // Buttons stick out 1.0mm past the lip, so 1.2mm bumper protects them

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
    buttons_scad = ""
    for row in rows:
        for b in row:
            buttons_scad += f"translate([{b['x']:.1f}, {b['y']:.1f}, 2.0]) rotate([0, 180, 0]) key_button({b['w']}, {b['h']}, \"{b['label']}\");\n"

    if False:
        pass

    # ---------------------------------------------------------
    # DUMMY PCB FOR ALIGNMENT
    # ---------------------------------------------------------
    dummy_scad = f"""
// ── DUMMY PCB FOR ALIGNMENT TESTING ──────────────────────────────
$fn=24;
module dummy_pcb_board_local() {{
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
        translate([{56.15:.3f}, {140.0 + pad_y:.3f}, 0]) 
            translate([-6.0/2, -7.8/2, -4.8])
            cube([6.0, 7.8, 4.8]);
    }}
}}

// Place the board-local model in the chassis coordinate system.
translate([2, 7.7, 3])
    rotate([90, 0, 0])
        dummy_pcb_board_local();
"""
    with open("designs/dummy_pcb.scad", "w") as f:
        f.write(dummy_scad)

    print("SCAD files generated:")
    print("  Faceplate (MJF): FACE-UP print (front face on top). ZERO overhangs.")
    print("  Faceplate (FDM): FACE-UP print (front face on top). Bezel chamfer visible from front.")
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

    import shutil
    openscad_bin = shutil.which("openscad") or "/usr/local/bin/openscad"

    for label, src, dst in tasks:
        print(f"  Building {label} ...")
        res = subprocess.run([openscad_bin, "-o", dst, src],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            print(f"  ✓ {label}.stl")
        else:
            print(f"  ✗ {label} ERRORS:\n{res.stderr[-800:]}")

    print("Done generating SCAD files!")
