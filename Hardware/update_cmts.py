import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Remove all existing drawings on Cmts.User
to_remove = [d for d in board.GetDrawings() if d.GetLayerName() in ["Cmts.User", "User.Comments"]]
for dwg in to_remove:
    board.Remove(dwg)

def draw_rect(layer, x1, y1, width, height, thickness=0.2):
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

def add_text(txt, x, y, layer):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(txt)
    t.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(x), pcbnew.FromMM(y)))
    t.SetLayer(layer)
    t.SetTextSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.5), pcbnew.FromMM(1.5)))
    board.Add(t)

# 1. LCD Active Area: 56.73 x 27.92, centered at X=45.0, Y=-110.5
active_w = 56.73
active_h = 27.92
draw_rect(pcbnew.Cmts_User, 45.0 - active_w/2, -110.5 - active_h/2, active_w, active_h)
add_text("Active Area", 45.0, -110.5, pcbnew.Cmts_User)

# 2. LCD Outline
disp_w = 69.0
disp_h = 41.5
draw_rect(pcbnew.Cmts_User, 45.0 - disp_w/2, -110.5 - disp_h/2, disp_w, disp_h)
add_text("LCD Glass", 45.0, -134.0, pcbnew.Cmts_User)

# 3. Chassis Inner Cavity (71.6 width) -> Left = 45.0 - 35.8 = 9.2
cavity_w = 71.6
draw_rect(pcbnew.Cmts_User, 9.2, -141.2, cavity_w, 148.0)
add_text("Chassis Cavity", 45.0, 4.0, pcbnew.Cmts_User)

# 4. Top Cap Bosses
# Left Boss: centered at X=18.5, width=10, Y=-134.7 to -129.5
draw_rect(pcbnew.Cmts_User, 13.5, -134.7, 10.0, 5.2)
add_text("Boss L", 18.5, -132.5, pcbnew.Cmts_User)

# Right Boss: centered at X=71.5, width=10, Y=-134.7 to -129.5
draw_rect(pcbnew.Cmts_User, 66.5, -134.7, 10.0, 5.2)
add_text("Boss R", 71.5, -132.5, pcbnew.Cmts_User)

# 5. Battery Bucket
# Centered at X=45.0, width=24, Y=-136.2 to -129.4
draw_rect(pcbnew.Cmts_User, 33.0, -136.2, 24.0, 6.8)
add_text("CR2032 Bucket", 45.0, -132.5, pcbnew.Cmts_User)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Updated Cmts.User outlines for cavity, bosses, and battery bucket.")
