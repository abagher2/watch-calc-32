import sys
import os
import pcbnew

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref == 'JST1':
        # Move it to top edge: x=35.0mm, y=-140.0mm
        fp.SetPosition(pcbnew.VECTOR2I(int(35.0 * 1e6), int(-140.0 * 1e6)))
        # Make sure it's rotated correctly (facing outwards?)
        # Originally at y=-8.0, orientation might have been facing down.
        # Let's rotate 180 degrees so it faces up? Or just keep original orientation for now.
        print(f"Moved JST1 to {fp.GetPosition().x/1e6}, {fp.GetPosition().y/1e6}")

pcbnew.SaveBoard('output/pcbs/calculator.kicad_pcb', board)
