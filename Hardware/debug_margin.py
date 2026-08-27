import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
bbox = board.GetBoardEdgesBoundingBox()
y_max = bbox.GetBottom() / 1e6

disp = None
for f in board.GetFootprints():
    ref = f.GetReference()
    if ref == "J1":
        pos = f.GetPosition()
        disp = {'y': y_max - pos.y / 1e6}
        break

pcb_height = bbox.GetHeight() / 1e6
fp_h = pcb_height + 4.0
pad_y = (fp_h - pcb_height) / 2
disp_y = disp['y'] + pad_y + 5.35

print(f"disp_y = {disp_y}")
print(f"Top margin (fp_h - disp_y - DISP_H/2) = {fp_h - disp_y - 35.28/2}") # wait, DISP_H is 35.28? Wait, ACTIVE_H is 35.28! DISP_H = 39.0
print(f"Top margin (fp_h - disp_y - 39.0/2) = {fp_h - disp_y - 39.0/2}")
