import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
x_min = min([f.GetPosition().x for f in board.GetFootprints()]) / 1000000.0
x_max = max([f.GetPosition().x for f in board.GetFootprints()]) / 1000000.0
y_min = min([f.GetPosition().y for f in board.GetFootprints()]) / 1000000.0
y_max = max([f.GetPosition().y for f in board.GetFootprints()]) / 1000000.0

disp = None
for f in board.GetFootprints():
    ref = f.GetReference()
    if ref == "J1":
        pos = f.GetPosition()
        disp = {'x': pos.x / 1e6 - x_min, 'y': y_max - pos.y / 1e6}
        break

pcb_height = board.GetBoardEdgesBoundingBox().GetHeight() / 1000000.0
pcb_width = x_max - x_min
fp_h = pcb_height + 4.0
fp_w = pcb_width + 4.0
pad_y = (fp_h - pcb_height) / 2
pad_x = (fp_w - pcb_width) / 2
disp_y = disp['y'] + pad_y + 5.35
disp_x = fp_w / 2

print(f"pcb_height = {pcb_height}")
print(f"fp_h = {fp_h}")
print(f"fp_w = {fp_w}")
print(f"disp_y = {disp_y}")
print(f"disp_x = {disp_x}")
print(f"pad_y = {pad_y}")
print(f"pad_x = {pad_x}")
print(f"Top space = fp_h - (disp_y + 35.28/2) = {fp_h - (disp_y + 35.28/2)}")
