import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
y_min = min([f.GetPosition().y for f in board.GetFootprints()]) / 1000000.0
y_max = max([f.GetPosition().y for f in board.GetFootprints()]) / 1000000.0

disp = None
for f in board.GetFootprints():
    ref = f.GetReference()
    if ref == "J1":
        pos = f.GetPosition()
        disp = {'x': pos.x / 1e6, 'y': pos.y / 1e6}
        break

print(f"y_min = {y_min}")
print(f"y_max = {y_max}")
print(f"disp_pos_y = {disp['y']}")
