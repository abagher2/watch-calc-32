import os
import sys
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
    ["√x", "e^x", "LN", "y^x", "1/x", "Σ+"],
    ["STO", "RCL", "R↓", "SIN", "COS", "TAN"],
    ["ENTER", "x<>y", "+/-", "E", "<-"],
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
        b['w']     = 9.0 if r_idx == 0 else (17.5 if lbl == "ENTER" else 9.5 if lbl in ("f","g","C") else 8.5)
        b['h']     = 5.5

# ─────────────────────────────────────────────────────────
# Global constants
# ─────────────────────────────────────────────────────────
fp_w   = pcb_width  + 8    # faceplate width
fp_h   = pcb_height + 8    # faceplate height
corner = 6.0

EINK_W = 65.0   # module width  (mm)
EINK_H = 30.2   # module height (mm)
disp_x = fp_w / 2
disp_y = (disp['y'] + 4) if disp else (fp_h - EINK_H / 2 - 5)

H_TOP  = 10.0    # chassis depth (flat, uniform — no taper)
H_BOT  = 10.0    # same as H_TOP (flat chassis)
WALL   = 2.0
CHASSIS_D = 10.0  # chassis depth shorthand

PCB_SCREW_INSET = 5.0
chassis_screws = [
    (5.0, 5.0), (fp_w - 5.0, 5.0),
    (5.0, fp_h - 5.0), (fp_w - 5.0, fp_h - 5.0),
]

def generate_scad():
    os.makedirs("designs/stl", exist_ok=True)

    # ═══════════════════════════════════════════════════════
    # FACEPLATE — printed FACE-UP
    # Z=0 is the BACK of the faceplate (flat on build plate).
    # Keys face UP. 
    # Plungers are at Z=0 (printing directly on bed).
    # Micro-supports bridge plunger and faceplate wall at Z=0.
    # ═══════════════════════════════════════════════════════
    gap         = 0.35   # print-in-place clearance
    plate_t     = 4.0    # faceplate base thickness (rim adds protection height)
    rim_h       = 4.0    # protective rim wall height above plate surface (keeps buttons safe)
    plunger_h   = 1.5    # Z=0.0 to 1.5
    stem_h      = 1.0    # Z=1.5 to 2.5
    diamond_h   = 2.0    # Z=2.5 to 4.5
    up_stem_h   = 1.0    # Z=4.5 to 5.5 (shortened to fit 4mm plate)
    wedge_h     = 1.5    # Z=5.5 to 7.0 (keycap, 1mm taper HP style)
    
    # Plunger dimensions (large for bed adhesion and switch pressing)
    pw = 6.5
    ph = 5.0

    faceplate = f"""
// WatchCalc 32 Faceplate — Print FACE-UP
// Back of faceplate is on Z=0 (build plate). Keys face up.
// Micro-supports connect plungers to faceplate for stability.
$fn = 60;
fp_w = {fp_w:.3f};
fp_h = {fp_h:.3f};
cr   = {corner};
pt   = {plate_t};    
GAP  = {gap};        

module key_button(w, h, label) {{
    bw = w;  
    bh = h;  
    dw = bw + 1.0;  // diamond width
    dh = bh + 1.0;  

    // Z=0.0 to 1.5 : Plunger (rectangular pad)
    translate([0, 0, {plunger_h/2}])
        cube([{pw}, {ph}, {plunger_h}], center=true);

    // Z=1.5 to 2.5 : Stem (rectangular)
    translate([0, 0, {plunger_h + stem_h/2}])
        cube([{pw}, {ph}, {stem_h}], center=true);

    // Z=2.5 to 4.5 : Diamond Flange (chamfered <> for no-support printing)
    // Lower half expands
    translate([0, 0, {plunger_h + stem_h}])
        hull() {{
            cube([{pw}, {ph}, 0.01], center=true);
            translate([0, 0, {diamond_h/2}]) cube([dw, dh, 0.01], center=true);
        }}
    // Upper half contracts
    translate([0, 0, {plunger_h + stem_h + diamond_h/2}])
        hull() {{
            cube([dw, dh, 0.01], center=true);
            translate([0, 0, {diamond_h/2}]) cube([bw, bh, 0.01], center=true);
        }}

    // Z=4.5 to 6.0 : Upper Stem
    translate([0, 0, {plunger_h + stem_h + diamond_h + up_stem_h/2}])
        cube([bw, bh, {up_stem_h}], center=true);

    // Z=6.0 to 8.5 : Key Cap (Wedge shape, HP style)
    // Flat top surface, sloped front face.
    translate([0, 0, {plunger_h + stem_h + diamond_h + up_stem_h}])
        hull() {{
            // Base of the keycap
            translate([-bw/2, -bh/2, 0]) cube([bw, bh, 0.01]);
            // Top of the keycap (smaller in Y, shifted back)
            translate([-bw/2 + 0.5, -bh/2 + 2.5, {wedge_h}]) cube([bw - 1.0, bh - 3.0, 0.01]);
        }}
}}

module micro_supports(x, y, w, h) {{
    // Break-away tabs linking plunger to faceplate wall at Z=0
    // 0.4mm thick (2 layers), 1.0mm wide
    // Left/Right
    translate([x - {pw/2 + gap/2}, y, 0.2]) cube([{gap}, 1.0, 0.4], center=true);
    translate([x + {pw/2 + gap/2}, y, 0.2]) cube([{gap}, 1.0, 0.4], center=true);
    // Top/Bottom
    translate([x, y - {ph/2 + gap/2}, 0.2]) cube([1.0, {gap}, 0.4], center=true);
    translate([x, y + {ph/2 + gap/2}, 0.2]) cube([1.0, {gap}, 0.4], center=true);
}}

module button_pocket(x, y, w, h) {{
    bw = w;  bh = h;
    dw = bw + 1.0 + GAP*2;  
    dh = bh + 1.0 + GAP*2;

    // Z=0.0 to 2.5 : Lower hole for plunger/stem
    translate([x, y, {(plunger_h + stem_h)/2}])
        cube([{pw} + GAP*2, {ph} + GAP*2, {plunger_h + stem_h}], center=true);

    // Z=2.5 to 4.5 : Diamond cavity (chamfered <>)
    translate([x, y, {plunger_h + stem_h}])
        hull() {{
            cube([{pw} + GAP*2, {ph} + GAP*2, 0.01], center=true);
            translate([0, 0, {diamond_h/2}]) cube([dw, dh, 0.01], center=true);
        }}
    translate([x, y, {plunger_h + stem_h + diamond_h/2}])
        hull() {{
            cube([dw, dh, 0.01], center=true);
            translate([0, 0, {diamond_h/2}]) cube([bw + GAP*2, bh + GAP*2, 0.01], center=true);
        }}

    // Z=4.5 to 6.0 : Upper hole
    translate([x, y, {plunger_h + stem_h + diamond_h + up_stem_h/2}])
        cube([bw + GAP*2, bh + GAP*2, {up_stem_h + 0.1}], center=true);
}}

module faceplate_body() {{
    // Base plate — rim walls are on chassis now (DM32 style protection)
    // 0.3mm clearance on all edges allows smooth slide-in from display end
    hull() {{
        translate([cr, cr, 0])           cylinder(r=cr, h=pt);
        translate([fp_w-cr, cr, 0])      cylinder(r=cr, h=pt);
        translate([cr, fp_h-cr, 0])      cylinder(r=cr, h=pt);
        translate([fp_w-cr, fp_h-cr, 0]) cylinder(r=cr, h=pt);
    }}
}}


module faceplate() {{
    difference() {{
        faceplate_body();

        // Display window (Angled bezel to eliminate bridging)
        // The EINK module sits perfectly flush on the flat back (Z=0).
        ACTIVE_W = 49.0;
        ACTIVE_H = 24.0;
        POCKET_W = {EINK_W:.3f} + 1.0;
        POCKET_H = {EINK_H:.3f} + 1.0;
        hull() {{
            // Back of faceplate (Z=-0.1) fits the full display module
            translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, -0.1])
                cube([POCKET_W, POCKET_H, 0.01]);
            // Front of faceplate (Z=pt+0.1) is just the active area
            translate([{disp_x:.3f} - ACTIVE_W/2, {disp_y:.3f} - ACTIVE_H/2, pt + 0.1])
                cube([ACTIVE_W, ACTIVE_H, 0.01]);
        }}

        // Button pockets
"""
    for row in rows:
        for b in row:
            ox = b['x'] + 4   
            oy = b['y'] + 4
            faceplate += f"        button_pocket({ox:.3f}, {oy:.3f}, {b['w']}, {b['h']});\n"

    # No screw holes in faceplate — top cap lip retains faceplate and PCB


    faceplate += """
    }
}

// Render faceplate
faceplate();

// Render buttons and micro-supports
color("Silver") {
"""
    for row in rows:
        for b in row:
            ox = b['x'] + 4
            oy = b['y'] + 4
            faceplate += f"    translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \"{b['label']}\");\n"
            faceplate += f"    micro_supports({ox:.3f}, {oy:.3f}, {b['w']}, {b['h']});\n"

    faceplate += "}\n"

    with open("designs/faceplate.scad", "w") as f:
        f.write(faceplate)


    # ═══════════════════════════════════════════════════════
    # CHASSIS — FLAT SLEEVE STYLE
    # ═══════════════════════════════════════════════════════
    # Print orientation: stand on the keypad (bottom) edge.
    #   Z=0 = keypad end (on build plate), Z=ch = display/top end
    #   Front face (Y=0) open for faceplate. Back face (Y=D) solid + battery door.
    #   PCB slides in from top (Z=ch). Cradled by left/right PCB rails.
    #   Side grooves on left (X=0) and right (X=cw) walls accept sliding cover rails.
    #   M3 corner screw posts: straight holes (no angle — chassis is flat).
    #
    #   Total assembled thickness: CHASSIS_D(10) + plate_t(4) = 14mm target.

    import math
    D        = CHASSIS_D
    STANDOFF = 1.2
    PCB_T    = 1.6
    plate_t  = 4.0
    GCW = 2.0; GCD = 1.5; GR = 1.5; GY = 3.0
    junc_z = fp_h / 3.0
    batt_w = 40; batt_h = 25
    batt_z = fp_h - WALL - 30

    chassis = f"""
// WatchCalc 32 Chassis — v7
$fn = 40;
cw   = {fp_w:.3f};
ch   = {fp_h:.3f};
D    = {D:.3f};
wall = {WALL:.3f};
batt_w = {batt_w}; batt_h = {batt_h}; batt_z = {batt_z:.2f};
GCW = {GCW:.1f}; GCD = {GCD:.1f}; GR = {GR:.1f}; GY = {GY:.1f};
junc = {junc_z:.2f};

module chassis_shell() {{
    difference() {{
        cube([cw, D, ch]);
        translate([wall, -0.1, -0.1])
            cube([cw - 2*wall, D - wall + 0.1, ch - wall + 0.1]);
    }}
}}
module pcb_rails() {{
    rl = 1.5; yoff = {plate_t:.1f} + 0.5;
    translate([wall, yoff, {STANDOFF:.1f}])
        cube([rl, D - wall - yoff, ch - wall - {STANDOFF:.1f}]);
    translate([cw - wall - rl, yoff, {STANDOFF:.1f}])
        cube([rl, D - wall - yoff, ch - wall - {STANDOFF:.1f}]);
}}
module pcb_standoff() {{
    translate([wall + 1.5, {plate_t:.1f} + 0.5, 0])
        cube([cw - 2*(wall + 1.5), D - wall - ({plate_t:.1f} + 0.5), {STANDOFF:.1f}]);
}}
module rim_walls() {{
    rim_d = 4.0;
    translate([0, -rim_d, 0])        cube([wall, rim_d, ch]);
    translate([cw-wall, -rim_d, 0])  cube([wall, rim_d, ch]);
    translate([0, -rim_d, 0])        cube([cw, rim_d, wall]);
    translate([0, -rim_d, ch-wall])  cube([cw, rim_d, wall]);
}}
module cap_posts() {{
    py = D - wall - 1.5;
    translate([wall + 4,      py, 0]) cylinder(d=7, h=14);
    translate([cw - wall - 4, py, 0]) cylinder(d=7, h=14);
}}
module railway_grooves() {{
    translate([-0.1, GY, 0])          cube([GCD+0.1, GCW, ch]);
    translate([-0.1, GY+GCW+GR, 0])  cube([GCD+0.1, GCW, ch]);
    translate([0, GY, junc]) rotate([10,0,0])
        translate([-0.1, 0, 0]) cube([GCD+0.1, GCW, ch]);
    translate([0, GY+GCW+GR, junc]) rotate([10,0,0])
        translate([-0.1, 0, 0]) cube([GCD+0.1, GCW, ch]);
    translate([cw-GCD, GY, 0])          cube([GCD+0.1, GCW, ch]);
    translate([cw-GCD, GY+GCW+GR, 0])  cube([GCD+0.1, GCW, ch]);
    translate([cw, GY, junc]) rotate([10,0,0])
        translate([-GCD-0.1, 0, 0]) cube([GCD+0.1, GCW, ch]);
    translate([cw, GY+GCW+GR, junc]) rotate([10,0,0])
        translate([-GCD-0.1, 0, 0]) cube([GCD+0.1, GCW, ch]);
}}
module battery_door_rails() {{
    rail_w = 1.0; rail_d = 1.0;
    translate([cw/2 - batt_w/2 - rail_w, D - wall - rail_d, batt_z - 2])
        cube([rail_w, rail_d, batt_h + 4]);
    translate([cw/2 + batt_w/2, D - wall - rail_d, batt_z - 2])
        cube([rail_w, rail_d, batt_h + 4]);
}}
module chassis() {{
    difference() {{
        union() {{
            chassis_shell(); pcb_rails(); pcb_standoff();
            cap_posts(); rim_walls(); battery_door_rails();
        }}
        translate([cw/2 - batt_w/2, D - wall - 0.1, batt_z])
            cube([batt_w, wall + 0.2, batt_h]);
        translate([cw/2 - 5, D - wall - 0.1, ch - wall - 5])
            cube([10, wall + 0.2, 6]);
        py = D - wall - 1.5;
        translate([wall + 4,      py, -0.1]) cylinder(d=2.6, h=15);
        translate([cw - wall - 4, py, -0.1]) cylinder(d=2.6, h=15);
        railway_grooves();
    }}
}}
chassis();
"""

    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)


    # ═══════════════════════════════════════════════════════
    # TOP CAP — at keypad end (Z=0), seals faceplate + PCB
    # ═══════════════════════════════════════════════════════
    # The cap is placed at the KEYPAD END (bottom of device, Z=0).
    # Faceplate and PCB slide UP from Z=0, cap seals them in.
    # 2× M3 screws through cap plate in +Z direction into chassis cap posts.
    # Retention lips on front (Y=0) and back (Y=D) edges grip the edges
    # of the faceplate and PCB to prevent them sliding back out.

    top_cap = f"""
// WatchCalc 32 Top Cap — v4, keypad end (Z=0)
// ONE connected body (hull). Retention lips on inner front/back edges.
// 2x M3 clearance holes in +Z direction matching chassis cap posts.
// Print flat (this face down on bed).
$fn = 60;
cw = {fp_w:.3f};
D  = {CHASSIS_D:.3f};
cap_t = 3.0;
lip_d = 1.5;   // retention lip depth (downward, into chassis)
lip_t = 1.5;   // retention lip thickness

module top_cap() {{
    difference() {{
        union() {{
            // ── MAIN PLATE (single hull, fully rounded corners) ───────────
            hull() {{
                for(x=[3, cw-3], y=[3, D-3])
                    translate([x, y, 0]) cylinder(r=3, h=cap_t);
            }}
            // ── FRONT RETENTION LIP (grips faceplate bottom edge) ─────────
            // Lip projects -Z (downward into chassis) from plate underside.
            // Sits at Y=0 (front face of chassis).
            hull() {{
                translate([3, lip_t/2, -lip_d+0.5])   cylinder(r=0.5, h=lip_d);
                translate([cw-3, lip_t/2, -lip_d+0.5]) cylinder(r=0.5, h=lip_d);
                translate([3, lip_t/2, -0.5])          cylinder(r=0.5, h=0.5);
                translate([cw-3, lip_t/2, -0.5])        cylinder(r=0.5, h=0.5);
            }}
            // ── BACK RETENTION LIP (grips PCB bottom edge) ────────────────
            hull() {{
                translate([3, D-lip_t/2, -lip_d+0.5])   cylinder(r=0.5, h=lip_d);
                translate([cw-3, D-lip_t/2, -lip_d+0.5]) cylinder(r=0.5, h=lip_d);
                translate([3, D-lip_t/2, -0.5])           cylinder(r=0.5, h=0.5);
                translate([cw-3, D-lip_t/2, -0.5])         cylinder(r=0.5, h=0.5);
            }}
        }}
        // ── M3 CLEARANCE HOLES (+Z direction, match chassis cap posts) ────
        translate([8,      {CHASSIS_D/2 - 3:.3f}, -0.1]) cylinder(d=3.4, h=cap_t+1);
        translate([cw-8.5, {CHASSIS_D/2 - 3:.3f}, -0.1]) cylinder(d=3.4, h=cap_t+1);
        // Countersinks (from the bottom face of the cap, Z=0)
        translate([8,      {CHASSIS_D/2 - 3:.3f}, -3])   cylinder(d1=6.5, d2=3.4, h=3);
        translate([cw-8.5, {CHASSIS_D/2 - 3:.3f}, -3])   cylinder(d1=6.5, d2=3.4, h=3);
        // ── Ribbon cable relief notch (display side) ──────────────────────
        translate([cw/2-10, -0.1, cap_t-1.2]) cube([20, D+0.2, 1.3]);
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
    GROOVE_W  = 2.5;  GROOVE_D = 2.0;  GROOVE_Z = 3.0
    rail_w    = GROOVE_W - 0.2   # rail tab width (0.2mm total clearance)
    rail_d    = GROOVE_D - 0.1   # rail tab depth (0.1mm clearance)
    wedge_len = 30
    wedge_rise = wedge_len * math.tan(math.radians(10))  # 5.29mm at 10°
    cov_ow    = fp_w + 2 * (cov_wall + cov_clear)        # 83.45mm

    cover = f"""
// WatchCalc 32 C-Cover — v3 PLA BACK COVER
// C-shaped: back panel + two side flanges. Open FRONT (buttons/screen accessible).
// Full height {cov_h:.1f}mm — slides onto chassis from display end.
// Wedge foot at keypad end (Z=0) creates 10° desk tilt.
// Rail tabs inside flanges engage chassis side grooves.
$fn = 40;
cw       = {fp_w:.3f};   // chassis width
ch       = {fp_h:.3f};   // chassis height
D        = {CHASSIS_D:.3f};   // chassis depth
cov_wall = {cov_wall:.1f};
cov_clear= {cov_clear:.1f};
cov_ow   = {cov_ow:.3f};  // total outer width (including flanges)
cov_h    = {cov_h:.3f};  // total height
rail_w   = {rail_w:.2f};  // rail tab width
rail_d   = {rail_d:.2f};  // rail tab depth
GROOVE_Z = {GROOVE_Z:.1f};  // groove Y-offset from front face
wedge_len  = {wedge_len};
wedge_rise = {wedge_rise:.3f};

module c_cover() {{
    difference() {{
        union() {{
            // ── BACK PANEL ─────────────────────────────────────────────────────
            // Sits flush against chassis back face (Y=D)
            translate([-(cov_wall + cov_clear), D + cov_clear, -2])
                cube([cov_ow, cov_wall, cov_h]);

            // ── LEFT FLANGE ────────────────────────────────────────────────────
            // Wraps around left side of chassis (X<0)
            translate([-(cov_wall + cov_clear), -cov_clear, -2])
                cube([cov_wall, D + cov_clear + cov_wall, cov_h]);

            // ── RIGHT FLANGE ───────────────────────────────────────────────────
            // Wraps around right side of chassis (X=cw)
            translate([cw + cov_clear, -cov_clear, -2])
                cube([cov_wall, D + cov_clear + cov_wall, cov_h]);

            // ── BOTTOM END CAP (keypad end, Z=-2) ─────────────────────────────
            // Solid end cap — becomes the desk stand foot.
            translate([-(cov_wall + cov_clear), -cov_clear, -2])
                cube([cov_ow, D + cov_clear + cov_wall, cov_wall]);
        }}

        // ── WEDGE FOOT BEVEL ────────────────────────────────────────────────
        // 10° bevel cut from BACK face of end cap only.
        // When cover sits on desk, back corner lifts {wedge_rise:.1f}mm → 10° tilt.
        translate([-(cov_wall + cov_clear + 1),
                   D + cov_clear - 0.1,
                   -2 - 1])
            rotate([-atan(wedge_rise / wedge_len), 0, 0])
                cube([cov_ow + 2, wedge_rise + 2, wedge_len + 3]);

        // ── LEFT RAIL TAB SLOT ──────────────────────────────────────────────
        // Subtracted from left flange interior — creates inward-facing rail tab.
        // Rail tab is what remains after the slot is cut.
        // (Build the tab by geometry, not subtraction — handled in union above)
    }}

    // ── RAIL TABS (inside flanges, engage chassis side grooves) ──────────
    // Left flange rail tab
    translate([-(cov_clear) + cov_wall - cov_wall, GROOVE_Z - cov_clear, -2])
        cube([rail_d, rail_w, cov_h]);
    // Right flange rail tab
    translate([cw + cov_clear, GROOVE_Z - cov_clear, -2])
        cube([rail_d, rail_w, cov_h]);
}}
c_cover();
"""
    with open("designs/sliding_cover.scad", "w") as f:
        f.write(cover)



    # ═══════════════════════════════════════════════════════
    # BATTERY DOOR (Replaces back_cover)
    # ═══════════════════════════════════════════════════════
    back_cover = f"""
// WatchCalc 32 Battery Door (Flat rear sliding track)
$fn = 60;

module battery_door() {{
    // Print FACE-DOWN: outer visible face is Z=2 (on the bed), lip at Z=0-1 sticks up
    // Lip slides into chassis rail groove on the back face of the chassis.
    //
    // Dimensions derived from chassis:
    //   Chassis ch = {fp_h:.2f} mm. Slot start Y=100, length = {fp_h - 100:.2f} mm
    //   Door must be {fp_h - 100 - 0.2:.2f} mm long (0.2mm clearance)
    //
    //   Print orientation: face-down (Z=2 on build plate)
    //   Z=0-1: inner lip / rails (wider, slides in the groove)
    //   Z=1-2: outer visible face plate (narrower, sits in outer slot)

    difference() {{
        union() {{
            // Inner lip (wider rail) at Z=0 to Z=1 — slides in chassis groove
            // 49.8mm wide to fit in 50mm slot with 0.1mm each side clearance
            translate([-49.8/2, 0, 0]) cube([49.8, {fp_h - 100 - 0.2:.2f}, 1.0]);

            // Outer face at Z=1 to Z=2 — narrower, sits in 2mm outer slot
            // 47.8mm wide (1mm inset each side, acts as ledge/stop)
            translate([-47.8/2, 0, 1.0]) cube([47.8, {fp_h - 100 - 0.2:.2f}, 1.0]);
        }}
        // Grip ridges on the outer face (Z=2, the bed-side when printing face-down)
        for(i=[8:3:22]) {{
            translate([-12, i, 1.6]) cube([24, 1.5, 0.5]);
        }}
        // M2 Screw clearance hole through both layers (locks door to chassis post)
        // At 85% of door length = {(fp_h - 100 - 0.2) * 0.85:.2f} mm
        translate([0, {(fp_h - 100 - 0.2) * 0.85:.2f}, -0.1]) cylinder(d=2.4, h=2.3);
        // Countersink on the outer visible face (Z=2, facing user)
        translate([0, {(fp_h - 100 - 0.2) * 0.85:.2f}, 1.0]) cylinder(d1=2.4, d2=4.4, h=1.1);
    }}
}}
battery_door();

"""
    with open("designs/battery_door.scad", "w") as f:
        f.write(back_cover)

    # ═══════════════════════════════════════════════════════
    # STANDALONE KEYCAPS 
    # ═══════════════════════════════════════════════════════
    buttons_scad = f"""
// Standalone Keycaps
$fn = 40;
module keycap(w, h, label) {{
    // HP32SII-style keycap: only ~1mm taper front-to-back
    // Front edge (y = -h/2) sits 0.5mm lower than rear edge (y = +h/2)
    // giving a gentle 1mm total rise over key depth — very subtle, comfortable
    hull() {{
        // Bottom face (Z=0)
        translate([-w/2+1, -h/2+1, 0])   cylinder(r=1, h=0.01);
        translate([ w/2-1, -h/2+1, 0])   cylinder(r=1, h=0.01);
        translate([-w/2+1,  h/2-1, 0])   cylinder(r=1, h=0.01);
        translate([ w/2-1,  h/2-1, 0])   cylinder(r=1, h=0.01);
        
        // Top face: front at Z=2.5, rear at Z=2.5+1=3.5 — 1mm taper only
        translate([-w/2+1, -h/2+1, 2.5]) cylinder(r=1, h=0.01);
        translate([ w/2-1, -h/2+1, 2.5]) cylinder(r=1, h=0.01);
        translate([-w/2+1,  h/2-1, 3.5]) cylinder(r=1, h=0.01);
        translate([ w/2-1,  h/2-1, 3.5]) cylinder(r=1, h=0.01);
    }}
}}
"""
    for row in rows:
        for b in row:
            buttons_scad += f"translate([{b['x']:.1f}, {b['y']:.1f}, 0]) keycap({b['w']}, {b['h']}, \"{b['label']}\");\n"

    with open("designs/buttons.scad", "w") as f:
        f.write(buttons_scad)

    print(f"SCAD files generated:")
    print(f"  Faceplate:      FACE-UP print. Keys face up, Z=0 on bed. DM32-style protective rim.")
    print(f"  Chassis:        STANDING on keypad edge. Flat 10mm uniform depth. Side grooves for cover.")
    print(f"  Top Cap:        FLAT print. Seals display end.")
    print(f"  Battery Door:   FACE-DOWN print. T-slot on back of chassis.")
    print(f"  Sliding Cover:  FLAT on front wall face. Print in PLA (v1). TPU for v2.")
    print(f"  Buttons:        As-is.")

if __name__ == "__main__":
    generate_scad()

    print("\nCompiling STLs...")
    jobs = [
        ("faceplate",      "designs/faceplate.scad",      "designs/stl/faceplate.stl"),
        ("chassis",        "designs/chassis.scad",        "designs/stl/chassis.stl"),
        ("top_cap",        "designs/top_cap.scad",        "designs/stl/top_cap.stl"),
        ("battery_door",   "designs/battery_door.scad",   "designs/stl/battery_door.stl"),
        ("sliding_cover",  "designs/sliding_cover.scad",  "designs/stl/sliding_cover.stl"),
        ("buttons",        "designs/buttons.scad",        "designs/stl/buttons.stl"),
    ]

    for label, src, dst in jobs:
        r = subprocess.run(["openscad", "-o", dst, src], capture_output=True, text=True)
        if r.returncode == 0:
            print(f"  ✓ {label}.stl")
        else:
            print(f"  ✗ {label} ERRORS:\n{r.stderr[-800:]}")

    mfg_3d = "output/WatchCalc32_PCBWay_Manufacturing/3D_Printing_Files"
    os.makedirs(mfg_3d, exist_ok=True)
    for _, _, stl in jobs:
        fname = os.path.basename(stl)
        subprocess.run(["cp", stl, f"{mfg_3d}/{fname}"])
        subprocess.run(["cp", stl, f"./{fname}"])
