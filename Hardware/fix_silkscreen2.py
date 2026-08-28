import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
to_delete = []

for dwg in board.GetDrawings():
    layer = dwg.GetLayer()
    layer_name = board.GetLayerName(layer)
    if layer_name == "F.Silkscreen" and isinstance(dwg, pcbnew.PCB_SHAPE) and dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
        sy = dwg.GetStart().y / 1e6
        ey = dwg.GetEnd().y / 1e6
        if sy < -80 and ey < -80:
            to_delete.append(dwg)

for dwg in to_delete:
    board.Remove(dwg)

print(f"Deleted {len(to_delete)} remaining LCD lines from F.Silkscreen.")
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
