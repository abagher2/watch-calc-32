import re

with open("generate_scad.py", "r") as f:
    text = f.read()

# Replace key_button
start_btn = text.find('module key_button(w, h, label) {')
end_btn = text.find('    // 2. Shaft (Z=1.3 to Z=4.5)', start_btn)

new_btn = """module key_button(w, h, label) {{
    // 1. Massive Piston Base (Z=0.0 to Z=1.3)
    // Double-chamfered to create a 0.3mm mechanical hard stop and retain the button 
    // from falling out the back during assembly!
    hull() {{
        translate([0, 0, 0.20]) cylinder(d=6.2, h=0.4, center=true);
        translate([0, 0, 0.60]) cylinder(d=7.0, h=0.4, center=true);
    }}
    translate([0, 0, 1.05]) cylinder(d=7.0, h=0.5, center=true);

"""
if start_btn != -1 and end_btn != -1:
    text = text[:start_btn] + new_btn + text[end_btn:]


# Replace button_pocket
start_pkt = text.find('module button_pocket(x, y, w, h) {')
end_pkt = text.find('        // 2. Roof Chamfer (Z=1.6 to Z=2.0)', start_pkt)

new_pkt = """module button_pocket(x, y, w, h) {{
    translate([x, y, 0]) {{
        // 1a. Bottom Retaining Lip & Hard Stop (Z=-0.1 to Z=0.5)
        // Matches the button chamfer perfectly when pressed by exactly 0.3mm!
        hull() {{
            translate([0, 0, 0.0]) cylinder(d=6.6, h=0.2, center=true);
            translate([0, 0, 0.3]) cylinder(d=7.4, h=0.2, center=true);
        }}
        
        // 1b. Main Piston Cavity (Z=0.5 to Z=1.6)
        translate([0, 0, 1.0]) cylinder(d=7.4, h=1.0, center=true);
        
"""
if start_pkt != -1 and end_pkt != -1:
    text = text[:start_pkt] + new_pkt + text[end_pkt:]

with open("generate_scad.py", "w") as f:
    f.write(text)
