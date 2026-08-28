import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Replace dummy PCB battery translation
# from: translate([{cw/2:.3f}, 137.0, -3.2])
# to:   translate([48.000, 131.300, -3.2])
content = re.sub(
    r'translate\(\[\{cw/2:\.3f\}, 137\.0, -3\.2\]\)',
    'translate([48.000, 131.300, -3.2])',
    content
)

# And the red wire
# from: translate([{cw/2:.3f}, 137.0, 1.6])
# to:   translate([48.000, 131.300, 1.6])
content = re.sub(
    r'translate\(\[\{cw/2:\.3f\}, 137\.0, 1\.6\]\)',
    'translate([48.000, 131.300, 1.6])',
    content
)


with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated SCAD dummy_pcb battery location")
