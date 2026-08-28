import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
x_max = bbox.GetRight() / 1e6
y_min = bbox.GetY() / 1e6
y_max = bbox.GetBottom() / 1e6

min_comp_y = 999999
max_comp_y = -999999

for fp in board.GetFootprints():
    if fp.GetReference().startswith("FID"): continue
    
    fp_bbox = fp.GetBoundingBox()
    top = fp_bbox.GetY() / 1e6
    bottom = fp_bbox.GetBottom() / 1e6
    
    if top < min_comp_y: min_comp_y = top
    if bottom > max_comp_y: max_comp_y = bottom

print(f"PCB Y_MIN: {y_min:.2f}, Y_MAX: {y_max:.2f}")
print(f"Top Margin (Clearance): {min_comp_y - y_min:.2f}mm")
print(f"Bottom Margin (Clearance): {y_max - max_comp_y:.2f}mm")
