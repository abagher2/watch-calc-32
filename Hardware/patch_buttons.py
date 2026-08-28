import sys

with open("generate_scad.py", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if skip:
        if line.strip() == 'unibody_scad += f"""':
            skip = False
            
            # Insert our new geometry!
            new_code = """
    unibody_scad += "    difference() {\\n"
    unibody_scad += "        union() {\\n"
    for row in rows:
        for b in row:
            ox = fp_w - (pad_left + b['x'])
            oy = pad_bottom + b['y']
            unibody_scad += f"            translate([{ox:.3f}, {oy:.3f}, 0]) button_solid({b['w']}, {b['h']});\\n"
    
    # Embossed labels
    unibody_scad += "            translate([0, 0, 4.5]) linear_extrude(0.4) scale([0.1, 0.1, 1]) import(\"../Layout_Embossed.svg\");\\n"
    unibody_scad += "        }\\n"
    
    # Sunken labels (Subtracted)
    unibody_scad += "        translate([0, 0, 4.1]) linear_extrude(0.5) scale([0.1, 0.1, 1]) import(\"../Layout_Sunken.svg\");\\n"
    unibody_scad += "    }\\n"
    unibody_scad += f\"\"\"
"""
            new_lines.append(new_code)
        continue

    if "for row in rows:" in line and "unibody_scad += \"    }\\n\"" in lines[i-1]:
        skip = True
        continue
    
    new_lines.append(line)

with open("generate_scad.py", "w") as f:
    f.writelines(new_lines)

