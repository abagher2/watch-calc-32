import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Revert battery holder translation in top cap back to right screw boss with 5mm shift
content = re.sub(
    r'translate\(\[\{cw/2:\.3f\} - 12\.0, 0\.8 \+ \{pt:\.3f\} \+ \{TACTILE_H\} \+ \{PCB_T\}, ch - 31\.2\]\)',
    'translate([{rx:.3f} - 3.0 - 24.0, 0.8 + {pt:.3f} + {TACTILE_H} + {PCB_T}, ch - 33.5])',
    content
)

# Revert the inner hull taper to 31mm height
content = re.sub(
    r'translate\(\[0, 0, 29\.2 \+ 0\.1\]\) cube\(\[24, 12\.2 - ',
    'translate([0, 0, 31 + 0.1]) cube([24, 12.2 - ',
    content
)

# Revert Dummy PCB update to X=48.0 and Y=126.3
content = re.sub(
    r'translate\(\[36\.000, 128\.600, -3\.2\]\)',
    'translate([48.000, 126.300, -3.2])',
    content
)

content = re.sub(
    r'translate\(\[36\.000, 128\.600, 1\.6\]\)',
    'translate([48.000, 126.300, 1.6])',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Reverted Top Cap SCAD battery holder position to overlap LCD.")
