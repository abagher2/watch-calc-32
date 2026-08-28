import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
bbox   = board.GetBoardEdgesBoundingBox()
print(f"X min: {bbox.GetX()/1e6}, X max: {bbox.GetRight()/1e6}")
print(f"Y min: {bbox.GetY()/1e6}, Y max: {bbox.GetBottom()/1e6}")
print(f"Width: {bbox.GetWidth()/1e6}, Height: {bbox.GetHeight()/1e6}")
