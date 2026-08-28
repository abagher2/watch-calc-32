import pcbnew
import sys
import os

pcb_file = "calculator.kicad_pcb"

print(f"Loading {pcb_file}...")
board = pcbnew.LoadBoard(pcb_file)

jst_fp = board.FindFootprintByReference("JST1")
if not jst_fp:
    print("Error: Could not find JST1")
    sys.exit(1)

pos = jst_fp.GetPosition()
current_x_mm = pos.x / 1e6
current_y_mm = pos.y / 1e6

print(f"Current JST1 Position: ({current_x_mm:.3f}, {current_y_mm:.3f}) mm")

new_y_mm = -128.0
print(f"Moving JST1 to ({current_x_mm:.3f}, {new_y_mm:.3f}) mm...")

pos.y = int(new_y_mm * 1e6)
jst_fp.SetPosition(pos)

print("Saving PCB...")
pcbnew.SaveBoard(pcb_file, board)
print("Done!")
