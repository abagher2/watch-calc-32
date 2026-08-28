import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.Edge_Cuts and isinstance(dwg, pcbnew.PCB_SHAPE):
        if dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
            print(f"Line from {dwg.GetStart().x/1e6}, {dwg.GetStart().y/1e6} to {dwg.GetEnd().x/1e6}, {dwg.GetEnd().y/1e6}")
        elif dwg.GetShape() == pcbnew.SHAPE_T_ARC:
            print(f"Arc at {dwg.GetCenter().x/1e6}, {dwg.GetCenter().y/1e6}")
