import pcbnew
import sys

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# We want to remove the old LCD outlines from F.Silkscreen
# The new LCD glass is X: 10.5 to 79.5, Y: -131.25 to -89.75
# The active area is X: 16.635 to 73.365, Y: -124.46 to -96.54

to_delete = []

for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.F_SilkS and isinstance(dwg, pcbnew.PCB_SHAPE):
        if dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
            # Check if it's in the display region
            sy = dwg.GetStart().y / 1e6
            ey = dwg.GetEnd().y / 1e6
            if sy < -80 and ey < -80: # It's in the display area
                # Is it the new LCD glass?
                sx = dwg.GetStart().x / 1e6
                ex = dwg.GetEnd().x / 1e6
                
                # Check if it matches exactly the new LCD Glass
                is_new_glass = (
                    (abs(sx - 10.5) < 0.1 and abs(ex - 10.5) < 0.1) or
                    (abs(sx - 79.5) < 0.1 and abs(ex - 79.5) < 0.1) or
                    (abs(sy + 131.25) < 0.1 and abs(ey + 131.25) < 0.1) or
                    (abs(sy + 89.75) < 0.1 and abs(ey + 89.75) < 0.1)
                ) and (
                    min(sx, ex) >= 10.4 and max(sx, ex) <= 79.6
                ) and (
                    max(sy, ey) <= -89.6 and min(sy, ey) >= -131.3
                )
                
                if not is_new_glass:
                    to_delete.append(dwg)
                else:
                    # It's already the new glass, we keep it!
                    pass

for dwg in to_delete:
    board.Remove(dwg)

print(f"Deleted {len(to_delete)} old lines from F.Silkscreen.")
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
print("SUCCESS!")
