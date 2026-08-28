import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

content = re.sub(
    r'translate\(\[\{rx:\.3f\} - 3\.0 - 24\.0, 0\.8 \+ \{pt:\.3f\} \+ \{TACTILE_H\} \+ \{PCB_T\}, ch - 33\.5\]\)',
    'translate([{cw/2:.3f} - 12.0, 0.8 + {pt:.3f} + {TACTILE_H} + {PCB_T}, ch - 31.2])',
    content
)

content = re.sub(
    r'translate\(\[0, 0, 31 \+ 0\.1\]\) cube\(\[24, 12\.2 - ',
    'translate([0, 0, 29.2 + 0.1]) cube([24, 12.2 - ',
    content
)

# Dummy PCB update (X=45.0 in KiCad = 36.0 in PCB local space. Y_pcb = 128.6)
content = re.sub(
    r'translate\(\[48\.000, 126\.300, -3\.2\]\)',
    'translate([36.000, 128.600, -3.2])',
    content
)

content = re.sub(
    r'translate\(\[48\.000, 126\.300, 1\.6\]\)',
    'translate([36.000, 128.600, 1.6])',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated Top Cap SCAD to perfectly center the battery above the LCD.")
