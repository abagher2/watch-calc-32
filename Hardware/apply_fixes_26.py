import re

with open("generate_scad.py", "r") as f:
    code = f.read()

# 1. Update button sizes to 8.2x5.2
code = re.sub(r"b\['w'\] = 9\.8\s+b\['h'\] = 9\.6", "b['w'] = 8.2\n        b['h'] = 5.2", code)

# 2. Add buttons_generated.scad export
button_gen = """
    # ═══════════════════════════════════════════════════════
    # BUTTONS ARRAY 
    # ═══════════════════════════════════════════════════════
    buttons_scad = "use <buttons.scad>;\\n\\n"
    for row in rows:
        for b in row:
            ox = pad_left + b['x']
            oy = pad_bottom + b['y']
            lbl = b.get('label', '').replace('"', '\\\\"')
            buttons_scad += f"translate([{ox:.3f}, {oy:.3f}, 0]) button_hp32({b['w']}, {b['h']}, 5.6, 0.8, \\"{lbl}\\");\\n"
    
    with open("designs/buttons_generated.scad", "w") as f:
        f.write(buttons_scad)
"""
code = code.replace("    buttons_scad = \"\"\n    for row in rows:\n        for b in row:\n            buttons_scad += f\"translate([{b['x']:.1f}, {b['y']:.1f}, 2.0]) rotate([0, 180, 0]) key_button({b['w']}, {b['h']}, \\\"{b['label']}\\\");\\n\"", button_gen)

# 3. Update button_faceplate() in generate_scad.py to use hp32_cavity
new_button_faceplate = """
FP_CLR = 0.1;
module button_faceplate() {
    difference() {
        union() {
            // Rails (Z = 0.0 to 1.0)
            translate([FP_CLR, 0, 0]) cube([fp_w - 2*FP_CLR, {split_y:.3f} - FP_CLR, 1.0]);
            
            // Front Solid Block (Z = 1.0 to 2.5) -> Total thickness 2.5mm
            translate([1.5 + FP_CLR, 0, 1.0]) cube([fp_w - 3.0 - 2*FP_CLR, {split_y:.3f} - FP_CLR, 1.5]);
        }
        // Button Holes are subtracted here
"""
code = re.sub(r"FP_CLR = 0\.1;\s*module button_faceplate\(\) \{\{\s*union\(\) \{\{\s*difference\(\) \{\{.*?// Button Holes are subtracted here\n\"\"\"", new_button_faceplate.replace("{", "{{").replace("}", "}}") + '"""', code, flags=re.DOTALL)

# 4. Replace button_cavity and button_labeled with hp32_cavity
code = re.sub(r"unibody_scad \+= f\"        translate\(\[\{ox:\.3f\}, \{oy:\.3f\}, 0\]\) button_cavity\(\{b\['w'\]\}\);\\n\"", "unibody_scad += f\"        translate([{ox:.3f}, {oy:.3f}, 0]) hp32_cavity({b['w'] + 0.4:.3f}, {b['h'] + 0.4:.3f}, 8.4, 2.5);\\n\"", code)
code = re.sub(r"unibody_scad \+= f'        translate\(\[\{ox:\.3f\}, \{oy:\.3f\}, 0\]\) button_labeled\(\{b\[\"w\"\]\}, \{b\[\"w\"\]\}, 0\.5, \"\{lbl_a\}\", \"\{lbl_l\}\", \"\{lbl_r\}\"\);\\n'", "", code)
code = re.sub(r"unibody_scad \+= \"    \}\\n\"\s+for row in rows:.*?lbl_a = b\.get\('label_alpha', ''\)\.replace\('\"', '\\\\\\\"'\)", "", code, flags=re.DOTALL)

# 5. Fix the end brackets for button_faceplate
code = code.replace("    unibody_scad += f\"\"\"\n    }\n}\n", "    unibody_scad += f\"\"\"\n    }\n}\n") # Just in case

# Write back
with open("generate_scad.py", "w") as f:
    f.write(code)

print("Applied fixes to generate_scad.py")
