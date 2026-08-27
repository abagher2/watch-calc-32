import os

p = "/Users/abagher/Documents/GitHub/watch-calc-32/Hardware/generate_scad.py"
with open(p, "r") as f:
    c = f.read()

c = c.replace("""# Display Geometry: EastRising 2.7" ST7567 (ERC12864FSF-6)
ACTIVE_W = 60.77
ACTIVE_H = 32.94
DISP_W   = 71.20
DISP_H   = 48.20
# Assuming "No Backlight" version which is typically ~2.0mm to 2.8mm thick. 
# If they use the 5.1mm backlit version, this will need to be 5.10!
DISP_T = 2.00""",
"""# Display Geometry: EastRising 2.5" ERC13265FS-1
ACTIVE_W = 56.73
ACTIVE_H = 27.92
DISP_W   = 69.00
DISP_H   = 41.50
DISP_T = 5.20""")

with open(p, "w") as f:
    f.write(c)

print("generate_scad updated")
