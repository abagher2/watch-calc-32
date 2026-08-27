import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Remove previous BOSS and BATTERY labels
to_remove = []
for dwg in board.GetDrawings():
    if isinstance(dwg, pcbnew.PCB_TEXT):
        txt = dwg.GetText()
        if "BOSS" in txt or "BATTERY" in txt:
            to_remove.append(dwg)

for item in to_remove:
    board.Remove(item)

def add_text(board, text, x, y, layer, size=1.5, thickness=0.25, mirrored=False):
    txt = pcbnew.PCB_TEXT(board)
    txt.SetText(text)
    txt.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(x), pcbnew.FromMM(y)))
    txt.SetLayer(layer)
    txt.SetTextSize(pcbnew.VECTOR2I(pcbnew.FromMM(size), pcbnew.FromMM(size)))
    txt.SetTextThickness(pcbnew.FromMM(thickness))
    if mirrored:
        txt.SetMirrored(True)
    board.Add(txt)

def draw_rect(board, x1, y1, x2, y2, layer, thickness=0.3):
    pts = [
        (x1, y1),
        (x2, y1),
        (x2, y2),
        (x1, y2),
        (x1, y1)
    ]
    for i in range(len(pts)-1):
        line = pcbnew.PCB_SHAPE(board)
        line.SetShape(pcbnew.SHAPE_T_SEGMENT)
        line.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(pts[i][0]), pcbnew.FromMM(pts[i][1])))
        line.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(pts[i+1][0]), pcbnew.FromMM(pts[i+1][1])))
        line.SetLayer(layer)
        line.SetWidth(pcbnew.FromMM(thickness))
        board.Add(line)

# Add Boss Labels at the TOP
add_text(board, "BOSS", 11.0, -138.0, pcbnew.B_SilkS, mirrored=True)
add_text(board, "BOSS", 83.0, -138.0, pcbnew.B_SilkS, mirrored=True)

# Add Battery Label at the TOP (Battery bucket is Y from -119.5 to -145.5, X from 43 to 67)
add_text(board, "CR2032 BATTERY", 55.0, -132.0, pcbnew.B_SilkS, mirrored=True)

# Let's draw boxes on Cmts.User layer to show the mechanical clearance
# Left Boss Box
draw_rect(board, 4.0, -134.45, 14.0, -148.0, pcbnew.Cmts_User)
# Right Boss Box
draw_rect(board, 80.0, -134.45, 90.0, -148.0, pcbnew.Cmts_User)
# Battery Box
draw_rect(board, 43.0, -119.5, 67.0, -145.5, pcbnew.Cmts_User)
# Pico Box
draw_rect(board, 12.5, -91.1, 33.5, -125.8, pcbnew.Cmts_User)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Updated silkscreen labels and drew mechanical clearances!")
