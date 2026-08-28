import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Replace Top Cap translation
content = re.sub(
    r'ch - 33\.5\]\)',
    'ch - 38.5])',
    content
)

# Replace the inner hull taper
content = re.sub(
    r'translate\(\[0, 0, 31 \+ 0\.1\]\) cube',
    'translate([0, 0, 36 + 0.1]) cube',
    content
)

# Replace Dummy PCB update
content = re.sub(
    r'translate\(\[48\.000, 126\.300, -3\.2\]\)',
    'translate([48.000, 121.300, -3.2])',
    content
)

content = re.sub(
    r'translate\(\[48\.000, 126\.300, 1\.6\]\)',
    'translate([48.000, 121.300, 1.6])',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated Top Cap SCAD battery holder position down another 5mm.")
