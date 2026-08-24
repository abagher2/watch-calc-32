import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
print(f"BBox: X={bbox.GetX()/1000000.0} to {bbox.GetRight()/1000000.0}, Y={bbox.GetY()/1000000.0} to {bbox.GetBottom()/1000000.0}")
