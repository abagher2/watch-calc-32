import sys
import pcbnew
import wx
import math
app = wx.App(False)

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# 1. NEW BOARD EDGES
x_min = 14.7
x_max = 75.4
y_min = -137.0
y_max = -17.0
pcb_center_x = (x_min + x_max) / 2

# Remove old Edge.Cuts
for d in list(board.GetDrawings()):
    if d.GetLayer() == pcbnew.Edge_Cuts:
        board.Remove(d)

def add_edge_line(board, x1, y1, x2, y2):
    line = pcbnew.PCB_SHAPE(board)
    line.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    line.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    line.SetLayer(pcbnew.Edge_Cuts)
    line.SetWidth(int(0.1*1e6))
    board.Add(line)

# Connect lines as a simple rectangle
add_edge_line(board, x_min, y_min, x_max, y_min) # Top
add_edge_line(board, x_max, y_min, x_max, y_max) # Right
add_edge_line(board, x_max, y_max, x_min, y_max) # Bottom
add_edge_line(board, x_min, y_max, x_min, y_min) # Left

# 2. RELOCATE COMPONENTS
mcu_obj = board.FindFootprintByReference('MCU1')
if mcu_obj:
    mcu = pcbnew.Cast_to_FOOTPRINT(mcu_obj)
    mcu.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T)) # Vertical
    mcu.SetPosition(pcbnew.VECTOR2I(int(24.7*1e6), int(-110.5*1e6)))

jst_obj = board.FindFootprintByReference('JST1')
if jst_obj:
    jst = pcbnew.Cast_to_FOOTPRINT(jst_obj)
    jst.SetOrientation(pcbnew.EDA_ANGLE(180.0, pcbnew.DEGREES_T)) # Down
    jst.SetPosition(pcbnew.VECTOR2I(int(45.05*1e6), int(-128.0*1e6)))

# Move (Pico Module) text
for text in board.GetDrawings():
    if isinstance(text, pcbnew.PCB_TEXT):
        if "Pico" in text.GetText() or "PICO" in text.GetText():
            text.SetPosition(pcbnew.VECTOR2I(int(24.7*1e6), int(-110.5*1e6)))


# Clear old drawings on Dwgs.User (we will redraw them)
for d in list(board.GetDrawings()):
    if d.GetLayer() == pcbnew.Dwgs_User:
        board.Remove(d)

def add_line(board, layer, x1, y1, x2, y2, thickness=0.2):
    line = pcbnew.PCB_SHAPE(board)
    line.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    line.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    line.SetLayer(layer)
    line.SetWidth(int(thickness*1e6))
    board.Add(line)

def add_circle(board, layer, cx, cy, r, thickness=0.2):
    circle = pcbnew.PCB_SHAPE(board)
    circle.SetShape(pcbnew.SHAPE_T_CIRCLE)
    circle.SetCenter(pcbnew.VECTOR2I(int(cx*1e6), int(cy*1e6)))
    circle.SetEnd(pcbnew.VECTOR2I(int((cx+r)*1e6), int(cy*1e6)))
    circle.SetLayer(layer)
    circle.SetWidth(int(thickness*1e6))
    board.Add(circle)

# Dwgs.User
dwg = pcbnew.Dwgs_User
add_circle(board, dwg, 60.4, -110.5, 14.0, 0.4) # Battery bucket overlay

# Save
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("DM32 style layout reduction applied.")
