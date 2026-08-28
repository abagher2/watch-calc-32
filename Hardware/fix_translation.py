import re
with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Fix the translation to X=1.2 (offset_x) since pad_left is now 0.0
# The Y translation should be FRONT_LIP + pt + TACTILE_H = 1.0 + 2.0 + 1.6 = 4.6
# In the original, it was 7.7 because the chassis used to have different dimensions.
# Wait, let's just make it align perfectly with the PCB cavity.
# PCB Cavity Y = FRONT_LIP + pt + TACTILE_H = 4.6.
content = re.sub(
    r'translate\(\[1\.8, 7\.7, 3\]\)',
    'translate([1.2, 4.6, 3])',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
