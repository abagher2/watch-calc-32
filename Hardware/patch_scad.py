import sys

with open("generate_scad.py", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "def generate_button_faceplate():" in line:
        new_lines.append(line)
        continue
    
    if "translate([ox:.3f}, {oy:.3f}, 0]) button_solid({b['w']}, {b['h']}{label_arg});" in line:
        pass # this doesn't match directly anyway
        
    if "unibody_scad += f\"        translate([{ox:.3f}, {oy:.3f}, 0]) button_solid" in line:
        new_lines.append('            unibody_scad += f"        translate([{ox:.3f}, {oy:.3f}, 0]) button_solid({b[\'w\']}, {b[\'h\']});\\n"\n')
        continue
        
    if "unibody_scad += \"    }\\n\"" in line and "for row in rows" not in line:
        # this is the end of the union
        new_lines.append(line)
        continue
        
    new_lines.append(line)

# Wait, it's easier to just use sed or Python to replace the whole block
