import re
with open("Hardware/generate_scad.py", "r") as f:
    for line in f:
        if "caps.append" in line or "caps = []" in line or "for cap in caps:" in line:
            print(line.strip())
