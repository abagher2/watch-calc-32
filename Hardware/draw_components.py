import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

def add_rect(board, x1, y1, x2, y2, layer=pcbnew.Dwgs_User, thickness=0.1):
    # Top
    l1 = pcbnew.PCB_SHAPE(board)
    l1.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l1.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    l1.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y1*1e6)))
    l1.SetLayer(layer)
    l1.SetWidth(int(thickness*1e6))
    board.Add(l1)
    
    # Bottom
    l2 = pcbnew.PCB_SHAPE(board)
    l2.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l2.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y2*1e6)))
    l2.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    l2.SetLayer(layer)
    l2.SetWidth(int(thickness*1e6))
    board.Add(l2)
    
    # Left
    l3 = pcbnew.PCB_SHAPE(board)
    l3.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l3.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    l3.SetEnd(pcbnew.VECTOR2I(int(x1*1e6), int(y2*1e6)))
    l3.SetLayer(layer)
    l3.SetWidth(int(thickness*1e6))
    board.Add(l3)
    
    # Right
    l4 = pcbnew.PCB_SHAPE(board)
    l4.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l4.SetStart(pcbnew.VECTOR2I(int(x2*1e6), int(y1*1e6)))
    l4.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    l4.SetLayer(layer)
    l4.SetWidth(int(thickness*1e6))
    board.Add(l4)

def add_front_text(board, text, x, y):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(text)
    t.SetPosition(pcbnew.VECTOR2I(int(x*1e6), int(y*1e6)))
    t.SetLayer(pcbnew.F_SilkS)
    t.SetTextThickness(int(0.15*1e6))
    t.SetTextSize(pcbnew.VECTOR2I(int(1.5*1e6), int(1.5*1e6)))
    board.Add(t)

def add_back_text(board, text, x, y):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(text)
    t.SetPosition(pcbnew.VECTOR2I(int(x*1e6), int(y*1e6)))
    t.SetLayer(pcbnew.B_SilkS)
    t.SetTextThickness(int(0.15*1e6))
    t.SetTextSize(pcbnew.VECTOR2I(int(1.5*1e6), int(1.5*1e6)))
    t.SetMirrored(True)
    board.Add(t)

# --- 1. LCD (Front) ---
add_rect(board, 13.3, -48.0, 76.7, -5.0, layer=pcbnew.F_SilkS, thickness=0.15)
add_front_text(board, "LCD Screen Area", 45.0, -26.5)

# --- 2. Battery Bucket (Back) ---
add_rect(board, 50.8, -13.9, 74.8, 0.0, layer=pcbnew.B_SilkS, thickness=0.15)
add_back_text(board, "BATTERY", 62.8, -6.95)

# --- 3. Screw Bosses (Back) ---
add_rect(board, 12.6, -10.95, 22.6, 0.0, layer=pcbnew.B_SilkS, thickness=0.15)
add_back_text(board, "BOSS", 17.6, -5.5)

add_rect(board, 70.6, -10.95, 80.6, 0.0, layer=pcbnew.B_SilkS, thickness=0.15)
add_back_text(board, "BOSS", 75.6, -5.5)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Added LCD, Battery, and Boss labels to PCB!")
