import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6

disp_x = None
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref == "J1" or "LCD" in ref:
        pos = fp.GetPosition()
        disp_x = pos.x / 1e6 - x_min
        print(f"Found {ref} at X={disp_x}")

if disp_x is None:
    print("Could not find display footprint!")
