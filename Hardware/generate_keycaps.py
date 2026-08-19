#!/usr/bin/env python3
import os

# Define the keys needed for the calculator
KEYS = [
    # Top Row
    "1/x", "y^x", "SQRT", "LOG", "LN", "x<>y",
    # Second Row
    "E", "sin", "cos", "tan", "y", "P",
    # Third Row
    "+/-", "EEX", "<-", "CLEAR", "x", "r",
    # Numpad & Math
    "7", "8", "9", "/",
    "4", "5", "6", "*",
    "1", "2", "3", "-",
    "0", ".", "ENTER", "+"
]

def generate_scad(key_label):
    # OpenSCAD code for a parametric keycap with raised text
    # The text is raised by 0.6mm (perfect for 3 filament-swap layers at 0.2mm height)
    scad = f"""
$fn = 60;

// Keycap Parameters
base_width = 9;
top_width = 7.5;
height = 5;
stem_dia = 3.3; // Fits tightly over a standard 6x6 tactile switch plunger
stem_depth = 2.5;
text_height = 0.6; // Raised amount for filament swapping
label = "{key_label}";

module keycap() {{
    difference() {{
        // Main body (Truncated Pyramid)
        hull() {{
            translate([0, 0, 0])
                cube([base_width, base_width, 0.1], center=true);
            translate([0, 0, height])
                cube([top_width, top_width, 0.1], center=true);
        }}
        
        // Hollow stem underneath
        translate([0, 0, -0.1])
            cylinder(d=stem_dia, h=stem_depth + 0.1);
    }}
    
    // Raised text on top
    translate([0, 0, height])
        linear_extrude(height = text_height)
            text(label, size=2.5, font="Arial:style=Bold", halign="center", valign="center");
}}

keycap();
"""
    return scad

def main():
    os.makedirs("output/keycaps", exist_ok=True)
    
    for key in KEYS:
        # Sanitize filename
        safe_name = key.replace("/", "_div_").replace("*", "_mul_").replace("+", "_plus_").replace("-", "_minus_")
        safe_name = safe_name.replace("<", "_lt_").replace(">", "_gt_").replace("^", "_pow_")
        
        filename = f"output/keycaps/key_{safe_name}.scad"
        with open(filename, "w") as f:
            f.write(generate_scad(key))
            
    print(f"✅ Generated {len(KEYS)} OpenSCAD keycap models in output/keycaps/")

if __name__ == "__main__":
    main()