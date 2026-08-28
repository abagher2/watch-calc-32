import re
with open("Hardware/generate_scad.py", "r") as f:
    for line in f:
        if "pad_left" in line or "pad_bottom" in line or "pcb_width" in line or "pcb_len" in line:
            print(line.strip())
