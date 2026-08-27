import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Remove all existing Edge.Cuts and Cmts.User
to_remove = []
for dwg in board.GetDrawings():
    if dwg.GetLayerName() in ["Edge.Cuts", "Cmts.User"]:
        to_remove.append(dwg)
    # Also remove LCD Outline in F.SilkS
    if isinstance(dwg, pcbnew.PCB_SHAPE) and dwg.GetLayerName() == "F.SilkS":
        bb = dwg.GetBoundingBox()
        y = pcbnew.ToMM(bb.GetY())
        if -145 < y < -85: # roughly the LCD area
            to_remove.append(dwg)

for item in to_remove:
    board.Remove(item)

# Draw 71mm wide Edge.Cuts (Centered at X=45.0 -> Left 9.5, Right 80.5)
def draw_rect(layer, x1, y1, width, height, thickness=0.1):
    l1 = pcbnew.PCB_SHAPE(board)
    l1.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l1.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1)))
    l1.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1)))
    l1.SetLayer(layer)
    l1.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l1)
    
    l2 = pcbnew.PCB_SHAPE(board)
    l2.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l2.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1+height)))
    l2.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1+height)))
    l2.SetLayer(layer)
    l2.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l2)
    
    l3 = pcbnew.PCB_SHAPE(board)
    l3.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l3.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1)))
    l3.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1+height)))
    l3.SetLayer(layer)
    l3.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l3)
    
    l4 = pcbnew.PCB_SHAPE(board)
    l4.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l4.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1)))
    l4.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1+height)))
    l4.SetLayer(layer)
    l4.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l4)

draw_rect(pcbnew.Edge_Cuts, 9.5, -138.0, 71.0, 138.0, 0.1)

# Draw F.SilkS LCD Outline (69.0 x 41.5, centered at 45.0, -110.5)
draw_rect(pcbnew.F_SilkS, 45.0 - 34.5, -110.5 - 20.75, 69.0, 41.5, 0.15)

# Re-position Buttons to fit in 71mm and squeeze Top Row
spacing = 11.5 # Adjusted spacing for 71mm width
C1 = 45.0 - 2.5 * spacing
C2 = 45.0 - 1.5 * spacing
C3 = 45.0 - 0.5 * spacing
C4 = 45.0 + 0.5 * spacing
C5 = 45.0 + 1.5 * spacing
C6 = 45.0 + 2.5 * spacing

columns_6 = [C1, C2, C3, C4, C5, C6]
columns_enter = [(C1+C2)/2.0, C3, C4, C5, C6]
columns_bottom = [C1, C3, C4, C5, C6]

spacing_top = 9.45
C1_t = 45.0 - 2.5 * spacing_top
C2_t = 45.0 - 1.5 * spacing_top
C3_t = 45.0 - 0.5 * spacing_top
C4_t = 45.0 + 0.5 * spacing_top
C5_t = 45.0 + 1.5 * spacing_top
C6_t = 45.0 + 2.5 * spacing_top
columns_6_top = [C1_t, C2_t, C3_t, C4_t, C5_t, C6_t]

footprints = board.GetFootprints()
buttons = []
for fp in footprints:
    val = fp.GetValue()
    if "Tactile" in val:
        buttons.append(pcbnew.Cast_to_FOOTPRINT(fp))

buttons.sort(key=lambda b: b.GetPosition().y)

rows = []
cur_row = []
cur_y = buttons[0].GetPosition().y if buttons else 0
for b in buttons:
    if abs(b.GetPosition().y - cur_y) > 2*1e6:
        cur_row.sort(key=lambda x: x.GetPosition().x)
        rows.append(cur_row)
        cur_row = []
        cur_y = b.GetPosition().y
    cur_row.append(b)
if cur_row:
    cur_row.sort(key=lambda x: x.GetPosition().x)
    rows.append(cur_row)

for r_idx, row in enumerate(rows):
    target_y = int(row[0].GetPosition().y) # Keep same Y
    if len(row) == 6:
        if r_idx == 0:
            for c_idx, b in enumerate(row):
                b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_6_top[c_idx]), target_y))
        else:
            for c_idx, b in enumerate(row):
                b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_6[c_idx]), target_y))
    elif len(row) == 5:
        if r_idx == 3: # Enter row
            for c_idx, b in enumerate(row):
                b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_enter[c_idx]), target_y))
        else: # Rows 4, 5, 6, 7
            for c_idx, b in enumerate(row):
                b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_bottom[c_idx]), target_y))

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Set 71mm PCB Width, adjusted button spacing, cleared tracks.")
