import re

with open("generate_scad.py", "r") as f:
    text = f.read()

# 1. Depth Calculation
text = text.replace(
"""BATT_H    = 7.0   # Clearance for wired CR2450 battery holder (Z)
plate_t   = 3.0   # Faceplate base thickness (Reduced for DM32 matching)

# Calculate required chassis depth to securely fit all components
# Total Depth = Faceplate(4.0) + Switch Gap(1.5) + PCB(1.6) + Battery Clearance(3.2) + Back Wall(1.7) = 12.0mm
CHASSIS_D = plate_t + TACTILE_H + PCB_T + BATT_H + WALL""",
"""BATT_H    = 7.0   # Clearance for wired CR2450 battery holder (Z)
plate_t   = 3.0   # Faceplate base thickness (Reduced for DM32 matching)
FRONT_LIP = 1.5   # Structural retaining bezel

# Calculate required chassis depth to securely fit all components
CHASSIS_D = FRONT_LIP + plate_t + TACTILE_H + PCB_T + BATT_H + WALL""")

# 2. Inject FRONT_LIP variable to SCAD generator locals
text = text.replace(
"""chassis_tapered = f\"\"\"
// WatchCalc 32 Chassis (Tapered)""",
"""FRONT_LIP = 1.5
chassis_tapered = f\"\"\"
// WatchCalc 32 Chassis (Tapered)""")

# 3. Fix Tier Cavities
text = text.replace(
"""        // Tier 1: Faceplate (Closed bottom, Open top)
        translate([wall, -0.1, wall])
            cube([cw - 2*wall, pt + 0.1, ch + 0.2]);
            
        // Tier 2: PCB
        translate([wall, pt - 0.1, wall])
            cube([cw - 2*wall, 1.6 + 0.2, ch + 0.2]);
            
        // Tier 3: Back Components Clearance (Deepest)
        // Sloped to follow the outer wedge hull!
        hull() {
            // Bottom (Z=wall) - Cavity depth is 0 here since chassis is thin.
            translate([wall + 5.5, pt + 1.6 - 0.1, wall]) 
                cube([cw - 2*wall - 11.0, 0.1, 0.1]);
            // Top (Z=ch+0.1) - Cavity depth is full here.
            translate([wall + 5.5, pt + 1.6 - 0.1, ch + 0.1]) 
                cube([cw - 2*wall - 11.0, D - wall - pt - 1.6 + 0.1, 0.1]);
        }""",
"""        // Tier 1: Faceplate (Closed bottom, Open top)
        translate([wall, {FRONT_LIP}, wall])
            cube([cw - 2*wall, pt + 0.1, ch + 0.2]);
            
        // Tier 2: PCB
        translate([wall, {FRONT_LIP} + pt - 0.1, wall])
            cube([cw - 2*wall, 1.6 + 0.2, ch + 0.2]);
            
        // Tier 3: Back Components Clearance (Deepest)
        // Sloped to follow the outer wedge hull!
        hull() {{
            // Bottom (Z=wall) - Cavity depth is 0 here since chassis is thin.
            translate([wall + 5.5, {FRONT_LIP} + pt + 1.6 - 0.1, wall]) 
                cube([cw - 2*wall - 11.0, 0.1, 0.1]);
            // Top (Z=ch+0.1) - Cavity depth is full here.
            translate([wall + 5.5, {FRONT_LIP} + pt + 1.6 - 0.1, ch + 0.1]) 
                cube([cw - 2*wall - 11.0, D - wall - {FRONT_LIP} - pt - 1.6 + 0.1, 0.1]);
        }}""")

# 4. Screw Bosses
text = text.replace(
"""module screw_bosses() {
    for (sx = [7.0, cw - 2*wall - 7.0]) {
        for (sy = [5.0]) { // Bottom screw position (was at ch-wall-5.0)
            // Peg that passes through the PCB 1.6mm thickness
            translate([wall + sx, pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h=1.6 + 0.1);
        }
    }
}""",
"""module screw_bosses() {{
    for (sx = [7.0, cw - 2*wall - 7.0]) {{
        for (sy = [5.0]) {{ // Bottom screw position (was at ch-wall-5.0)
            // Peg that passes through the PCB 1.6mm thickness
            translate([wall + sx, {FRONT_LIP} + pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h=1.6 + 0.1);
        }}
    }}
}}""")

# 5. Bezel Window
text = text.replace(
"""        // ── CHASSIS SCREW CLEARANCE HOLES ────────────────────────────────""",
"""        // ── BEZEL WINDOW (Exposes keypad and screen) ────────────────────
        // Cuts a window in the FRONT_LIP to expose the faceplate.
        // Leaves a 2.0mm wide frame on left, right, and bottom.
        translate([wall + 2.0, -0.1, wall + 2.0])
            cube([cw - 2*wall - 4.0, {FRONT_LIP} + 0.2, ch - wall - 2.0 + 0.1]);
            
        // ── CHASSIS SCREW CLEARANCE HOLES ────────────────────────────────""")

# 6. Top Cap Bosses
text = text.replace(
"""        // Left Standoff
        difference() {
            union() {
                // Thick Base: From back wall to PCB (Y = pt + PCB_T)
                // Width 6.0, drops down from ch to Z=135
                translate([wall + 7.0 - 3.0, {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                // Thin Shaft: Passes through PCB to reach the Faceplate (Y = pt)
                translate([wall + 7.0, {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }
            // Clearance hole for M2 screw (d=2.2) passes through BOTH
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }
        
        // Right Standoff
        difference() {
            union() {
                translate([cw - wall - 7.0 - 3.0, {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                translate([cw - wall - 7.0, {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }
        
        // ── BATTERY BUCKET (hangs down into Tier 3 cavity) ─────
        // Designed to hold a wired CR2450 battery (approx 26x26x6mm)
        // Positioned in the Y dimension within the Tier 3 cavity (Y={pt}+{PCB_T} to Y=D-wall)
        // Z hangs down from ch.
        translate([(cw - 28)/2, {pt} + {PCB_T}, ch - 26]) {
            difference() {
                // Outer block
                cube([28, D - wall - ({pt} + {PCB_T}) - 0.2, 26]);
                // Inner hollow (1.2mm walls on sides and bottom, open on front and top)
                translate([1.2, -0.1, 1.2])
                    cube([28 - 2.4, D - wall - ({pt} + {PCB_T}), 26]);
            }
        }""",
"""        // Left Standoff
        difference() {{
            union() {{
                // Thick Base: From back wall to PCB (Y = pt + PCB_T)
                // Width 6.0, drops down from ch to Z=135
                translate([wall + 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                // Thin Shaft: Passes through PCB to reach the Faceplate (Y = pt)
                translate([wall + 7.0, {FRONT_LIP} + {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }}
            // Clearance hole for M2 screw (d=2.2) passes through BOTH
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // Right Standoff
        difference() {{
            union() {{
                translate([cw - wall - 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                translate([cw - wall - 7.0, {FRONT_LIP} + {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }}
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // ── BATTERY BUCKET (hangs down into Tier 3 cavity) ─────
        translate([(cw - 28)/2, {FRONT_LIP} + {pt} + {PCB_T}, ch - 26]) {{
            difference() {{
                // Outer block
                cube([28, D - wall - ({FRONT_LIP} + {pt} + {PCB_T}) - 0.2, 26]);
                // Inner hollow (1.2mm walls on sides and bottom, open on front and top)
                translate([1.2, -0.1, 1.2])
                    cube([28 - 2.4, D - wall - ({FRONT_LIP} + {pt} + {PCB_T}), 26]);
            }}
        }}""")

with open("generate_scad.py", "w") as f:
    f.write(text)

