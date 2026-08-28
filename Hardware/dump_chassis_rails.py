import re
with open("Hardware/generate_scad.py", "r") as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        if "module chassis_shell" in line or "module chassis" in line:
            print("".join(lines[i:i+40]))
            break
