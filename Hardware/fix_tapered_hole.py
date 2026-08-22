with open("generate_scad.py", "r") as f:
    orig = f.read()

# We need to replace pt + 0.1 with pt + 5.0 but ONLY in fp_tapered!
# Let's find the fp_tapered block!
target = 'disp_cut_orig = f"translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 3.0])"'
replacement = 'disp_cut_orig = f"translate([{disp_x:.3f} - POCKET_W/2, {disp_y:.3f} - POCKET_H/2, pt + 0.1])"'

orig = orig.replace(target, replacement)

with open("generate_scad.py", "w") as f:
    f.write(orig)
