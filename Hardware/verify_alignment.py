import sys
import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_min = bbox.GetY() / 1e6
y_max = bbox.GetBottom() / 1e6
pcb_height = y_max - y_min

print(f"PCB Height: {pcb_height}mm")

mcu = None
disp = None
buttons = []
for fp in board.Footprints():
    ref = fp.GetReference()
    y_pos = y_max - fp.GetPosition().y / 1e6  # 0 at bottom, increasing upwards
    if ref in ["U1", "MCU1"] or fp.GetValue() == "promicro":
        mcu = y_pos
    elif ref == "Disp":
        disp = y_pos
    elif "B" in ref and len(ref) <= 3:
        buttons.append(y_pos)

if buttons:
    top_button = max(buttons)
    bottom_button = min(buttons)
    print(f"Top Button Y: {top_button:.2f}mm")
    print(f"Bottom Button Y: {bottom_button:.2f}mm")
else:
    print("No buttons found.")

if mcu:
    print(f"MCU Y: {mcu:.2f}mm")
if disp:
    print(f"Display Y: {disp:.2f}mm")
    
if mcu and buttons:
    print(f"Gap between Top Button and MCU: {mcu - top_button:.2f}mm")
    
