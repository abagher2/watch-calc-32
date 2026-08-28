import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

user_layer = board.GetLayerID("User.Comments")
silk_layer = board.GetLayerID("F.Silkscreen")

# Find and delete the old CR2032 circles
to_delete = []
for dwg in board.GetDrawings():
    layer_name = board.GetLayerName(dwg.GetLayer())
    if layer_name == "User.Comments" or layer_name == "F.Silkscreen":
        if isinstance(dwg, pcbnew.PCB_TEXT):
            if "CR2032" in dwg.GetText():
                to_delete.append(dwg)
        elif isinstance(dwg, pcbnew.PCB_SHAPE):
            if dwg.GetShape() == pcbnew.SHAPE_T_CIRCLE:
                if dwg.GetStart().y / 1e6 < -110:
                    to_delete.append(dwg)

for d in to_delete:
    board.Remove(d)

# Draw the exact physical battery position (Centered and ABOVE the LCD!)
batt_x = 45.0 * 1e6
batt_y = -128.6 * 1e6
radius = 10.5 * 1e6

for layer_id in [user_layer, silk_layer]:
    circle = pcbnew.PCB_SHAPE(board)
    circle.SetShape(pcbnew.SHAPE_T_CIRCLE)
    circle.SetLayer(layer_id)
    circle.SetCenter(pcbnew.VECTOR2I(int(batt_x), int(batt_y)))
    circle.SetStart(pcbnew.VECTOR2I(int(batt_x), int(batt_y)))
    circle.SetEnd(pcbnew.VECTOR2I(int(batt_x + radius), int(batt_y)))
    circle.SetWidth(int(0.15 * 1e6))
    board.Add(circle)
    
    text = pcbnew.PCB_TEXT(board)
    text.SetText("CR2032 (21mm)")
    text.SetPosition(pcbnew.VECTOR2I(int(batt_x), int(batt_y)))
    text.SetLayer(layer_id)
    text.SetTextSize(pcbnew.VECTOR2I(int(1.5 * 1e6), int(1.5 * 1e6)))
    text.SetTextThickness(int(0.15 * 1e6))
    board.Add(text)

pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
print("Updated KiCad board with perfectly centered non-overlapping CR2032 footprint.")
