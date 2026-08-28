import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

for dwg in board.GetDrawings():
    layer = dwg.GetLayer()
    layer_name = board.GetLayerName(layer)
    if layer_name == "F.Silkscreen":
        if isinstance(dwg, pcbnew.PCB_SHAPE):
            if dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
                print(f"{layer_name}: Line from {dwg.GetStart().x/1e6}, {dwg.GetStart().y/1e6} to {dwg.GetEnd().x/1e6}, {dwg.GetEnd().y/1e6}")

