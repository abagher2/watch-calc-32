import re
with open("designs/sf_glyphs.scad", "r") as f:
    lines = f.readlines()

out = []
for line in lines:
    if "polygon(" in line:
        # count number of points, e.g. [-0.01, -36.62]
        pts = line.count("]") - 1 # rough heuristic
        if pts < 3:
            continue
    out.append(line)

with open("designs/sf_glyphs.scad", "w") as f:
    f.writelines(out)
