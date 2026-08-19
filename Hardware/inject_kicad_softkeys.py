import pcbnew
import sys

pcb_file = "output/pcbs/calculator.kicad_pcb"
board = pcbnew.LoadBoard(pcb_file)

btns = []
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if "B" in ref and len(ref) <= 3:
        btns.append(fp)

# KiCad Y increases going downwards. So the top row has the minimum Y values.
btns.sort(key=lambda fp: fp.GetPosition().y)
top_row = btns[:6]

# Ensure we haven't already injected soft keys to avoid duplicates
has_softkeys = any(fp.GetReference().startswith("SOFT") for fp in board.GetFootprints())

if not has_softkeys:
    for i, fp in enumerate(top_row):
        new_fp = pcbnew.Footprint(board)
        # Duplicate the tactile switch footprint
        new_fp.SetFPID(fp.GetFPID())
        
        # Position it exactly 11.5mm lower (Y + 11.5mm)
        pos = pcbnew.VECTOR2I(fp.GetPosition().x, fp.GetPosition().y + int(11.5 * 1e6))
        new_fp.SetPosition(pos)
        
        # Set reference to SOFT1..SOFT6
        new_fp.SetReference(f"SOFT{i+1}")
        
        # Add to board
        board.Add(new_fp)

    pcbnew.SaveBoard(pcb_file, board)
    print("Successfully injected 6 Soft Key footprints into calculator.kicad_pcb")
else:
    print("Soft keys already exist in the PCB.")
