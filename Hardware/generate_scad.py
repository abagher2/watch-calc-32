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
        b['w']     = 7.5 if r_idx == 0 else (16.0 if lbl == "ENTER" else 8.0 if lbl in ("f","g","C") else 7.5)
        b['h']     = 6.0

# ─────────────────────────────────────────────────────────
# Global constants & Component Geometry
# ─────────────────────────────────────────────────────────
WALL   = 2.3   # Base wall thickness (thickened to support rails)
cw     = pcb_width + 2*WALL + 0.4    # chassis outer width
fp_w   = pcb_width + 0.4             # faceplate width (matches inner cavity exactly)
fp_h   = pcb_height + 0.4            # faceplate height
corner = 6.0

# Internal Component Heights (mm)
TACTILE_H = 1.5   # Tactile switch height above PCB (Switch Gap)
PCB_T     = 1.6   # PCB thickness
BATT_H    = 3.2   # Battery thickness (e.g. CR2032)
plate_t   = 4.0   # Faceplate base thickness

# Calculate required chassis depth to securely fit all components
# Total Depth = Faceplate(4.0) + Switch Gap(1.5) + PCB(1.6) + Battery Clearance(3.2) + Back Wall(1.7) = 12.0mm
CHASSIS_D = plate_t + TACTILE_H + PCB_T + BATT_H + WALL

EINK_W = 65.0   # module width  (mm)
EINK_H = 30.2   # module height (mm)
disp_x = fp_w / 2
disp_y = (disp['y'] + 4) if disp else (fp_h - EINK_H / 2 - 5)
PCB_SCREW_INSET = 5.0
chassis_screws = [
    (5.0, 5.0), (fp_w - 5.0, 5.0),
    (5.0, fp_h - 5.0), (fp_w - 5.0, fp_h - 5.0),
]

def generate_scad():
    os.makedirs("../scratch/stl", exist_ok=True)

    # ═══════════════════════════════════════════════════════
    # FACEPLATE — printed FACE-UP
    # Z=0 is the BACK of the faceplate (flat on build plate).
    # Keys face UP. 
    # Plungers are at Z=0 (printing directly on bed).
    # Micro-supports bridge plunger and faceplate wall at Z=0.
    # ═══════════════════════════════════════════════════════
    gap         = 0.50   # print-in-place clearance (0.50mm for FDM — generous for kids toy)
    rim_h       = 4.0    # protective rim wall height above plate surface (keeps buttons safe)
    plunger_h   = 1.0    # Z=0.0 to 1.0
    stem_h      = 0.5    # Z=1.0 to 1.5
    diamond_h   = 1.5    # Z=1.5 to 3.0 (exactly 1.0mm below top of 4.0mm plate)
    up_stem_h   = 1.6    # Z=3.0 to 4.6 (Provides 0.6mm travel clearance above 4.0mm faceplate)
    wedge_h     = 2.8    # Z=4.6 to 7.4 (keycap)
    
    # Plunger dimensions (large for bed adhesion and switch pressing)
    pw = 6.0
    ph = 4.0

    faceplate = f"""
// WatchCalc 32 Faceplate — Print FACE-UP
// Back of faceplate is on Z=0 (build plate). Keys face up.
// Micro-supports connect plungers to faceplate for stability.
$fn = 24;
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
    top_z = {plunger_h + stem_h + diamond_h + up_stem_h + wedge_h};

    union() {{
        // Z=0.0 to 1.5 : Plunger (rectangular pad)
        translate([0, 0, {plunger_h/2}])
            cube([{pw}, {ph}, {plunger_h}], center=true);

        // Z=1.5 to 2.5 : Stem (rectangular)
        translate([0, 0, {plunger_h + stem_h/2}])
            cube([{pw}, {ph}, {stem_h}], center=true);

        // Z=1.7 to 3.2 : Diamond Flange (chamfered <> for no-support printing)
        button_flange(w, h, 0);

        // Z=3.0 to 4.6 : Upper Stem (rounded)
        // Uses 1.5mm inset (r=0.5) to create a massive retention lip on the Faceplate
        translate([0, 0, {plunger_h + stem_h + diamond_h}])
            hull() {{
                for(x=[-bw/2+1.5, bw/2-1.5], y=[-bh/2+1.5, bh/2-1.5])
                    translate([x, y, 0]) cylinder(r=0.5, h={up_stem_h});
            }}
            
        // Z=4.6 to 5.6 : Key Cap Base Chamfer (45 degrees, no support needed)
        // Eliminates the flat overhang that sags and fuses to the faceplate
        translate([0, 0, {plunger_h + stem_h + diamond_h + up_stem_h}])
            hull() {{
                // Bottom of chamfer matches upper stem
                for(x=[-bw/2+1.5, bw/2-1.5], y=[-bh/2+1.5, bh/2-1.5])
                    translate([x, y, 0]) cylinder(r=0.5, h=0.01);
                // Top of chamfer matches full keycap base (1.0mm overhang over 1.0mm height = 45 deg)
                for(x=[-bw/2+1, bw/2-1], y=[-bh/2+1, bh/2-1])
                    translate([x, y, 1.0]) cylinder(r=1.0, h=0.01);
            }}
            
        // Z=5.6 to 7.4 : Key Cap Top (Flat, rounded chiclet style)
        translate([0, 0, {plunger_h + stem_h + diamond_h + up_stem_h + 1.0}])
            hull() {{
                for(x=[-bw/2+1, bw/2-1], y=[-bh/2+1, bh/2-1])
                    translate([x, y, 0]) cylinder(r=1.0, h=0.01);
                // Top of the keycap (flat, slightly smaller radius for soft edge)
                for(x=[-bw/2+1, bw/2-1], y=[-bh/2+1, bh/2-1])
                    translate([x, y, {wedge_h - 1.0}]) cylinder(r=0.8, h=0.01);
            }}
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
            cube([dw, dh, 0.1], center=true);
            translate([0, 0, {diamond_h/2}])
                for(x=[-bw/2+1.0, bw/2-1.0], y=[-bh/2+1.0, bh/2-1.0])
                    translate([x, y, 0]) cylinder(r=1.0 + gap, h=0.1);
        }}
}}

module button_pocket(x, y, w, h) {{
    // Pocket mirrors the exact button_flange shape + GAP at every Z height.
    // This guarantees GAP clearance through the full diamond cross-section.
    translate([x, y, 0]) {{
        // 1. Plunger/stem cavity: Z=0 to Z=1.5
        translate([0, 0, {(plunger_h + stem_h)/2}])
            cube([{pw} + GAP*2, {ph} + GAP*2, {plunger_h + stem_h}], center=true);

        // 2. Diamond lower half (expanding): Z=1.5 to Z=2.25
        //    Mirrors button_flange lower half: pw×ph → (w+1)×(h+1), with +GAP
        translate([0, 0, {plunger_h + stem_h}])
            hull() {{
                cube([{pw} + GAP*2, {ph} + GAP*2, 0.01], center=true);
                translate([0, 0, {diamond_h/2}])
                    cube([w + 1.0 + GAP*2, h + 1.0 + GAP*2, 0.01], center=true);
            }}

        // 3. Diamond upper half (contracting): Z=2.25 to Z=3.0
        //    Mirrors button_flange upper half: (w+1)×(h+1) → rounded rect, with +GAP
        translate([0, 0, {plunger_h + stem_h + diamond_h/2}])
            hull() {{
                cube([w + 1.0 + GAP*2, h + 1.0 + GAP*2, 0.01], center=true);
                translate([0, 0, {diamond_h/2}])
                    for(ddx=[-w/2+1.0, w/2-1.0], ddy=[-h/2+1.0, h/2-1.0])
                        translate([ddx, ddy, 0]) cylinder(r=1.0 + GAP, h=0.01);
            }}

        // 4. Retention taper: Z=3.0 to Z=4.0 (45° chamfer, eliminates bridge infill)
        //    Smoothly connects diamond endpoint to upper hole — no flat step!
        //    1.0mm overhang over 1.0mm height = exactly 45°
        translate([0, 0, {plunger_h + stem_h + diamond_h}])
            hull() {{
                // Bottom (Z=3.0): matches diamond upper half endpoint
                for(ddx=[-w/2+1.0, w/2-1.0], ddy=[-h/2+1.0, h/2-1.0])
                    translate([ddx, ddy, 0]) cylinder(r=1.0 + GAP, h=0.01);
                // Top (Z=4.0): matches upper hole size
                translate([0, 0, {plate_t - (plunger_h + stem_h + diamond_h)}])
                    for(dx=[-(w)/2+1.5, (w)/2-1.5], dy=[-(h)/2+1.5, (h)/2-1.5])
                        translate([dx, dy, 0]) cylinder(r=0.5 + GAP, h=0.01);
            }}

        // 5. Upper hole: Z=3.0 to Z=5.0 (breaks through faceplate top)
        translate([0, 0, {plunger_h + stem_h + diamond_h}])
            hull() {{
                for(dx=[-(w)/2+1.5, (w)/2-1.5], dy=[-(h)/2+1.5, (h)/2-1.5])
                    translate([dx, dy, 0]) cylinder(r=0.5 + GAP, h={up_stem_h + 1.0});
            }}
    }}
}}

module faceplate_body() {{
    // Base plate — rim walls are on chassis now (DM32 style protection)
    // 0.3mm clearance on all edges allows smooth slide-in from display end
    // Sharp rectangular corners to sit flush inside the chassis cavity
    cube([fp_w, fp_h, pt]);
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
    pad_x = (fp_w - pcb_width) / 2
    pad_y = (fp_h - pcb_height) / 2
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
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
    pad_x = (fp_w - pcb_width) / 2
    pad_y = (fp_h - pcb_height) / 2
    for row in rows:
        for b in row:
            ox = b['x'] + pad_x
            oy = b['y'] + pad_y
            faceplate += f"    translate([{ox:.3f}, {oy:.3f}, 0]) key_button({b['w']}, {b['h']}, \"{b['label']}\");\n"
            faceplate += f"    micro_supports({ox:.3f}, {oy:.3f}, {b['w']}, {b['h']});\n"

    faceplate += "}\n"

    with open("designs/faceplate.scad", "w") as f:
        f.write(faceplate)


    # ═══════════════════════════════════════════════════════
    # CHASSIS — CLOSED-TOP, BOTTOM-LOADING
    # ═══════════════════════════════════════════════════════
    # Print orientation: display end (Z=ch) face-down on build plate.
    #   Z=0 = keypad end (OPEN — end cap seals here)
    #   Z=ch = display end (SOLID ceiling — sits on build plate)
    #   Front face (Y=0) open for faceplate. Back face (Y=D) solid.
    #   PCB slides in from bottom (Z=0). Cradled by left/right PCB rails.
    #   End cap at Z=0 secures assembly with lateral M3 screws.
    #
    #   Total assembled thickness: CHASSIS_D(12) + plate_t(4) front = ~16mm.

    import math
    D        = CHASSIS_D
    GCW = 2.0; GCD = 1.5; GR = 1.5; GY = 3.0
    junc_z = fp_h / 3.0
    batt_w = 40; batt_h = 25
    batt_z = fp_h - WALL - 30

    chassis = f"""
// WatchCalc 32 Chassis — v8 (Closed Top, Bottom-Loading)
$fn = 24;
cw   = {cw:.3f};
ch   = {fp_h + WALL:.3f};
D    = {D:.3f};
wall = {WALL:.3f};
batt_w = {batt_w}; batt_h = {batt_h}; batt_z = {batt_z:.2f};
GCW = {GCW:.1f}; GCD = {GCD:.1f}; GR = {GR:.1f}; GY = {GY:.1f};
junc = {junc_z:.2f};

module chassis_shell() {{
    difference() {{
        // Chassis shell: sharp front corners (connect to rim walls), rounded back corners (r=3)
        hull() {{
            // Front left
            translate([0, 0, 0]) cube([3, 3, ch]);
            // Front right
            translate([cw-3, 0, 0]) cube([3, 3, ch]);
            // Back left (rounded)
            translate([3, D-3, 0]) cylinder(r=3, h=ch);
            // Back right (rounded)
            translate([cw-3, D-3, 0]) cylinder(r=3, h=ch);
        }}
        
        // 1. Tier 1: Faceplate Cavity (Y = 0 to plate_t)
        // Extends from Z=-0.1 up to Z=ch-wall (fp_h), leaving the top wall intact to lock the faceplate
        translate([wall, -0.1, -0.1])
            cube([cw - 2*wall, {plate_t} + 0.1, ch - wall + 0.1]);
            
        // 2. Tier 2: Switch Gap (Y = plate_t to plate_t + TACTILE_H)
        translate([wall + 3.0, {plate_t}, -0.1])
            cube([cw - 2*wall - 6.0, {TACTILE_H}, ch - wall + 0.1]);
            
        // 3. Tier 3: PCB Slot (Y = plate_t + TACTILE_H to + PCB_T)
        translate([wall, {plate_t} + {TACTILE_H}, -0.1])
            cube([cw - 2*wall, {PCB_T}, ch - wall + 0.1]);
            
        // 4. Tier 4: Battery & Component Clearance
        translate([wall + 3.0, {plate_t} + {TACTILE_H} + {PCB_T}, -0.1])
            cube([cw - 2*wall - 6.0, D - wall - ({plate_t} + {TACTILE_H} + {PCB_T}) + 0.1, ch - wall + 0.1]);
    }}
}}
module rim_walls() {{
    // DM32/HP32SII-style bezel. rim_d=4mm matches faceplate thickness.
    // Buttons recessed 1.2mm below rim — calculator can lie face-down safely.
    rim_d = {plate_t};
    lip   = 2.0;  // small retention chamfer lip at faceplate level

    // Outer rim walls (left, right, top crossbar)
    translate([0, -rim_d, 0])        cube([wall, rim_d, ch]);
    translate([cw-wall, -rim_d, 0])  cube([wall, rim_d, ch]);
    translate([0, -rim_d, ch-wall])  cube([cw, rim_d, wall]);

    // ── INNER CHAMFER LIPS (correct orientation) ──────────────────
    // Wide (lip=2mm) at Y=0 (faceplate face) — overlaps faceplate edge,
    // preventing it falling forward. Tapers to 0 at Y=-rim_d (outer face).
    // Smooth, subtle, invisible from outside. Rugged retention for kids use.
    //
    // Left: triangle in XY, extruded full height.
    //   At Y=0: extends lip=2mm inward from wall (supports faceplate).
    //   At Y=-rim_d: nothing (flush with outer bezel face).
    translate([wall, 0, 0])
        linear_extrude(ch - wall)
            polygon([[0,0],[lip,0],[0,-rim_d]]);
    // Right (mirror)
    translate([cw-wall, 0, 0])
        linear_extrude(ch - wall)
            polygon([[0,0],[-lip,0],[0,-rim_d]]);
    // Top: same taper, extruded full width
    translate([wall, 0, ch-wall])
        rotate([0, 90, 0])
        linear_extrude(cw - 2*wall)
            polygon([[0,0],[lip,0],[0,-rim_d]]);
}}
module screw_bosses() {{
    // Internal bosses on the inside of left/right walls at the keypad end.
    // Provide thread material for M3 screws WITHOUT protruding outside.
    // Boss: 4mm wide × 4mm deep × 3mm tall, flush with exterior wall face.
    // Left (X = wall to wall+4, Y = 0 to 4, Z = 0 to 3)
    translate([wall, 0, 0])       cube([4, 4, 3]);
    // Right (X = cw-wall-4 to cw-wall, Y = 0 to 4, Z = 0 to 3)
    translate([cw-wall-4, 0, 0])  cube([4, 4, 3]);
}}
module railway_grooves() {{
    translate([-0.1, GY, 0])        cube([GCD+0.1, GCW, ch]);
    translate([cw-GCD, GY, 0])      cube([GCD+0.1, GCW, ch]);
    
    // Friction-lock bumps near the bottom (Z=5) to snap the cover in place
    // A 0.4mm protrusion into the groove
    translate([-0.1, GY + GCW/2, 5.0]) rotate([0, 90, 0]) cylinder(d=GCW, h=GCD+0.5, $fn=16);
    translate([cw-GCD-0.4, GY + GCW/2, 5.0]) rotate([0, 90, 0]) cylinder(d=GCW, h=GCD+0.5, $fn=16);
}}
module chassis() {{
    difference() {{
        union() {{
            chassis_shell();
            rim_walls();
            // No internal screw bosses — end cap boss provides thread engagement.
        }}
        
        // ── END CAP SCREWS ───────────────────────────────────────────────
        // Screw head recess (6mm) on exterior, clearance bore (3.4mm) through wall
        // AND through 2mm air gap to reach inset boss. Boss starts at wall+2.
        // Left
        translate([-0.1, 2.0, 3.5]) rotate([0, 90, 0]) cylinder(d=6.0, h=0.8);   // head recess
        translate([-0.1, 2.0, 3.5]) rotate([0, 90, 0]) cylinder(d=3.4, h=wall+2.2); // clearance bore to boss
        // Right
        translate([cw+0.1, 2.0, 3.5]) rotate([0, -90, 0]) cylinder(d=6.0, h=0.8);
        translate([cw+0.1, 2.0, 3.5]) rotate([0, -90, 0]) cylinder(d=3.4, h=wall+2.2);
        
        // ── CLOSED TOP ───────────────────────────────────────────────────
        // Display end (Z=ch) is solid. PCB+Faceplate load from bottom (Z=0).
        // The Tier 1 cavity ends at Z=ch-wall, creating a locking lip for the faceplate.
        
        // ── RAILWAY GROOVES ──────────────────────────────────────────────
        // 2 straight grooves for the sliding cover
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

    cap_t_val = 3.0      # end cap plate thickness
    bezel_lip = plate_t   # front lip extends 4mm forward to match bezel

    top_cap = f"""
// WatchCalc 32 End Cap — v7 (sits BELOW chassis at Z=0)
// Cap extends from Z=-cap_t to Z=0. Top face flush with chassis bottom.
// Front lip extends forward to complete DM32-style bezel.
// Secured by lateral M3 screws through chassis side walls.
$fn = 24;
cw    = {cw:.3f};
D     = {CHASSIS_D:.3f};
wall  = {WALL:.3f};
cap_t = {cap_t_val};
lip_h = {bezel_lip};   // front bezel lip height (matches rim_d)

module top_cap() {{
    union() {{
        difference() {{
            // ── MAIN PLATE (below chassis, Z=-cap_t to Z=0) ─────────
            // Sharp front corners, rounded back corners (r=3)
            // Front edge extends to Y=-{plate_t} to cover the full bezel/rim area
            // and retain the faceplate
            hull() {{
                translate([0, -{plate_t}, -cap_t]) cube([3, 3, cap_t]);
                translate([cw-3, -{plate_t}, -cap_t]) cube([3, 3, cap_t]);
                translate([3, D-3, -cap_t]) cylinder(r=3, h=cap_t);
                translate([cw-3, D-3, -cap_t]) cylinder(r=3, h=cap_t);
            }}
        }}
        // ── SCREW BOSSES (project upward into Tier 1 cavity) ────────
        // Bosses inset 2mm from chassis inner wall to avoid overlapping wall material.
        // Screw clearance bore in chassis extends through wall + 2mm gap to reach boss.
        // 2.5mm pilot hole in boss provides thread engagement.
        
        // Left boss — inset 2mm from inner wall (X=wall+2 to X=wall+6)
        difference() {{
            translate([wall+2, 0, 0]) cube([4, 4, 5]);
            translate([wall+2-0.1, 2.0, 3.5]) rotate([0, 90, 0]) cylinder(d=2.5, h=4.2);
        }}
        // Right boss — inset 2mm from inner wall (X=cw-wall-6 to X=cw-wall-2)
        difference() {{
            translate([cw-wall-6, 0, 0]) cube([4, 4, 5]);
            translate([cw-wall-6-0.1, 2.0, 3.5]) rotate([0, 90, 0]) cylinder(d=2.5, h=4.2);
        }}
        // ── FRONT BEZEL LIP ──
        // (Removed to avoid requiring supports during 3D printing)
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
    union() {{
        // Overlap by 0.1mm into the flange wall to ensure perfect manifold fusion
        translate([-cov_clear - 0.1, GROOVE_Z - cov_clear, -2])
            cube([rail_d + 0.1, rail_w, cov_h]);
        // Lock bump at Z=5
        translate([-cov_clear - 0.1, GROOVE_Z - cov_clear + rail_w/2, 5.0]) 
            rotate([0, 90, 0]) 
            cylinder(d=rail_w, h=rail_d + 0.35, $fn=16);
    }}
    // Right flange rail tab (translated inwards by rail_d)
    union() {{
        // Overlap by 0.1mm into the flange wall
        translate([cw + cov_clear - rail_d, GROOVE_Z - cov_clear, -2])
            cube([rail_d + 0.1, rail_w, cov_h]);
        // Lock bump at Z=5
        // Protrudes in negative X direction, so translate to outer edge and rotate -90
        translate([cw + cov_clear + 0.1, GROOVE_Z - cov_clear + rail_w/2, 5.0]) 
            rotate([0, -90, 0]) 
            cylinder(d=rail_w, h=rail_d + 0.35, $fn=16);
    }}
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
$fn = 24;

module battery_door() {{
    // Print FACE-DOWN: outer visible face is Z=2 (on the bed), lip at Z=0-1 sticks up
    // Lip slides into chassis rail groove on the back face of the chassis.
    //
    // Dimensions derived from chassis:
    //   Chassis battery hole is 40x25mm
    difference() {{
        union() {{
            // Main plate (39.6 x 24.6mm to fit with 0.2mm clearance in 40x25 hole)
            // Thickness = 1.5mm so it sits perfectly flush in the 1.5mm deep recess.
            translate([-39.6/2, 0, 0]) cube([39.6, 24.6, 1.5]);

            // Bottom mounting tab (slides into chassis slot at Z=-1.0)
            // Starts at Z=0 (bottom edge of door), goes down 1.0mm
            translate([-(39.6 - 4)/2, -1.0, 0.5]) cube([39.6 - 4, 1.0, 1.0]);
        }}

        // Fingernail notch on the top edge (Z=24.6)
        translate([0, 24.6, 1.5]) rotate([90,0,0]) cylinder(d=4.0, h=4.0, center=true);

        // M2 Screw clearance hole 
        translate([0, 21.08, -0.1]) cylinder(d=2.4, h=2.3);
        // Countersink
        translate([0, 21.08, 0.5]) cylinder(d1=2.4, d2=4.4, h=1.1);
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
    tasks = [
        ("faceplate",      "designs/faceplate.scad",      "../scratch/stl/faceplate.stl"),
        ("chassis",        "designs/chassis.scad",        "../scratch/stl/chassis.stl"),
        ("top_cap",        "designs/top_cap.scad",        "../scratch/stl/top_cap.stl"),
        ("sliding_cover",  "designs/sliding_cover.scad",  "../scratch/stl/sliding_cover.stl"),
        ("buttons",        "designs/buttons.scad",        "../scratch/stl/buttons.stl"),
    ]

    procs = []
    for label, src, dst in tasks:
        p = subprocess.Popen(["openscad", "-o", dst, src], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        procs.append((label, p))
        
    for label, p in procs:
        stdout, stderr = p.communicate()
        if p.returncode == 0:
            print(f"  ✓ {label}.stl")
        else:
            print(f"  ✗ {label} ERRORS:\n{stderr[-800:]}")

    mfg_3d = "output/WatchCalc32_PCBWay_Manufacturing/3D_Printing_Files"
    os.makedirs(mfg_3d, exist_ok=True)
    for _, _, stl in tasks:
        fname = os.path.basename(stl)
        subprocess.run(["cp", stl, f"{mfg_3d}/{fname}"])
        subprocess.run(["cp", stl, f"./{fname}"])
