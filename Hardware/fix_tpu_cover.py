import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

target = """        ACTIVE_W = 49.0; ACTIVE_H = 24.0;
        translate([{disp_x:.3f} - ACTIVE_W/2, -cover_t-0.1, {disp_y:.3f} - ACTIVE_H/2])
            cube([ACTIVE_W, cover_t+0.2, ACTIVE_H]);
            
        translate([cover_t, -cover_t-0.1, cover_t])
            cube([cw - 2*cover_t, cover_t+0.2, ch - 50.0]);"""

repl = """        // Inner pocket for screen and buttons so they don't get pressed!
        // The buttons now protrude 1.5mm, so a 2.0mm deep pocket is needed.
        // Since cover_t = 3.0 now, we leave 1.0mm of solid TPU covering the front.
        translate([wall, -2.0, wall])
            cube([cw - 2*wall, 2.1, ch - 2*wall]);"""

# The target might be slightly different. Let's use regex to replace everything inside the difference() except the first two cubes.
# Wait, I previously tried to replace the pocket but it failed silently because it wasn't matching perfectly.

orig = re.sub(r'        ACTIVE_W = 49\.0;.*?ch - 50\.0\]\);\n', repl + '\n', orig, flags=re.DOTALL)

with open("generate_scad.py", "w") as f:
    f.write(orig)
