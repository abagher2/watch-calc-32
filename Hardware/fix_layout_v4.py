import sys
import pcbnew
import wx
app = wx.App(False)

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# Dimensions
x_min = 10.0
x_max = 80.65
y_min = -158.15
y_max = -15.0
pcb_center_x = (x_min + x_max) / 2

# 1. PICO (MCU1): Up and to the left (under the left screwboss)
mcu = board.FindFootprintByReference('MCU1')
if mcu:
    # 90 degrees vertical
    mcu.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T))
    # Place on the left, below the top lip (-148.15)
    # Center Y = -128.0 means top is -145.5
    mcu.SetPosition(pcbnew.VECTOR2I(int(22.0*1e6), int(-128.0*1e6)))

# 2. JST (JST1): Rotated to route wires down, placed entirely under top edge
jst = board.FindFootprintByReference('JST1')
if jst:
    # Rotate to 180 degrees so wires point down/inwards
    jst.SetOrientation(pcbnew.EDA_ANGLE(180.0, pcbnew.DEGREES_T))
    # Place in the center, below the top lip
    jst.SetPosition(pcbnew.VECTOR2I(int(pcb_center_x*1e6), int(-140.0*1e6)))

# 3. Graphical Overlays (update to match new locations)
def add_line(board, layer, x1, y1, x2, y2, thickness=0.2):
    line = pcbnew.PCB_SHAPE(board)
    line.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    line.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    line.SetLayer(layer)
    line.SetWidth(int(thickness*1e6))
    board.Add(line)

def add_rect(board, layer, x1, y1, x2, y2, thickness=0.2):
    add_line(board, layer, x1, y1, x2, y1, thickness)
    add_line(board, layer, x2, y1, x2, y2, thickness)
    add_line(board, layer, x2, y2, x1, y2, thickness)
    add_line(board, layer, x1, y2, x1, y1, thickness)

def add_circle(board, layer, cx, cy, r, thickness=0.2):
    circle = pcbnew.PCB_SHAPE(board)
    circle.SetShape(pcbnew.SHAPE_T_CIRCLE)
    circle.SetCenter(pcbnew.VECTOR2I(int(cx*1e6), int(cy*1e6)))
    circle.SetEnd(pcbnew.VECTOR2I(int((cx+r)*1e6), int(cy*1e6)))
    circle.SetLayer(layer)
    circle.SetWidth(int(thickness*1e6))
    board.Add(circle)

# Clear old drawings on Dwgs.User
for d in list(board.GetDrawings()):
    if d.GetLayer() == pcbnew.Dwgs_User:
        board.Remove(d)

dwg = pcbnew.Dwgs_User
add_line(board, dwg, x_min, y_min + 10.0, x_max, y_min + 10.0, 0.4) # Top cap lip (-148.15)
add_rect(board, dwg, x_min, y_min, x_min + 11.0, y_min + 15.0, 0.4) # Left Boss (ends at -143.15)
add_rect(board, dwg, x_max - 11.0, y_min, x_max, y_min + 15.0, 0.4) # Right Boss (ends at -143.15)

# Battery bucket: on the right, below the screwboss. 
# Right boss X is 69.65 to 80.65. So center X around 62.0.
# Right boss Y ends at -143.15. So top of battery at -142.0.
# Radius 14.0 -> Center Y = -128.0
add_circle(board, dwg, 62.0, -128.0, 14.0, 0.4) 

# Save
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Layout and overlays updated successfully.")
