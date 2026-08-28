import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Update WALL
content = re.sub(r'WALL\s*=\s*1\.6', 'WALL = 1.0', content)

# Update Middle Cavity to 69.4mm wide (69.0mm LCD + 0.4mm clearance)
# Old: cube([72.0, {TACTILE_H} + 0.2, ch + 0.1]);
# Old translate: translate([(cw - 72.0)/2, {FRONT_LIP} + pt - 0.1, wall])
new_middle_cavity = """
        // Middle Cavity: Separates Faceplate and PCB on the edges to form sliding rails!
        // The display glass is 69.0mm wide, so we make this 69.4mm wide.
        translate([(cw - 69.4)/2, {FRONT_LIP} + pt - 0.1, wall])
            cube([69.4, {TACTILE_H} + 0.2, ch + 0.1]);
"""
content = re.sub(
    r'\s*// Middle Cavity: Hollows out the center for the Display to slide down!.*?cube\[72\.0, \{TACTILE_H\} \+ 0\.2, ch \+ 0\.1\];',
    new_middle_cavity.strip("\n"),
    content,
    flags=re.DOTALL
)

# Update fp_w calculation so the faceplate is 72.0mm wide (same as PCB!) to slide into the same 72.4mm cavity width.
# Old: fp_w = cw - 2*WALL - 0.4
# We want fp_w to be strictly 72.0, or derived from pcb_width.
# Let's just set fp_w = pcb_width.
content = re.sub(r'fp_w\s*=\s*cw - 2\*WALL - 0\.4', 'fp_w = pcb_width', content)

# Check Faceplate cavity
# translate([offset_x - 0.2, {FRONT_LIP} - 0.2, wall])
# offset_x = (cw - fp_w)/2. With cw=74.4, fp_w=72.0, offset_x = 1.2.
# So faceplate cavity width = fp_w + 0.4 = 72.4. This perfectly creates a 1.2mm rail on each side! 
# Wait, user wanted 1.5mm rail?
# If cw = 74.4, and fp_w = 72.0. The outer wall is WALL=1.0. 
# Total inner width = 72.4. So (72.4 - 69.4) / 2 = 1.5mm rail holding the faceplate/PCB in!
# This is mathematically perfect.

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)

print("Updated chassis to use sliding rails.")
