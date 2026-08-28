import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for fp in board.GetFootprints():
    fp_bbox = fp.GetBoundingBox()
    left = fp_bbox.GetX() / 1e6
    right = fp_bbox.GetRight() / 1e6
    bottom = fp_bbox.GetBottom() / 1e6
    if left < 5 or right > 85 or bottom > 5:
        print(f"{fp.GetReference()} is out of bounds! L: {left}, R: {right}, B: {bottom}")
