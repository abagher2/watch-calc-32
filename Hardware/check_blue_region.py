import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for zone in board.Zones():
    print(f"Zone on layer {board.GetLayerName(zone.GetLayer())} at {zone.GetBoundingBox().GetX()/1e6}, {zone.GetBoundingBox().GetY()/1e6}")

for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.B_Cu:
        print(f"Drawing on B.Cu: {dwg}")
