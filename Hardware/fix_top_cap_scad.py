import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Replace battery holder translation in top cap
# from: translate([{rx:.3f} - 3.0 - 24.0, 0.8 + {pt:.3f} + {TACTILE_H} + {PCB_T}, ch - 28.5])
# to:   translate([{rx:.3f} - 3.0 - 24.0, 0.8 + {pt:.3f} + {TACTILE_H} + {PCB_T}, ch - 33.5])
content = re.sub(
    r'ch - 28\.5\]\)',
    'ch - 33.5])',
    content
)

# Replace the inner hull taper so it reaches up to the top cap lid
# from: translate([0, 0, 26 + 0.1]) cube([24, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5), 0.1]);
# to:   translate([0, 0, 31 + 0.1]) cube([24, 12.2 - (0.8 + {pt} + {TACTILE_H} + {PCB_T} + 0.5), 0.1]);
content = re.sub(
    r'26 \+ 0\.1\]\) cube\(\[24, 12\.2 - ',
    '31 + 0.1]) cube([24, 12.2 - ',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated Top Cap SCAD battery holder position.")
