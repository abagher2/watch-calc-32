import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
layer = board.GetLayerID("User.Comments")
silk = board.GetLayerID("F.Silkscreen")

center_x = 45.0
center_y = -97.35

disp_w = 69.0
disp_h = 41.5

active_w = 56.73
active_h = 27.92

def draw_rect(layer_id, cx, cy, w, h, thickness=0.15):
    rect = pcbnew.PCB_SHAPE(board)
    rect.SetShape(pcbnew.SHAPE_T_RECT)
    rect.SetLayer(layer_id)
    rect.SetStart(pcbnew.VECTOR2I(int((cx - w/2) * 1e6), int((cy - h/2) * 1e6)))
    rect.SetEnd(pcbnew.VECTOR2I(int((cx + w/2) * 1e6), int((cy + h/2) * 1e6)))
    rect.SetWidth(int(thickness * 1e6))
    board.Add(rect)
    return rect

def add_text(layer_id, text_str, cx, cy):
    text = pcbnew.PCB_TEXT(board)
    text.SetText(text_str)
    text.SetPosition(pcbnew.VECTOR2I(int(cx * 1e6), int(cy * 1e6)))
    text.SetLayer(layer_id)
    text.SetTextSize(pcbnew.VECTOR2I(int(1.5 * 1e6), int(1.5 * 1e6)))
    text.SetTextThickness(int(0.15 * 1e6))
    board.Add(text)
    return text

# Draw Outer Glass
draw_rect(layer, center_x, center_y, disp_w, disp_h)
add_text(layer, "LCD Glass Boundary (69x41.5)", center_x, center_y - disp_h/2 - 1.5)

# Draw Active Area
draw_rect(layer, center_x, center_y, active_w, active_h)
add_text(layer, "Active Area", center_x, center_y)

# Also draw on silkscreen? User said "diagram for the outline of the LCD back"
# Usually silkscreen is good for physical outlines. We'll draw the outer glass on F.Silkscreen too.
draw_rect(silk, center_x, center_y, disp_w, disp_h)

pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
print("Added LCD outline diagrams.")
