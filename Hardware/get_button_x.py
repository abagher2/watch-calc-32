import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew
import generate_scad

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
x_max = bbox.GetRight() / 1e6

buttons = []
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref.startswith("B") and len(ref) <= 3 and ref[1:].isdigit():
        pos = fp.GetPosition()
        sx = pos.x / 1e6 - x_min
        buttons.append(sx)
    elif ref.startswith("SOFT"):
        pos = fp.GetPosition()
        sx = pos.x / 1e6 - x_min
        buttons.append(sx)

print(f"Min button X (from left edge of PCB): {min(buttons)}")
print(f"Max button X (from left edge of PCB): {max(buttons)}")
print(f"PCB width: {x_max - x_min}")
