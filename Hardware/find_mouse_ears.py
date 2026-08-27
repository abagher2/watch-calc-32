import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")
for d in board.GetDrawings():
    if isinstance(d, pcbnew.PCB_SHAPE):
        bb = d.GetBoundingBox()
        if bb.GetY() / 1e6 < -138.5:
            print(f"Found shape on layer {d.GetLayerName()}: Y = {bb.GetY()/1e6} to {bb.GetBottom()/1e6}")
            board.Remove(d)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Removed mouse ears and saved.")
