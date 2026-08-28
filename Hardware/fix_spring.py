with open("generate_scad.py", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if "translate([0, 0, -0.1]) cylinder(r=r_center + spring_gap + arm_w + 0.3" in line:
        new_lines.append("    r_hole = r_center + spring_gap + arm_w + 0.3;\n")
        new_lines.append("    translate([0, 0, -0.1]) cylinder(r=r_hole, h=0.8, $fn=32);\n")
    elif "spiral_arm(1.5, r_center+spring_gap, arm_w, 180)" in line:
        new_lines.append("        r_hole = r_center + spring_gap + arm_w + 0.3;\n")
        new_lines.append("        r2 = r_hole - arm_w + 0.1;\n")
        new_lines.append("        for(i=[0:2]) rotate([0, 0, i*120]) translate([0,0,0]) linear_extrude(1.0) spiral_arm(1.5, r2, arm_w, 180);\n")
    else:
        new_lines.append(line)

with open("generate_scad.py", "w") as f:
    f.writelines(new_lines)
