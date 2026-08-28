import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
x_max = bbox.GetRight() / 1e6
y_min = bbox.GetY() / 1e6
y_max = bbox.GetBottom() / 1e6

min_comp_x = 999999
max_comp_x = -999999
min_comp_y = 999999
max_comp_y = -999999

for fp in board.GetFootprints():
    ref = fp.GetReference()
    fp_bbox = fp.GetBoundingBox()
    
    # Check footprint bounding box limits
    left = fp_bbox.GetX() / 1e6
    right = fp_bbox.GetRight() / 1e6
    top = fp_bbox.GetY() / 1e6
    bottom = fp_bbox.GetBottom() / 1e6
    
    if left < min_comp_x: min_comp_x = left
    if right > max_comp_x: max_comp_x = right
    if top < min_comp_y: min_comp_y = top
    if bottom > max_comp_y: max_comp_y = bottom

print(f"PCB Width: {x_max - x_min:.2f}mm (X: {x_min:.2f} to {x_max:.2f})")
print(f"Component Bounds X: {min_comp_x:.2f} to {max_comp_x:.2f}")
print(f"Left Margin: {min_comp_x - x_min:.2f}mm")
print(f"Right Margin: {x_max - max_comp_x:.2f}mm")
print(f"Top Margin: {min_comp_y - y_min:.2f}mm")
print(f"Bottom Margin: {y_max - max_comp_y:.2f}mm")
