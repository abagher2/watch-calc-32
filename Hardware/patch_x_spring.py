import re

with open("generate_scad.py", "r") as f:
    code = f.read()

# Replace lattice spring union
old_union = """                union() {{
                    translate([-cavity_w/2, -0.6, 0]) cube([cavity_w, 1.2, z_spring_top]);
                    translate([-0.6, -cavity_h/2, 0]) cube([1.2, cavity_h, z_spring_top]);
                }}"""

new_union = """                union() {{
                    rotate([0, 0, 45]) translate([-cavity_w, -0.6, 0]) cube([cavity_w*2, 1.2, z_spring_top]);
                    rotate([0, 0, -45]) translate([-cavity_w, -0.6, 0]) cube([cavity_w*2, 1.2, z_spring_top]);
                }}"""

if old_union in code:
    code = code.replace(old_union, new_union)
    with open("generate_scad.py", "w") as f:
        f.write(code)
    print("Patched X-springs!")
else:
    print("Could not find old union")
