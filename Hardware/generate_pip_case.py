#!/usr/bin/env python3
import os

def generate_pip_scad():
    scad = """
// Print-in-Place Calculator Faceplate with Compliant Hinged Keys
// Designed for a single filament swap to color all text.
$fn = 60;

// Dimensions
faceplate_width = 95;
faceplate_height = 180;
faceplate_thickness = 3;
corner_radius = 5;
text_extrude = 0.6; // Text sticks up 0.6mm from the top surface

// Screen Cutout
screen_width = 60;
screen_height = 25;
screen_x_offset = 47.5; // Centered
screen_y_offset = 145; // Forehead

// Button Dimensions
button_width = 8;
button_height = 5;
gap = 0.5; // Gap between button and faceplate hole
hinge_thickness = 0.4; // 2 layers at 0.2mm - compliant mechanism
hinge_width = 1.0;

module button_hole(x, y, w, h) {
    translate([x - w/2 - gap, y - h/2 - gap, -1])
        cube([w + 2*gap, h + 2*gap, faceplate_thickness + 2]);
}

module hinged_button(x, y, w, h, label) {
    translate([x, y, 0]) {
        // Main button body
        translate([0, 0, faceplate_thickness/2])
            cube([w, h, faceplate_thickness], center=true);
            
        // Compliant Hinges (Left and Right)
        translate([-w/2 - gap/2, 0, faceplate_thickness/2])
            cube([gap, hinge_width, hinge_thickness], center=true);
        translate([w/2 + gap/2, 0, faceplate_thickness/2])
            cube([gap, hinge_width, hinge_thickness], center=true);
            
        // Plunger (Stem) to hit the tactile switch
        translate([0, 0, -2])
            cylinder(d=3.3, h=2);
            
        // Raised Text
        translate([0, 0, faceplate_thickness])
            linear_extrude(height=text_extrude)
            // Use slightly smaller font for longer labels
            text(label, size=len(label)>3 ? 1.5 : 2, font="Arial:style=Bold", halign="center", valign="center");
    }
}

// 1. The Main Faceplate
difference() {
    // Faceplate Base
    hull() {
        translate([corner_radius, corner_radius, 0]) cylinder(r=corner_radius, h=faceplate_thickness);
        translate([faceplate_width-corner_radius, corner_radius, 0]) cylinder(r=corner_radius, h=faceplate_thickness);
        translate([corner_radius, faceplate_height-corner_radius, 0]) cylinder(r=corner_radius, h=faceplate_thickness);
        translate([faceplate_width-corner_radius, faceplate_height-corner_radius, 0]) cylinder(r=corner_radius, h=faceplate_thickness);
    }
    
    // Screen Cutout
    translate([screen_x_offset - screen_width/2, screen_y_offset - screen_height/2, -1])
        cube([screen_width, screen_height, faceplate_thickness + 2]);
        
    // Screw Holes (Matches angled_shell.scad wall corners)
    // The angled shell walls are 3mm thick, so centers are at 1.5mm from edges
    translate([1.5, 1.5, -1]) cylinder(d=2.4, h=faceplate_thickness+2);
    translate([faceplate_width-1.5, 1.5, -1]) cylinder(d=2.4, h=faceplate_thickness+2);
    translate([1.5, faceplate_height-1.5, -1]) cylinder(d=2.4, h=faceplate_thickness+2);
    translate([faceplate_width-1.5, faceplate_height-1.5, -1]) cylinder(d=2.4, h=faceplate_thickness+2);

    // --- Button Cutouts ---
"""

    # Button Coordinates mapping from KiCad
    # Structure: (x, y, width, label)
    # The list is sorted from top (y=111.08) down to bottom (y=17.07)
    buttons = [
        # Row 8 (Top Row)
        (12.07, 111.08, 22, "ENTER"), # Double wide
        (33.08, 111.08, 8, "CLEAR"),
        (47.08, 111.08, 8, "x<>y"),
        (61.08, 111.08, 8, "Rdn"),
        (75.08, 111.08, 8, "STO"),
        
        # Row 7
        (5.07, 97.08, 8, "+/-"),
        (19.07, 97.08, 8, "EEX"),
        (33.08, 97.08, 8, "<-"),
        (47.08, 97.08, 8, "x"),
        (61.08, 97.08, 8, "y"),
        (75.08, 97.08, 8, "RCL"),
        
        # Row 6
        (5.07, 83.08, 8, "E"),
        (19.07, 83.08, 8, "sin"),
        (33.08, 83.08, 8, "cos"),
        (47.08, 83.08, 8, "tan"),
        (61.08, 83.08, 8, "LN"),
        (75.08, 83.08, 8, "LOG"),
        
        # Row 5
        (5.07, 69.08, 8, "1/x"),
        (19.07, 69.08, 8, "y^x"),
        (33.08, 69.08, 8, "A"),
        (47.08, 69.08, 8, "B"),
        (61.08, 69.08, 8, "C"),
        (75.08, 69.08, 8, "D"),

        # Row 4 (Lower Matrix)
        (5.07, 59.08, 8, "7"),
        (22.07, 59.08, 8, "8"),
        (39.08, 59.08, 8, "9"),
        (56.08, 59.08, 8, "/"),
        (73.08, 59.08, 8, "X"),
        (90.08, 59.08, 8, "Y"),

        # Row 3
        (5.07, 45.08, 8, "4"),
        (22.07, 45.08, 8, "5"),
        (39.08, 45.08, 8, "6"),
        (56.08, 45.08, 8, "*"),
        (73.08, 45.08, 8, "M"),
        (90.08, 45.08, 8, "N"),

        # Row 2
        (5.07, 31.07, 8, "1"),
        (22.07, 31.07, 8, "2"),
        (39.08, 31.07, 8, "3"),
        (56.08, 31.07, 8, "-"),
        (73.08, 31.07, 8, "P"),
        (90.08, 31.07, 8, "Q"),

        # Row 1 (Bottom Row)
        (5.07, 17.07, 8, "0"),
        (22.07, 17.07, 8, "."),
        (39.08, 17.07, 8, "SPC"),
        (56.08, 17.07, 8, "+"),
        (73.08, 17.07, 8, "I"),
        (90.08, 17.07, 8, "J"),
    ]

    for x, y, w, lbl in buttons:
        scad += f"    button_hole({x}, {y}, {w}, 5);\n"

    scad += "}\n\n// 2. The Print-in-Place Buttons\n"

    for x, y, w, lbl in buttons:
        scad += f'hinged_button({x}, {y}, {w}, 5, "{lbl}");\n'

    # Add Faceplate Text Logo
    scad += """
// 3. Faceplate Text (Prints in same filament swap pass)
translate([faceplate_width/2, faceplate_height - 15, faceplate_thickness])
    linear_extrude(height=text_extrude)
        text("WatchCalc 32", size=5, font="Arial:style=Bold", halign="center", valign="center");
"""
    return scad

if __name__ == "__main__":
    os.makedirs("output/cases", exist_ok=True)
    with open("output/cases/print_in_place_case.scad", "w") as f:
        f.write(generate_pip_scad())
    print("✅ Generated print_in_place_case.scad!")
