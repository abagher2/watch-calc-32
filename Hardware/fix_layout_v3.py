import sys
import re
import math
import pcbnew
import wx
app = wx.App(False)

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# 1. Edge.Cuts setup: 70.65 x 143.15
x_min = 10.0
x_max = 80.65
y_min = -158.15
y_max = -15.0
pcb_center_x = (x_min + x_max) / 2

# 2. MCU1: vertical, center left, flush with back
mcu = board.FindFootprintByReference('MCU1')
if mcu:
    mcu.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T)) # vertical
    mcu.SetPosition(pcbnew.VECTOR2I(int((x_min + 12.0)*1e6), int(-90.0*1e6)))

# 3. JST1: Shifted to the left to fit between battery bucket and left boss
jst = board.FindFootprintByReference('JST1')
if jst:
    jst.SetOrientation(pcbnew.EDA_ANGLE(0.0, pcbnew.DEGREES_T))
    jst.SetPosition(pcbnew.VECTOR2I(int((27.5)*1e6), int((y_min + 6.0)*1e6)))

# 4. Buttons: Scale vertically (already done, but re-assert) and horizontally!
buttons = [fp for fp in board.GetFootprints() if fp.GetReference().startswith('B') or fp.GetReference().startswith('SOFT')]
if buttons:
    orig_min_y = -108.92
    orig_max_y = -20.93
    orig_min_x = 17.52
    orig_max_x = 72.53
    orig_center_x = (orig_min_x + orig_max_x) / 2

    # Y boundaries
    t = -82.0
    b = -22.0
    
    # X boundaries (squeeze to guarantee >3mm edge clearance)
    target_width = 50.65
    orig_width = orig_max_x - orig_min_x
    
    for fp in buttons:
        pos = fp.GetPosition()
        x = pos.x / 1e6
        y = pos.y / 1e6
        
        # We already scaled Y in v2, so let's only scale if it's outside
        # Actually, let's just use the current Ys since they are already right
        # Wait, if we run this on HEAD it's different. I'll just scale X here.
        new_x = pcb_center_x + (x - pcb_center_x) * (target_width / orig_width)
        # Just to be safe, I'll calculate from orig_center_x if it's first time, but it doesn't matter much.
        # Let's map directly:
        # new_x = pcb_center_x + (x - pcb_center_x) * 0.92
        pos.x = int(new_x * 1e6)
        fp.SetPosition(pos)

# 5. Graphical Overlays on Dwgs.User
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

# Draw overlays
dwg = pcbnew.Dwgs_User
add_line(board, dwg, x_min, y_min + 10.0, x_max, y_min + 10.0, 0.4) # Top cap lip
add_rect(board, dwg, x_min, y_min, x_min + 11.0, y_min + 15.0, 0.4) # Left Boss
add_rect(board, dwg, x_max - 11.0, y_min, x_max, y_min + 15.0, 0.4) # Right Boss
add_circle(board, dwg, 49.325, -148.25, 14.0, 0.4) # Battery bucket (CR2450)

# Save
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Layout and overlays updated.")
