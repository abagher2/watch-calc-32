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

# Move (Pico Module) text
for text in board.GetDrawings():
    if isinstance(text, pcbnew.PCB_TEXT):
        if "Pico" in text.GetText() or "PICO" in text.GetText():
            text.SetPosition(pcbnew.VECTOR2I(int(22.0*1e6), int(-148.0*1e6)))
            
        # Delete old LCD SCREEN text if any
        if "LCD SCREEN" in text.GetText():
            board.Remove(text)

# Add Sharp LCD Shape to F.SilkS
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

# LCD dimensions: 63.0 x 42.82
# Connector J1 is at Y=-130.0. Let's assume glass top is at -135.0.
lcd_top = -135.0
lcd_bot = -135.0 + 42.82
lcd_left = pcb_center_x - (63.0 / 2)
lcd_right = pcb_center_x + (63.0 / 2)
add_rect(board, pcbnew.F_SilkS, lcd_left, lcd_top, lcd_right, lcd_bot, 0.3)

lcd_text = pcbnew.PCB_TEXT(board)
lcd_text.SetText("SHARP LS027B7DH01")
lcd_text.SetPosition(pcbnew.VECTOR2I(int(pcb_center_x*1e6), int((lcd_top + 10.0)*1e6)))
lcd_text.SetLayer(pcbnew.F_SilkS)
lcd_text.SetTextSize(pcbnew.VECTOR2I(int(2.0*1e6), int(2.0*1e6)))
lcd_text.SetTextThickness(int(0.4*1e6))
board.Add(lcd_text)

# Clear old drawings on Dwgs.User (we will redraw them)
for d in list(board.GetDrawings()):
    if d.GetLayer() == pcbnew.Dwgs_User:
        board.Remove(d)

dwg = pcbnew.Dwgs_User
add_line(board, dwg, x_min, y_min + 10.0, x_max, y_min + 10.0, 0.4) # Top cap lip (-148.15)
add_rect(board, dwg, x_min, y_min, x_min + 11.0, y_min + 15.0, 0.4) # Left Boss
add_rect(board, dwg, x_max - 11.0, y_min, x_max, y_min + 15.0, 0.4) # Right Boss

# Battery bucket: moved to X=65.0 to give JST more room
add_circle(board, dwg, 65.0, -128.0, 14.0, 0.4) 

# Save
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Layout and overlays updated successfully.")
