import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Remove all existing Edge.Cuts
edges = [d for d in board.GetDrawings() if d.GetLayerName() == "Edge.Cuts"]
for dwg in edges:
    board.Remove(dwg)

# Remove all existing drawings on Cmts.User
cmts = [d for d in board.GetDrawings() if d.GetLayerName() == "Cmts.User"]
for dwg in cmts:
    board.Remove(dwg)

# The user wants a 2mm border around the 71.2mm display outline
# New PCB width = 71.2 + 4 = 75.2mm
# Centered at X = 45.0
# Left = 45.0 - 37.6 = 7.4
# Right = 45.0 + 37.6 = 82.6
# Height remains the same (Y: 0.0 to -138.0)

def draw_rect(layer, x1, y1, width, height, thickness=0.15):
    # Top
    l1 = pcbnew.PCB_SHAPE(board)
    l1.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l1.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1)))
    l1.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1)))
    l1.SetLayer(layer)
    l1.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l1)
    
    # Bottom
    l2 = pcbnew.PCB_SHAPE(board)
    l2.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l2.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1+height)))
    l2.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1+height)))
    l2.SetLayer(layer)
    l2.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l2)
    
    # Left
    l3 = pcbnew.PCB_SHAPE(board)
    l3.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l3.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1)))
    l3.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1), pcbnew.FromMM(y1+height)))
    l3.SetLayer(layer)
    l3.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l3)
    
    # Right
    l4 = pcbnew.PCB_SHAPE(board)
    l4.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l4.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1)))
    l4.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(x1+width), pcbnew.FromMM(y1+height)))
    l4.SetLayer(layer)
    l4.SetWidth(pcbnew.FromMM(thickness))
    board.Add(l4)

# Draw 75.2mm wide Edge.Cuts
draw_rect(pcbnew.Edge_Cuts, 7.4, -138.0, 75.2, 138.0, 0.1)

# Draw Guidelines on Cmts.User
# 1. LCD Active Area: 60.77 x 32.94, centered at X=45.0, Y=-110.5
active_w = 60.77
active_h = 32.94
draw_rect(pcbnew.Cmts_User, 45.0 - active_w/2, -110.5 - active_h/2, active_w, active_h, 0.2)

def add_text(txt, x, y, layer):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(txt)
    t.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(x), pcbnew.FromMM(y)))
    t.SetLayer(layer)
    t.SetTextSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.5), pcbnew.FromMM(1.5)))
    board.Add(t)

add_text("Active Area (60.77 x 32.94)", 45.0, -110.5, pcbnew.Cmts_User)

# 2. LCD Outline (already on F.SilkS, but let's mirror it on Cmts.User just in case)
# 71.2 x 43.3, centered at 45.0, -110.5
disp_w = 71.2
disp_h = 43.3
draw_rect(pcbnew.Cmts_User, 45.0 - disp_w/2, -110.5 - disp_h/2, disp_w, disp_h, 0.2)
add_text("Display Module Outline (71.2 x 43.3)", 45.0, -134, pcbnew.Cmts_User)

# 3. Chassis Inner Cavity Outline (76.6 width)
# Assuming 75.2mm PCB + 1.4mm clearance = 76.6mm cavity width
cavity_w = 76.6
draw_rect(pcbnew.Cmts_User, 45.0 - cavity_w/2, -140.0, cavity_w, 142.0, 0.2)
add_text("Chassis Inner Cavity (76.6 width)", 45.0, 2.0, pcbnew.Cmts_User)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Updated Edge.Cuts and drew guidelines on Cmts.User")
