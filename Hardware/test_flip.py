import pcbnew
import sys

board_path = "output/pcbs/calculator.kicad_pcb"
print(f"Loading {board_path}")
try:
    board = pcbnew.LoadBoard(board_path)
except Exception as e:
    print(f"Failed to load board: {e}")
    sys.exit(1)

mcu = board.FindFootprintByReference("MCU1")
if not mcu:
    mcu = board.FindFootprintByReference("U1")
if not mcu:
    for fp in board.GetFootprints():
        if "Pico" in fp.GetValue() or "RP2040" in fp.GetValue():
            mcu = fp
            break

if not mcu:
    print("Could not find MCU!")
    sys.exit(1)

print(f"Found MCU: {mcu.GetReference()} / {mcu.GetValue()}")
print(f"Current Layer: {mcu.GetLayer()} (F_Cu is {pcbnew.F_Cu}, B_Cu is {pcbnew.B_Cu})")

# Flip unconditionally
mcu.Flip(mcu.GetPosition(), False)
print(f"Layer after flip: {mcu.GetLayer()}")

jst = None
for fp in board.GetFootprints():
    if "JST" in fp.GetReference() or "JST" in fp.GetValue():
        jst = fp
        break

if jst:
    print(f"Found JST: {jst.GetReference()}")
    print(f"Current Layer: {jst.GetLayer()}")
    jst.Flip(jst.GetPosition(), False)
    print(f"Layer after flip: {jst.GetLayer()}")
else:
    print("Could not find JST!")
