import sys

with open("generate_scad.py", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if skip:
        if line.strip() == 'unibody_scad += f"""':
            skip = False
            new_lines.append(line)
        continue
        
    if "unibody_scad += \"    difference() {\\n\"" in line:
        skip = True
        # Insert the correct loop without SVG imports
        new_lines.append("""
    for row in rows:
        for b in row:
            ox = pad_left + b['x']
            oy = pad_bottom + b['y']
            lbl = b.get('label', '').replace('"', '\\\\"')
            label_arg = f', "{lbl}"' if lbl else ',""'
            unibody_scad += f"        translate([{ox:.3f}, {oy:.3f}, 0]) button_solid({b['w']}, {b['h']}{label_arg});\\n"
""")
        continue
        
    new_lines.append(line)

with open("generate_scad.py", "w") as f:
    f.writelines(new_lines)
