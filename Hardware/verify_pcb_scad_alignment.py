import sys
import pcbnew
import re

print("========================================")
print(" PCB vs SCAD ALIGNMENT VERIFIER ")
print("========================================")

# 1. Read PCB Dimensions
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_min = bbox.GetY() / 1e6
x_max = bbox.GetRight() / 1e6
y_max = bbox.GetBottom() / 1e6

pcb_width = x_max - x_min
pcb_height = y_max - y_min
print(f"PCB Dimensions: {pcb_width:.2f} x {pcb_height:.2f} mm")

# 2. Read SCAD Dimensions
scad_width = 0
scad_height = 0
try:
    with open("designs/faceplate.scad", "r") as f:
        scad_data = f.read()
        w_match = re.search(r"faceplate_width\s*=\s*([\d\.]+);", scad_data)
        h_match = re.search(r"faceplate_height\s*=\s*([\d\.]+);", scad_data)
        if w_match: scad_width = float(w_match.group(1))
        if h_match: scad_height = float(h_match.group(1))
    print(f"SCAD Dimensions: {scad_width:.2f} x {scad_height:.2f} mm")
except FileNotFoundError:
    print("SCAD file not generated yet.")

# 3. Verify Footprint inside bounds
mcu = None
disp = None
buttons = []
for fp in board.Footprints():
    ref = fp.GetReference()
    y_pos = y_max - fp.GetPosition().y / 1e6
    if ref in ["U1", "MCU1"] or fp.GetValue() == "promicro":
        mcu = y_pos
    elif ref == "Disp":
        disp = y_pos
    elif "B" in ref and len(ref) <= 3:
        buttons.append(y_pos)

print("\n--- Internal Component Placement ---")
if mcu:
    print(f"MCU Center Y: {mcu:.2f} mm (Distance to Top Edge: {pcb_height - mcu:.2f} mm)")
if disp:
    print(f"Display Y: {disp:.2f} mm (Distance to Top Edge: {pcb_height - disp:.2f} mm)")
    
if buttons:
    top_button = max(buttons)
    print(f"Top Button Row Y: {top_button:.2f} mm")
    if disp:
        print(f"Gap between Top Button and Display: {disp - top_button:.2f} mm")

print("\n--- Verdict ---")
if abs((pcb_width + 4) - scad_width) < 0.1 and abs((pcb_height + 4) - scad_height) < 0.1:
    print("✅ SUCCESS: PCB perfectly matches SCAD dimensions!")
else:
    print("❌ ERROR: Mismatch between PCB and SCAD!")

if mcu and (pcb_height - mcu) < 15:
    print("⚠️ WARNING: MCU is dangerously close to the top edge!")
else:
    print("✅ SUCCESS: MCU has adequate routing clearance at the top edge.")
