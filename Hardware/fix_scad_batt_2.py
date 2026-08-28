import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

content = re.sub(
    r'translate\(\[48\.000, 131\.300, -3\.2\]\)',
    'translate([48.000, 126.300, -3.2])',
    content
)

content = re.sub(
    r'translate\(\[48\.000, 131\.300, 1\.6\]\)',
    'translate([48.000, 126.300, 1.6])',
    content
)


with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated SCAD dummy_pcb battery location")
