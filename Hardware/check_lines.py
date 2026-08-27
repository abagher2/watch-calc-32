import re

with open("generate_scad.py") as f:
    code = f.read()

# print the exact lines to confirm they were changed!
for i, line in enumerate(code.split("\n")):
    if "pad_left = " in line or "BATT_H    =" in line or "CHASSIS_D =" in line:
        print(f"Line {i}: {line}")
