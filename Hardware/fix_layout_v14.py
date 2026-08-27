import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Remove all existing Edge.Cuts
edges = [d for d in board.GetDrawings() if d.GetLayerName() == "Edge.Cuts"]
for dwg in edges:
    board.Remove(dwg)
        
# Remove Boss and Battery labels and CMTS User clearance lines
to_remove = []
for dwg in board.GetDrawings():
    if isinstance(dwg, pcbnew.PCB_TEXT):
        txt = dwg.GetText()
        if "BOSS" in txt or "BATTERY" in txt:
            to_remove.append(dwg)
    if dwg.GetLayerName() == "Cmts.User":
        to_remove.append(dwg)

for item in to_remove:
    board.Remove(item)

# Draw 70mm wide Edge.Cuts (X: 10.0 to 80.0, Y: 0.0 to -138.0)
def draw_line(x1, y1, x2, y2):
    line = pcbnew.PCB_SHAPE(board)
    line.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1)))
    line.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x2), pcbnew.FromMM(y2)))
    line.SetLayer(pcbnew.Edge_Cuts)
    line.SetWidth(pcbnew.FromMM(0.1))
    board.Add(line)

draw_line(10.0, 0.0, 80.0, 0.0)
draw_line(80.0, 0.0, 80.0, -138.0)
draw_line(80.0, -138.0, 10.0, -138.0)
draw_line(10.0, -138.0, 10.0, 0.0)

# Re-position Buttons to fit in 70mm
spacing = 11.0 # Tighter spacing
C1 = 45.0 - 2.5 * spacing
C2 = 45.0 - 1.5 * spacing
C3 = 45.0 - 0.5 * spacing
C4 = 45.0 + 0.5 * spacing
C5 = 45.0 + 1.5 * spacing
C6 = 45.0 + 2.5 * spacing

columns_6 = [C1, C2, C3, C4, C5, C6]
columns_enter = [(C1+C2)/2.0, C3, C4, C5, C6]
columns_bottom = [C1, C3, C4, C5, C6]

footprints = board.GetFootprints()
buttons = []
for fp in footprints:
    ref = fp.GetReference()
    if ref.startswith("B") or ref.startswith("SOFT"):
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

if len(rows) == 8:
    for r_idx, row in enumerate(rows):
        target_y = int(row[0].GetPosition().y) # Keep same Y
        if len(row) == 6: # Rows 0, 1, 2
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
print("Set 70mm PCB Width, removed BOSS/BATTERY labels, updated button spacing, cleared tracks.")
