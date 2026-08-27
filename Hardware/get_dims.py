import sys
# We can just extract the math from generate_scad.py
with open("generate_scad.py", "r") as f:
    lines = f.readlines()
    for l in lines:
        if "cw =" in l or "fp_h =" in l or "CHASSIS_D" in l or "Target Assembled" in l:
            print(l.strip())
