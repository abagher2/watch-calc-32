import re
with open("designs/chassis_tapered.scad", "r") as f:
    orig = f.read()

orig = re.sub(r'D\s*=\s*13\.400;', 'D    = 14.900;', orig)

with open("designs/chassis_tapered.scad", "w") as f:
    f.write(orig)
