import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# Replace screw_bosses
target_boss = """module screw_bosses() {
    for (sx = [7.0, cw - 2*wall - 7.0]) {
        for (sy = [ch - wall - 5.0]) {
            translate([wall + sx - 3.0, pt + {PCB_T}, sy - 3.0])
                cube([6.0, D - wall - pt - {PCB_T} + 0.1, 6.0]);
            translate([wall + sx, pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h={PCB_T} + 0.1);
        }
    }
}"""

repl_boss = """module screw_bosses() {
    for (sx = [7.0, cw - 2*wall - 7.0]) {
        for (sy = [ch - wall - 5.0]) {
            // Base boss (supports back of PCB)
            translate([wall + sx - 3.0, pt + TACTILE_H + {PCB_T}, sy - 3.0])
                cube([6.0, D - wall - (pt + TACTILE_H + {PCB_T}) + 0.1, 6.0]);
            
            // Spacer peg (passes through PCB, touches Faceplate)
            // User requested widened PCB holes so the boss can pass through and act as a spacer
            translate([wall + sx, pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.5, h=TACTILE_H + {PCB_T} + 0.1);
        }
    }
}"""
orig = orig.replace(target_boss, repl_boss)

with open("generate_scad.py", "w") as f:
    f.write(orig)
