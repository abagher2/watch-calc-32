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
        b['w']     = 7.5 if r_idx == 0 else (16.0 if lbl == "ENTER" else 8.0 if lbl in ("f","g","C") else 7.0)
        b['h']     = 5.0

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
    plate_t     = 4.0    # faceplate base thickness
    rim_h       = 4.0    # protective rim wall height above plate surface (keeps buttons safe)
    plunger_h   = 1.0    # Z=0.0 to 1.0
    stem_h      = 0.5    # Z=1.0 to 1.5
    diamond_h   = 1.5    # Z=1.5 to 3.0 (exactly 1.0mm below top of 4.0mm plate)
    up_stem_h   = 1.0    # Z=3.0 to 4.0
    wedge_h     = 2.8    # Z=4.0 to 6.8 (keycap)
    
    # Plunger dimensions (large for bed adhesion and switch pressing)
    pw = 6.0
    ph = 4.0

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

    // Z=1.7 to 3.2 : Diamond Flange (chamfered <> for no-support printing)
    button_flange(w, h, 0);

    // Z=4.5 to 6.0 : Upper Stem (rounded)
    translate([0, 0, {plunger_h + stem_h + diamond_h}])
        hull() {{
            for(x=[-bw/2+1, bw/2-1], y=[-bh/2+1, bh/2-1])
                translate([x, y, 0]) cylinder(r=1.0, h={up_stem_h});
        }}
    // Z=6.0 to 8.5 : Key Cap (Flat, rounded chiclet style)
    translate([0, 0, {plunger_h + stem_h + diamond_h + up_stem_h}])
        hull() {{
            // Base of the keycap
            for(x=[-bw/2+1, bw/2-1], y=[-bh/2+1, bh/2-1])
                translate([x, y, 0]) cylinder(r=1.0, h=0.01);
            // Top of the keycap (flat, slightly smaller radius for soft edge)
            for(x=[-bw/2+1, bw/2-1], y=[-bh/2+1, bh/2-1])
                translate([x, y, {wedge_h}]) cylinder(r=0.8, h=0.01);
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

module button_flange(w, h, gap) {{
    bw = w; bh = h;
    dw = bw + 1.0 + gap*2;
    dh = bh + 1.0 + gap*2;
    // Lower half expands
    translate([0, 0, {plunger_h + stem_h}])
        hull() {{
            cube([{pw} + gap*2, {ph} + gap*2, 0.01], center=true);
            translate([0, 0, {diamond_h/2}]) cube([dw, dh, 0.01], center=true);
        }}
    // Upper half contracts smoothly to rounded rectangle
    translate([0, 0, {plunger_h + stem_h + diamond_h/2}])
        hull() {{
            cube([dw, dh, 0.01], center=true);
            translate([0, 0, {diamond_h/2}])
                for(x=[-bw/2+1.0, bw/2-1.0], y=[-bh/2+1.0, bh/2-1.0])
                    translate([x, y, 0]) cylinder(r=1.0 + gap, h=0.01);
        }}
}}

module button_pocket(x, y, w, h) {{
    // The pocket must accommodate the button in the UNPRESSED state (Z=0)
    // and PRESSED state (Z=-1.0).
    translate([x, y, 0]) {{
        // Lower hole (accommodates plunger/stem travel down to Z=-1)
        // From Z=0 to Z=1.7 (unpressed stem top).
        translate([0, 0, {(plunger_h + stem_h)/2}])
            cube([{pw} + GAP*2, {ph} + GAP*2, {plunger_h + stem_h}], center=true);

        // Flange cavity: Hull of unpressed and pressed (-1.0mm) states
        hull() {{
            button_flange(w, h, GAP);
            translate([0, 0, -1.0]) button_flange(w, h, GAP);
        }}

        // Upper hole: Must cut all the way through faceplate top
        translate([0, 0, {plunger_h + stem_h + diamond_h}])
            hull() {{
                for(dx=[-(w)/2+1.0, (w)/2-1.0], dy=[-(h)/2+1.0, (h)/2-1.0])
                    translate([dx, dy, 0]) cylinder(r=1.0 + GAP, h={up_stem_h + 1.0}); // Extra height to break through
            }}
    }}
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
        // The main cavity is fp_w wide (74.65mm), from Y=0 to Y=D-wall (8.0mm).
        // This holds the Faceplate (Y=0 to 4.0) and components.
        translate([wall, -0.1, -0.1])
            cube([cw - 2*wall, D - wall + 0.1, ch - wall + 0.1]);
    }}
}}

module pcb_rails() {{
    rl = 4.0; // The rails protrude 4.0mm to exactly match the PCB width (which is 8mm narrower than the faceplate)
    
    // Solid rail blocks on the left and right walls.
    // Sits directly behind the Faceplate (Y=4.0).
    // Provides a back-stop for the Faceplate, and side-walls for the PCB.
    difference() {{
        union() {{
            translate([wall, {plate_t}, 0])
                cube([rl, D - wall - {plate_t}, ch - wall]);
            translate([cw - wall - rl, {plate_t}, 0])
                cube([rl, D - wall - {plate_t}, ch - wall]);
        }}
        
        // Cut the 1.6mm PCB slot into these solid blocks
        // We leave a 1.5mm thick solid rail in front to support the Faceplate and clear its components.
        // The slot starts at Y = {plate_t} + 1.5
        // Z starts at 15.0 to clear the bottom cap screw holes
        translate([wall - 0.1, {plate_t} + 1.5, 15.0])
            cube([rl + 0.2, 1.6, ch - 15.0 + 0.1]);
            
        translate([cw - wall - rl - 0.1, {plate_t} + 1.5, 15.0])
            cube([rl + 0.2, 1.6, ch - 15.0 + 0.1]);
    }}
}}
module pcb_standoff() {{
    // Removed to allow bottom access for PCB/Faceplate sliding
}}
module rim_walls() {{
    rim_d = 4.0;
    translate([0, -rim_d, 0])        cube([wall, rim_d, ch]);
    translate([cw-wall, -rim_d, 0])  cube([wall, rim_d, ch]);
    // Bottom rim removed for full slide access
    translate([0, -rim_d, ch-wall])  cube([cw, rim_d, wall]);
}}
module cap_posts() {{
    py = D - wall - 1.5;
    // Left post tapers into the wall to prevent overhangs when printed inverted
    hull() {{
        translate([wall + 4, py, 0]) cylinder(d=7, h=14);
        translate([wall, py + 1.5, 14 + 7]) cube([0.1, 0.1, 0.1]);
    }}
    // Right post tapers into the wall
    hull() {{
        translate([cw - wall - 4, py, 0]) cylinder(d=7, h=14);
        translate([cw - wall, py + 1.5, 14 + 7]) cube([0.1, 0.1, 0.1]);
    }}
}}
module chassis() {{
    difference() {{
        union() {{
            chassis_shell(); pcb_rails(); pcb_standoff();
            cap_posts(); rim_walls();
        }}
        py = D - wall - 1.5;
        translate([wall + 4,      py, -0.1]) cylinder(d=2.6, h=15);
        translate([cw - wall - 4, py, -0.1]) cylinder(d=2.6, h=15);
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
        translate([6.0,    6.5, -0.1]) cylinder(d=3.4, h=cap_t+1);
        translate([cw-6.0, 6.5, -0.1]) cylinder(d=3.4, h=cap_t+1);
        // Countersinks (from the bottom face of the cap, Z=0)
        translate([6.0,    6.5, -3])   cylinder(d1=6.5, d2=3.4, h=3);
        translate([cw-6.0, 6.5, -3])   cylinder(d1=6.5, d2=3.4, h=3);
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
    GROOVE_W  = 2.0;  GROOVE_D = 1.5;  GROOVE_Z = 3.0
    rail_w    = GROOVE_W - 0.2   # rail tab width (0.2mm total clearance)
    rail_d    = GROOVE_D - 0.1   # rail tab depth (0.1mm clearance)
    wedge_len = 30
    wedge_rise = wedge_len * math.tan(math.radians(10))  # 5.29mm at 10°
    cov_ow    = fp_w + 2 * (cov_wall + cov_clear)        # 83.45mm

    cover = f"""
// WatchCalc 32 C-Cover — v3 PLA BACK COVER (Friction Sleeve)
// C-shaped: back panel + two side flanges that extend 2/3 of the way across the side depth.
// Full height {cov_h:.1f}mm — slides onto chassis from display end.
// Wedge foot at keypad end (Z=0) creates 10° desk tilt.
$fn = 40;
cw       = {fp_w:.3f};   // chassis width
ch       = {fp_h:.3f};   // chassis height
D        = {CHASSIS_D:.3f};   // chassis depth
cov_wall = {cov_wall:.1f};
cov_clear= {cov_clear:.1f};
cov_ow   = {cov_ow:.3f};  // total outer width (including flanges)
cov_h    = {cov_h:.3f};  // total height
wedge_len  = {wedge_len};
wedge_rise = {wedge_rise:.3f};

// Flanges extend from the back (Y=D) down to Y=2.0 (leaving the front rim exposed)
flange_y = 2.0;

module c_cover() {{
    difference() {{
        union() {{
            // ── BACK PANEL ─────────────────────────────────────────────────────
            // Sits flush against chassis back face (Y=D)
            translate([-(cov_wall + cov_clear), D + cov_clear, -2])
                cube([cov_ow, cov_wall, cov_h]);

            // ── LEFT FLANGE ────────────────────────────────────────────────────
            // Wraps around left side of chassis, ending at Y=flange_y
            translate([-(cov_wall + cov_clear), flange_y, -2])
                cube([cov_wall, D + cov_clear - flange_y, cov_h]);
            // Rounded lip for the edge of the flange
            translate([-(cov_wall + cov_clear) + cov_wall/2, flange_y, -2])
                cylinder(d=cov_wall, h=cov_h);

            // ── RIGHT FLANGE ───────────────────────────────────────────────────
            // Wraps around right side of chassis
            translate([cw + cov_clear, flange_y, -2])
                cube([cov_wall, D + cov_clear - flange_y, cov_h]);
            // Rounded lip for the edge of the flange
            translate([cw + cov_clear + cov_wall/2, flange_y, -2])
                cylinder(d=cov_wall, h=cov_h);

            // ── BOTTOM END CAP (keypad end, Z=-2) ─────────────────────────────
            // Solid end cap — becomes the desk stand foot.
            translate([-(cov_wall + cov_clear), flange_y - cov_wall/2, -2])
                cube([cov_ow, D + cov_clear - flange_y + cov_wall/2, cov_wall]);
        }}

        // ── WEDGE FOOT BEVEL ────────────────────────────────────────────────
        // 10° bevel cut from BACK face of end cap only.
        translate([-(cov_wall + cov_clear + 1),
                   D + cov_clear - 0.1,
                   -2 - 1])
            rotate([-atan(wedge_rise / wedge_len), 0, 0])
                cube([cov_ow + 2, wedge_rise + 2, wedge_len + 3]);
    }}
}}
c_cover();
"""
    with open("designs/sliding_cover.scad", "w") as f:
        f.write(cover)



    # ═══════════════════════════════════════════════════════
    # ═══════════════════════════════════════════════════════
    # STANDALONE KEYCAPS 
    # ═══════════════════════════════════════════════════════
    buttons_scad = f"""
// Standalone Keycaps
$fn = 40;
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
