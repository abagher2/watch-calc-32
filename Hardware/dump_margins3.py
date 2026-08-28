import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
x_max = bbox.GetRight() / 1e6
y_min = bbox.GetY() / 1e6
y_max = bbox.GetBottom() / 1e6

min_comp_x = 999999
max_comp_x = -999999

for fp in board.GetFootprints():
    if fp.GetReference().startswith("FID"): continue
    
    fp_bbox = fp.GetBoundingBox()
    left = fp_bbox.GetX() / 1e6
    right = fp_bbox.GetRight() / 1e6
    
    if left < min_comp_x: min_comp_x = left
    if right > max_comp_x: max_comp_x = right

print(f"PCB X_MIN: {x_min:.2f}, X_MAX: {x_max:.2f}")
print(f"Left Margin (Clearance): {min_comp_x - x_min:.2f}mm")
print(f"Right Margin (Clearance): {x_max - max_comp_x:.2f}mm")
