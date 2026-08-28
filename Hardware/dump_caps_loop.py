import re
with open("Hardware/generate_scad.py", "r") as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        if "caps = []" in line:
            print("".join(lines[i-5:i+10]))
            break
