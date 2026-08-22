import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# Let's fix the Tier 1, 2, 3 cutouts in chassis_shell
target_tiers = """        translate([wall, -0.1, -0.1])
            cube([cw - 2*wall, pt + 0.1, ch - wall + 0.1]);
            
        translate([wall + 2.5, pt - 0.1, -0.1])
            cube([cw - 2*wall - 5.0, {PCB_T} + 0.2, ch - wall + 0.1]);
            
        // Tier 3: Back Components Clearance (Deepest)
        // Starts at Y = pt + PCB_T - 0.1 (overlap with Tier 2).
        // Ends exactly at Y = D - wall. Depth = (D - wall) - (pt + PCB_T - 0.1).
        translate([wall + 5.5, pt + {PCB_T} - 0.1, -0.1])
            cube([cw - 2*wall - 11.0, D - wall - pt - {PCB_T} + 0.1, ch - wall + 0.2]);"""

repl_tiers = """        // Tier 1: Faceplate + Switch Gap + PCB
        // The faceplate, the gap for the tactile switches, and the PCB ALL fit in this main wide slot.
        // It provides the full width for the PCB to slide down.
        translate([wall, -0.1, -0.1])
            cube([cw - 2*wall, pt + TACTILE_H + {PCB_T} + 0.1, ch - wall + 0.1]);
            
        // Tier 2: Microcontroller / Battery JST clearance (Back components)
        // Starts behind the PCB.
        translate([wall + 5.5, pt + TACTILE_H + {PCB_T} - 0.1, -0.1])
            cube([cw - 2*wall - 11.0, D - wall - (pt + TACTILE_H + {PCB_T}) + 0.1, ch - wall + 0.2]);"""
            
if target_tiers in orig:
    orig = orig.replace(target_tiers, repl_tiers)
else:
    print("Could not find target_tiers!")

with open("generate_scad.py", "w") as f:
    f.write(orig)
