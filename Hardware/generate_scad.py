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
    // Base plate
    hull() {{
        translate([cr, cr, 0])           cylinder(r=cr, h=pt);
        translate([fp_w-cr, cr, 0])      cylinder(r=cr, h=pt);
        translate([cr, fp_h-cr, 0])      cylinder(r=cr, h=pt);
        translate([fp_w-cr, fp_h-cr, 0]) cylinder(r=cr, h=pt);
    }}
    // Protective rim walls (like DM32) — buttons sit recessed inside
    // Left rim
    translate([0, 0, pt]) cube([{WALL:.1f}, fp_h, {rim_h}]);
    // Right rim
    translate([fp_w - {WALL:.1f}, 0, pt]) cube([{WALL:.1f}, fp_h, {rim_h}]);
    // Bottom rim
    translate([0, 0, pt]) cube([fp_w, {WALL:.1f}, {rim_h}]);
    // Top rim
    translate([0, fp_h - {WALL:.1f}, pt]) cube([fp_w, {WALL:.1f}, {rim_h}]);
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

    faceplate += f"""
        // Screw holes — chassis to faceplate
        // Screw holes — chassis to faceplate (M3 threaded hole, blind from front)
"""
    for sx, sy in chassis_screws:
        # Straight M3 tap holes — chassis is flat, no angle needed
        faceplate += f"        translate([{sx:.3f}, {sy:.3f}, -0.1]) cylinder(d=2.6, h=4.5); // M3 tap\n"

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
    D      = CHASSIS_D    # 10.0mm uniform depth
    RAIL_W = 1.5          # PCB cradle rail width (1.5mm gives 0.5mm clearance each side)
    STANDOFF = 1.2        # Bottom SMD clearance
    PCB_T    = 1.6
    GROOVE_W = 2.5        # Cover rail groove width
    GROOVE_D = 2.0        # Cover rail groove depth
    GROOVE_Z = 3.0        # Groove inset from front face

    chassis = f"""
// WatchCalc 32 Chassis — FLAT SLEEVE
// Print STANDING on keypad (bottom) edge.
// Front face open (faceplate covers it). Back face solid with battery door.
// Side grooves on left/right walls for sliding TPU cover.
$fn = 60;
cw   = {fp_w:.3f};   // X width
ch   = {fp_h:.3f};   // Z height
D    = {D:.3f};      // Y depth (uniform)
wall = {WALL:.3f};
cr   = {corner:.3f};
PCB_W  = {pcb_width:.3f};
PCB_H  = {pcb_height:.3f};
PCB_T  = 1.6;
STANDOFF = 1.2;
RAIL_W   = {RAIL_W:.1f};
GROOVE_W = {GROOVE_W:.1f};  // Cover rail groove width
GROOVE_D = {GROOVE_D:.1f};  // Cover rail groove depth
GROOVE_Z = {GROOVE_Z:.1f};  // Groove inset from front face (Y direction)

// ── OUTER BODY ───────────────────────────────────────────────────────────────
module chassis_outer() {{
    hull() {{
        translate([cr,    cr,    0])     cylinder(r=cr, h=0.01);
        translate([cw-cr, cr,    0])     cylinder(r=cr, h=0.01);
        translate([cr,    D-cr,  0])     cylinder(r=cr, h=0.01);
        translate([cw-cr, D-cr,  0])     cylinder(r=cr, h=0.01);
        translate([cr,    cr,    ch-cr]) cylinder(r=cr, h=cr);
        translate([cw-cr, cr,    ch-cr]) cylinder(r=cr, h=cr);
        translate([cr,    D-cr,  ch-cr]) cylinder(r=cr, h=cr);
        translate([cw-cr, D-cr,  ch-cr]) cylinder(r=cr, h=cr);
    }}
}}

// ── INTERIOR VOID ────────────────────────────────────────────────────────────
module chassis_interior() {{
    hull() {{
        translate([wall+cr,    wall+cr,   wall]) cylinder(r=cr, h=0.01);
        translate([cw-wall-cr, wall+cr,   wall]) cylinder(r=cr, h=0.01);
        translate([wall+cr,    D-wall,    wall]) cylinder(r=cr, h=0.01);
        translate([cw-wall-cr, D-wall,    wall]) cylinder(r=cr, h=0.01);
        translate([wall+cr,    wall+cr,   ch-wall]) cylinder(r=cr, h=0.01);
        translate([cw-wall-cr, wall+cr,   ch-wall]) cylinder(r=cr, h=0.01);
        translate([wall+cr,    D-wall,    ch-wall]) cylinder(r=cr, h=0.01);
        translate([cw-wall-cr, D-wall,    ch-wall]) cylinder(r=cr, h=0.01);
    }}
}}

// ── PCB CRADLE RAILS ─────────────────────────────────────────────────────────
module pcb_rails() {{
    // Left rail — 0.5mm clearance each side (RAIL_W=1.5, inner w = PCB_W + 1mm total)
    translate([wall, wall, wall + STANDOFF])
        cube([RAIL_W, D - 2*wall, PCB_H + PCB_T + 1.0]);
    // Right rail
    translate([cw - wall - RAIL_W, wall, wall + STANDOFF])
        cube([RAIL_W, D - 2*wall, PCB_H + PCB_T + 1.0]);
}}

// ── BOTTOM STANDOFF ──────────────────────────────────────────────────────────
module bottom_standoff() {{
    translate([wall + RAIL_W, wall, wall])
        cube([cw - 2*(wall + RAIL_W), D - 2*wall, STANDOFF]);
}}

// ── CORNER SCREW POSTS (front rim) ───────────────────────────────────────────
module screw_posts() {{
    // 4 solid posts on front rim (Y=0 face), M3 clearance holes drilled in chassis()
    translate([5.0,    0, 5.0])    cylinder(d=9.0, h=wall + 0.1);
    translate([cw-5.0, 0, 5.0])   cylinder(d=9.0, h=wall + 0.1);
    translate([5.0,    0, ch-5.0]) cylinder(d=9.0, h=wall + 0.1);
    translate([cw-5.0, 0, ch-5.0]) cylinder(d=9.0, h=wall + 0.1);
}}

// ── CAP POSTS (top rim) ─────────────────────────────────────────────────────────
module cap_posts() {{
    translate([cw/2 - 12, 0, ch-wall]) cylinder(d=7.0, h=wall + 3);
    translate([cw/2 + 12, 0, ch-wall]) cylinder(d=7.0, h=wall + 3);
}}

// ── MAIN CHASSIS ───────────────────────────────────────────────────────────────
module chassis() {{
    difference() {{
        union() {{
            difference() {{ chassis_outer(); chassis_interior(); }}
            pcb_rails();
            bottom_standoff();
            screw_posts();
            cap_posts();
        }}

        // Battery door slot (back face at Y=D)
        // Outer slot: 50mm wide, 2mm deep, Z=10 to Z=ch*0.85
        translate([cw/2 - 25, D - 2.1, 10.0])
            cube([50, 2.2, ch*0.85 - 10.0]);
        // Rail groove: 52mm wide, 1mm deep, Z=15 to Z=ch*0.85
        translate([cw/2 - 26, D - 1.1, 15.0])
            cube([52, 1.2, ch*0.85 - 15.0]);

        // M2 pilot hole for battery door screw (horizontal through back wall)
        translate([cw/2, D - 0.1, ch * 0.6])
            rotate([90, 0, 0]) cylinder(d=2.0, h=wall + 2);
        // M2 boss countersink (exterior)
        translate([cw/2, D + 0.1, ch * 0.6])
            rotate([90, 0, 0]) cylinder(d=6.0, h=3);

        // Faceplate M3 clearance holes (straight — flat chassis, no angle needed)
        translate([5.0,    0, 5.0])    cylinder(d=3.4, h=wall + 2);
        translate([cw-5.0, 0, 5.0])   cylinder(d=3.4, h=wall + 2);
        translate([5.0,    0, ch-5.0]) cylinder(d=3.4, h=wall + 2);
        translate([cw-5.0, 0, ch-5.0]) cylinder(d=3.4, h=wall + 2);

        // Top cap M3 pilot holes
        translate([cw/2 - 12, wall/2, ch+1]) rotate([90,0,0]) cylinder(d=2.6, h=wall+5);
        translate([cw/2 + 12, wall/2, ch+1]) rotate([90,0,0]) cylinder(d=2.6, h=wall+5);

        // Sliding cover rail grooves — on left and right OUTER side walls
        // Run full height of chassis (Z). Groove at Y=GROOVE_Z from front face.
        // Left wall groove (at X=0, into +X)
        translate([-0.1, GROOVE_Z, 0])
            cube([GROOVE_D + 0.1, GROOVE_W, ch]);
        // Right wall groove (at X=cw, into -X)
        translate([cw - GROOVE_D, GROOVE_Z, 0])
            cube([GROOVE_D + 0.1, GROOVE_W, ch]);
    }}
}}

chassis();
"""

    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)

    # ═══════════════════════════════════════════════════════
    # TOP CAP (updated for flat chassis — D=10mm uniform)
    # ═══════════════════════════════════════════════════════
    top_cap = f"""
// WatchCalc 32 Top Cap — flat chassis version
// Seals the display end (Z=ch) of the chassis after PCB insertion.
// Plate: {fp_w:.2f}mm wide × {CHASSIS_D:.1f}mm deep × 3mm thick.
// Print flat. 2× M3 countersunk screws into chassis cap posts.
$fn = 60;
module top_cap() {{
    difference() {{
        hull() {{
            translate([3, 3, 0])                            cylinder(r=3, h=3);
            translate([{fp_w:.3f}-3, 3, 0])                cylinder(r=3, h=3);
            translate([3, {CHASSIS_D:.3f}-3, 0])           cylinder(r=3, h=3);
            translate([{fp_w:.3f}-3, {CHASSIS_D:.3f}-3, 0]) cylinder(r=3, h=3);
        }}
        // Center notch for display ribbon cable (20mm wide)
        translate([{fp_w/2 - 10:.3f}, -0.1, -0.1]) cube([20, {CHASSIS_D + 0.2:.3f}, 1.5]);
        // M3 clearance holes
        translate([{fp_w/2 - 12:.3f}, {CHASSIS_D/2:.3f}, -0.1]) cylinder(d=3.4, h=4.0);
        translate([{fp_w/2 + 12:.3f}, {CHASSIS_D/2:.3f}, -0.1]) cylinder(d=3.4, h=4.0);
        // Countersinks
        translate([{fp_w/2 - 12:.3f}, {CHASSIS_D/2:.3f}, 1.5]) cylinder(d1=3.4, d2=6.5, h=1.5);
        translate([{fp_w/2 + 12:.3f}, {CHASSIS_D/2:.3f}, 1.5]) cylinder(d1=3.4, d2=6.5, h=1.5);
    }}
}}
top_cap();
"""
    with open("designs/top_cap.scad", "w") as f:
        f.write(top_cap)

    # ═══════════════════════════════════════════════════════
    # SLIDING COVER (TPU, full-length flip-sleeve)
    # ═══════════════════════════════════════════════════════
    # The cover is a TPU sleeve that fits over the full calculator.
    # STORAGE: Calculator slides in from the top. Front wall protects buttons.
    # DESK STAND (flip operation):
    #   1. Slide calculator UP and out of the cover.
    #   2. Flip the cover 180° end-over-end.
    #   3. Slide calculator back DOWN into the now-inverted cover.
    #   4. The 10° wedge bevel on the cover FOOT now rests on the desk,
    #      angling the calculator back at ~10° for comfortable desk viewing.
    #
    # Print flat (on the front wall face). PLA filament (v1).
    # Cover total outer height = fp_h + 4mm (2mm overhang each end).
    # PLA sliding fit: 0.4mm clearance per side (more than TPU due to rigidity).
    # No snap detents in v1 — friction fit only (detents require flex).

    cov_wall   = 2.0       # cover wall thickness (thicker for PLA rigidity)
    cov_clear  = 0.4       # PLA sliding fit clearance per side
    cov_h      = fp_h + 4  # full length + 2mm each end
    cov_ow     = fp_w + 2 * (cov_wall + cov_clear)   # outer width
    cov_od     = CHASSIS_D + 2 * (cov_wall + cov_clear)  # outer depth
    rail_w     = GROOVE_W - 0.2   # rail tab width (0.1mm clearance per side)
    rail_d     = GROOVE_D - 0.1   # rail tab depth
    wedge_len  = 30         # length of wedge foot zone (mm)
    # At 10 degrees over wedge_len, height difference = wedge_len * tan(10)
    import math
    wedge_rise = wedge_len * math.tan(math.radians(10))

    cover = f"""
// WatchCalc 32 Sliding Cover — v1 PRINT IN PLA
// Full-length sleeve. Flip end-over-end for 10° desk stand.
// PLA: 0.4mm clearance each side for smooth sliding fit.
// No snap detents in v1 — friction fit in rail grooves.
// Print laying flat on the FRONT WALL face.
$fn = 40;
cov_ow   = {cov_ow:.3f};  // outer width
cov_od   = {cov_od:.3f};  // outer depth
cov_h    = {cov_h:.3f};  // outer height (full length)
cov_wall = {cov_wall:.1f};   // wall thickness
rail_w   = {rail_w:.2f};   // rail tab width
rail_d   = {rail_d:.2f};   // rail tab depth
wedge_len = {wedge_len};   // wedge foot zone length (mm)
wedge_rise = {wedge_rise:.3f};  // height difference across wedge foot

module cover() {{
    difference() {{
        union() {{
            // ── MAIN SHELL (hollow box, open top and bottom) ──────────────────────
            difference() {{
                // Outer shell
                hull() {{
                    translate([3, 3, 0])                cylinder(r=3, h=cov_h);
                    translate([cov_ow-3, 3, 0])         cylinder(r=3, h=cov_h);
                    translate([3, cov_od-3, 0])         cylinder(r=3, h=cov_h);
                    translate([cov_ow-3, cov_od-3, 0])  cylinder(r=3, h=cov_h);
                }}
                // Inner void: open top and bottom (Z clearance)
                translate([cov_wall, cov_wall, -0.1])
                    cube([cov_ow - 2*cov_wall, cov_od - 2*cov_wall, cov_h + 0.2]);
            }}

            // ── INTERIOR RAIL TABS (left and right) ───────────────────────────
            // Rail tab projects inward from side walls.
            // Sits at Y = cov_wall + {cov_clear:.2f} + {GROOVE_Z:.1f} to match chassis groove.
            // Left rail tab
            translate([cov_wall, cov_wall + {cov_clear + GROOVE_Z:.3f}, 0])
                cube([rail_d, rail_w, cov_h]);
            // Right rail tab
            translate([cov_ow - cov_wall - rail_d, cov_wall + {cov_clear + GROOVE_Z:.3f}, 0])
                cube([rail_d, rail_w, cov_h]);
        }}

        // ── WEDGE FOOT BEVEL (bottom end, Z=0 to wedge_len) ───────────────────
        // Cut a 10° bevel off the BACK face of the bottom end only.
        // When cover is flipped and used as a stand, this face contacts the desk,
        // angling the calculator ~10° back toward the user.
        // The bevel is a prism: zero cut at Z=0 (front edge), wedge_rise cut at Z=wedge_len (back edge).
        translate([0, cov_od - cov_wall - 0.1, 0])
            rotate([-atan(wedge_rise/wedge_len), 0, 0])
                translate([0, 0, -0.5])
                    cube([cov_ow, wedge_rise + 1, wedge_len + 2]);

        // NOTE: Snap detents removed for PLA v1 — friction fit only.
        // (Detents will be added back for TPU v2 where rail tabs can flex)
    }}
}}
cover();
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
