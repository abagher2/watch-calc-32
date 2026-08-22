import re

with open("generate_scad.py", "r") as f:
    text = f.read()

# Replace key_button
start_btn = text.find('module key_button(w, h, label) {')
end_btn = text.find('    // 4. Keycap', start_btn)

new_btn = """module key_button(w, h, label) {{
    // 1. Hollow Base (Z=0 to Z=2.0)
    // Prints on the bed. Hollow core fits AROUND the tactile switch body!
    difference() {{
        union() {{
            // Chamfered bottom for retention (snaps in or prints-in-place)
            hull() {{
                translate([0, 0, 0.1]) cylinder(d=8.4, h=0.2, center=true);
                translate([0, 0, 0.4]) cylinder(d=8.8, h=0.2, center=true);
            }}
            translate([0, 0, 1.2]) cylinder(d=8.8, h=1.6, center=true);
        }}
        // Inner hollow core (d=7.6 to easily clear a 5.2x5.2mm switch)
        translate([0, 0, 1.0]) cylinder(d=7.6, h=2.1, center=true);
    }}
    
    // 2. Base Roof (Z=2.0 to Z=2.4) - This rests perfectly on the tactile switch plunger!
    translate([0, 0, 2.2]) cylinder(d=8.8, h=0.4, center=true);
    
    // 2b. Shaft (Z=2.4 to Z=4.5)
    translate([0, 0, 3.45]) cylinder(d=4.6, h=2.1, center=true);
    
"""
if start_btn != -1 and end_btn != -1:
    text = text[:start_btn] + new_btn + text[end_btn:]

# Replace button_pocket
start_pkt = text.find('module button_pocket(x, y, w, h) {')
end_pkt = text.find('        // 3. Upper Shaft Hole', start_pkt)

new_pkt = """module button_pocket(x, y, w, h) {{
    translate([x, y, 0]) {{
        // 1a. Bottom Retaining Lip & Hard Stop (Z=-0.1 to Z=0.4)
        hull() {{
            translate([0, 0, 0.0]) cylinder(d=8.8, h=0.2, center=true);
            translate([0, 0, 0.4]) cylinder(d=9.2, h=0.2, center=true);
        }}
        
        // 1b. Main Hollow Cavity (Z=0.4 to Z=2.0)
        translate([0, 0, 1.2]) cylinder(d=9.2, h=1.6, center=true);
        
        // 2. Roof Chamfer (Z=2.0 to Z=2.5)
        hull() {{
            translate([0, 0, 2.0]) cylinder(d=9.2, h=0.01, center=true);
            translate([0, 0, 2.5]) cylinder(d=5.4, h=0.01, center=true);
        }}
        
"""
if start_pkt != -1 and end_pkt != -1:
    text = text[:start_pkt] + new_pkt + text[end_pkt:]

with open("generate_scad.py", "w") as f:
    f.write(text)
