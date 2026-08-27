import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_max = bbox.GetBottom() / 1e6
y_min = bbox.GetY() / 1e6

print(f"PCB X: {x_min} to {bbox.GetRight()/1e6}")
print(f"PCB Y: {y_min} to {y_max}")

buttons = []
for fp in board.GetFootprints():
    ref = fp.GetReference()
    pos = fp.GetPosition()
    sx = pos.x / 1e6 - x_min
    sy = y_max - pos.y / 1e6
    val = fp.GetValue()
    if ref.startswith("SOFT") or ref.startswith("B"):
        buttons.append((ref, val, sx, sy))
    if "Disp" in ref or "OLED" in ref or ref == "J1":
        print(f"Display {ref}: {sx}, {sy}")

buttons.sort(key=lambda b: b[3], reverse=True)
for b in buttons:
    print(f"{b[0]} ({b[1]}): X={b[2]:.2f}, Y={b[3]:.2f}")
