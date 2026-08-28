import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.Edge_Cuts:
        print(f"Edge Cut: {dwg.GetShapeStr()} at {dwg.GetStart().x/1e6}, {dwg.GetStart().y/1e6}")
