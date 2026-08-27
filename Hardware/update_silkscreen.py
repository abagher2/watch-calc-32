import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Update Text
for dwg in board.GetDrawings():
    if isinstance(dwg, pcbnew.PCB_TEXT):
        txt = dwg.GetText()
        if "SHARP LS027B7DH01" in txt:
            dwg.SetText("ERC12864FSF-6 (2.7\")")

# Find and remove old screen bounding box lines
to_remove = []
for dwg in board.GetDrawings():
    if isinstance(dwg, pcbnew.PCB_SHAPE) and dwg.GetLayerName() == "F.SilkS":
        # Check if it's one of the old screen lines
        # Old X: 13.3 to 76.7, Old Y: -89 to -132
        bb = dwg.GetBoundingBox()
        x = pcbnew.ToMM(bb.GetX())
        y = pcbnew.ToMM(bb.GetY())
        # Roughly check if it's in the top screen area
        if -135 < y < -85:
            to_remove.append(dwg)

for item in to_remove:
    board.Remove(item)

# Draw new screen bounding box (71.2 x 43.3 mm, centered at 45.0, -110.5)
# Left: 9.4, Right: 80.6, Top: -132.15, Bottom: -88.85
def draw_silk_line(x1, y1, x2, y2):
    line = pcbnew.PCB_SHAPE(board)
    line.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1)))
    line.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x2), pcbnew.FromMM(y2)))
    line.SetLayer(pcbnew.F_SilkS)
    line.SetWidth(pcbnew.FromMM(0.15))
    board.Add(line)

draw_silk_line(9.4, -132.15, 80.6, -132.15) # Top
draw_silk_line(80.6, -132.15, 80.6, -88.85) # Right
draw_silk_line(80.6, -88.85, 9.4, -88.85)   # Bottom
draw_silk_line(9.4, -88.85, 9.4, -132.15)   # Left

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Updated silkscreen for new 2.7-inch display.")
