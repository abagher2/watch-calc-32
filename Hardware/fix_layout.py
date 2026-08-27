import pcbnew
import wx
app = wx.App(False)

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# 1. Place MCU1 horizontally at the top
mcu = board.FindFootprintByReference('MCU1')
if mcu:
    mcu.SetOrientation(pcbnew.EDA_ANGLE(0.0, pcbnew.DEGREES_T))
    mcu.SetPosition(pcbnew.VECTOR2I(int(45.325*1e6), int(-147.0*1e6)))

# 2. Place JST1 to the right of MCU1
jst = board.FindFootprintByReference('JST1')
if jst:
    jst.SetOrientation(pcbnew.EDA_ANGLE(0.0, pcbnew.DEGREES_T))
    jst.SetPosition(pcbnew.VECTOR2I(int(70.0*1e6), int(-147.0*1e6)))

# 3. Place J1 (LCD Connector) right below MCU1
j1 = board.FindFootprintByReference('J1')
if j1:
    j1.SetOrientation(pcbnew.EDA_ANGLE(0.0, pcbnew.DEGREES_T))
    j1.SetPosition(pcbnew.VECTOR2I(int(45.325*1e6), int(-135.0*1e6)))

# 4. Scale buttons vertically to fit between -85 and -20
buttons = [fp for fp in board.GetFootprints() if fp.GetReference().startswith('B') or fp.GetReference().startswith('SOFT')]
if buttons:
    min_y = min(b.GetPosition().y/1e6 for b in buttons)
    max_y = max(b.GetPosition().y/1e6 for b in buttons)
    
    T = min_y
    B = max_y
    t = -85.0
    b = -20.0
    
    for fp in buttons:
        pos = fp.GetPosition()
        y = pos.y / 1e6
        if abs(B - T) > 0.1:
            new_y = t + (y - T) * (b - t) / (B - T)
        else:
            new_y = t
        pos.y = int(new_y * 1e6)
        fp.SetPosition(pos)

# 5. Fix LCD Silkscreen
# Remove existing lines and text for LCD
to_remove = []
for dwg in board.GetDrawings():
    if isinstance(dwg, pcbnew.PCB_SHAPE) and dwg.GetLayer() == pcbnew.F_SilkS:
        to_remove.append(dwg)
    if isinstance(dwg, pcbnew.PCB_TEXT) and dwg.GetLayer() == pcbnew.F_SilkS and 'LCD' in dwg.GetText():
        to_remove.append(dwg)

for item in to_remove:
    board.Remove(item)

# Add new LCD Silkscreen (62.8 x 42.8) below J1
lcd_x1 = 45.325 - 62.8/2
lcd_x2 = 45.325 + 62.8/2
lcd_y1 = -135.0
lcd_y2 = lcd_y1 + 42.8

def add_silk_line(x1, y1, x2, y2):
    seg = pcbnew.PCB_SHAPE(board)
    seg.SetShape(pcbnew.SHAPE_T_SEGMENT)
    seg.SetLayer(pcbnew.F_SilkS)
    seg.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    seg.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    seg.SetWidth(int(0.2*1e6))
    board.Add(seg)

add_silk_line(lcd_x1, lcd_y1, lcd_x2, lcd_y1)
add_silk_line(lcd_x2, lcd_y1, lcd_x2, lcd_y2)
add_silk_line(lcd_x2, lcd_y2, lcd_x1, lcd_y2)
add_silk_line(lcd_x1, lcd_y2, lcd_x1, lcd_y1)

text = pcbnew.PCB_TEXT(board)
text.SetText('LCD SCREEN')
text.SetPosition(pcbnew.VECTOR2I(int(45.325*1e6), int((lcd_y1 + 21.4)*1e6)))
text.SetLayer(pcbnew.F_SilkS)
text.SetTextSize(pcbnew.VECTOR2I(int(2*1e6), int(2*1e6)))
text.SetTextThickness(int(0.3*1e6))
board.Add(text)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print('Layout fixed and saved!')
