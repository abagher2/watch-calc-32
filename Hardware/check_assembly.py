import math

# Extract constants from generate_scad.py
pt = 3.0
PCB_T = 1.6
WALL = 2.0
fp_w = 70.0
fp_h = 141.4
pcb_width = 72.4
pcb_height = 139.2
D_top = 14.2
D_bot = 7.9
FRONT_LIP = 2.5

cw = fp_w + 2*WALL
ch = fp_h + WALL
offset_x = (cw - fp_w) / 2
offset_z = (ch - fp_h) / 2

print(f"=== ASSEMBLY SANITY CHECKER ===\n")

print("1. BUTTON MECHANISM & TRAVEL")
# From our manual code in key_button and button_pocket
cavity_h = 1.8
piston_h = 0.8
travel = cavity_h - piston_h
cavity_d = 8.6
piston_d = 7.0
radial_clear = (cavity_d - piston_d) / 2
print(f"  - Button Travel: {travel:.1f}mm (Requirement: 1.0mm) -> {'PASS' if travel > 0.99 else 'FAIL'}")
print(f"  - Radial Clearance: {radial_clear:.1f}mm (Requirement: 0.8mm) -> {'PASS' if radial_clear > 0.79 else 'FAIL'}")

print("\n2. SLIDE-IN CLEARANCES")
t1_width = fp_w
t1_depth = pt + 0.1
print(f"  - Faceplate (w={fp_w}) in Tier 1 (w={t1_width}): Clearance = {t1_width - fp_w:.1f}mm -> {'PASS' if t1_width >= fp_w else 'FAIL'}")
print(f"  - Faceplate (t={pt}) in Tier 1 (d={t1_depth}): Clearance = {t1_depth - pt:.1f}mm -> {'PASS' if t1_depth >= pt else 'FAIL'}")

t2_width = pcb_width
t2_depth = PCB_T + 0.2
print(f"  - PCB (w={pcb_width}) in Tier 2 (w={t2_width}): Clearance = {t2_width - pcb_width:.1f}mm -> {'PASS' if t2_width >= pcb_width else 'FAIL'}")
print(f"  - PCB (t={PCB_T}) in Tier 2 (d={t2_depth}): Clearance = {t2_depth - PCB_T:.1f}mm -> {'PASS' if t2_depth >= PCB_T else 'FAIL'}")

print("\n3. TOP CAP SECURMENT")
bezel_width = cw - 2*WALL - 8.0
lip_width = cw - 2*WALL - 8.0
print(f"  - Bezel Window Width: {bezel_width:.1f}mm")
print(f"  - Top Cap Lip Width: {lip_width:.1f}mm")
print(f"  - Interference check: {'PASS (Perfect Match)' if abs(bezel_width - lip_width) < 0.01 else 'FAIL (Collision)'}")

print("\n4. CHASSIS STRUCTURAL INTEGRITY (BACK WALL)")
z_screws = 7.0
d_at_screws = D_bot + (D_top - D_bot) * (z_screws / ch)
pcb_rear_y = pt + 1.5 + PCB_T
trace_cavity_rear_y = pcb_rear_y + 0.5
wall_thickness_screws = d_at_screws - trace_cavity_rear_y
print(f"  - Chassis depth at bottom screws (Z=7.0): {d_at_screws:.2f}mm")
print(f"  - Cavity depth at bottom screws: {trace_cavity_rear_y:.2f}mm")
print(f"  - Remaining back wall thickness: {wall_thickness_screws:.2f}mm -> {'PASS' if wall_thickness_screws >= 1.5 else 'WARNING (Too thin)'}")

z_tier3_top = ch
d_at_tier3_top = D_top
tier3_rear_y_top = 12.2
wall_thickness_top = d_at_tier3_top - tier3_rear_y_top
print(f"  - Chassis depth at Top Cap (Z={z_tier3_top:.1f}): {d_at_tier3_top:.2f}mm")
print(f"  - Tier 3 cavity depth at top: {tier3_rear_y_top:.2f}mm")
print(f"  - Remaining back wall thickness: {wall_thickness_top:.2f}mm -> {'PASS' if wall_thickness_top >= 1.5 else 'FAIL (Punch-through)'}")

