import sys
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
drawings = list(board.GetDrawings())
footprints = list(board.GetFootprints())

# --- 1. SET EXACT POSITIONS ---
# J1 (LCD Connector)
j1 = pcbnew.Cast_to_FOOTPRINT(board.FindFootprintByReference('J1'))
if j1:
    j1.SetPosition(pcbnew.VECTOR2I(int(45.0 * 1e6), int(-110.5 * 1e6)))

# MCU1
mcu = pcbnew.Cast_to_FOOTPRINT(board.FindFootprintByReference('MCU1'))
if mcu:
    mcu.SetPosition(pcbnew.VECTOR2I(int(23.0 * 1e6), int(-110.5 * 1e6)))

# JST1
jst = pcbnew.Cast_to_FOOTPRINT(board.FindFootprintByReference('JST1'))
if jst:
    jst.SetPosition(pcbnew.VECTOR2I(int(36.0 * 1e6), int(-110.5 * 1e6)))

# --- 2. EXACT BUTTON MATRIX ---
# Y spacing: 10mm from -82.0 to -12.0
y_rows = [
    -82.0, # Row 0 (Softkeys)
    -72.0, # Row 1
    -62.0, # Row 2
    -52.0, # Row 3
    -42.0, # Row 4
    -32.0, # Row 5
    -22.0, # Row 6
    -12.0, # Row 7
]

buttons = []
for fp in footprints:
    ref = fp.GetReference()
    if ref.startswith("B") or ref.startswith("SOFT"):
        buttons.append(pcbnew.Cast_to_FOOTPRINT(fp))

buttons.sort(key=lambda b: b.GetPosition().y)

rows = []
cur_row = []
cur_y = buttons[0].GetPosition().y if buttons else 0
for b in buttons:
    if abs(b.GetPosition().y - cur_y) > 2*1e6:
        cur_row.sort(key=lambda x: x.GetPosition().x)
        rows.append(cur_row)
        cur_row = []
        cur_y = b.GetPosition().y
    cur_row.append(b)
if cur_row:
    cur_row.sort(key=lambda x: x.GetPosition().x)
    rows.append(cur_row)

if len(rows) == 8:
    for r_idx, row in enumerate(rows):
        target_y = int(y_rows[r_idx] * 1e6)
        num_btns = len(row)
        
        if num_btns == 6:
            start_x = 45.0 - (2.5 * 10.4)
            spacing = 10.4
        elif num_btns == 5 and r_idx == 3:
            start_x = 45.0 - (2.0 * 12.4)
            spacing = 12.4
        elif num_btns == 5:
            start_x = 45.0 - (2.0 * 12.4)
            spacing = 12.4
        else:
            start_x = 45.0 - ((num_btns-1)/2.0 * 12.4)
            spacing = 12.4

        for c_idx, b in enumerate(row):
            target_x = int((start_x + c_idx * spacing) * 1e6)
            b.SetPosition(pcbnew.VECTOR2I(target_x, target_y))

# --- 3. FIX TEXT POSITIONS & CLEAN SILKSCREEN ---
for d in drawings:
    if d.GetLayer() in [pcbnew.F_SilkS, pcbnew.B_SilkS, pcbnew.Dwgs_User]:
        if isinstance(d, pcbnew.PCB_SHAPE) or (isinstance(d, pcbnew.PCB_TEXT) and d.GetText() in ["LCD Screen Area", "BATTERY", "BOSS", "CR2032 BATTERY", "JST"]):
            board.Remove(d)

    if isinstance(d, pcbnew.PCB_TEXT):
        txt = d.GetText()
        if "SHARP" in txt or "LS027B7DH01" in txt:
            # Move inside the LCD rectangle
            d.SetPosition(pcbnew.VECTOR2I(int(45.0*1e6), int(-100.0*1e6)))
            d.SetTextSize(pcbnew.VECTOR2I(int(1.2*1e6), int(1.2*1e6)))
            d.SetTextThickness(int(0.15*1e6))
        if "StackCalc" in txt:
            d.SetPosition(pcbnew.VECTOR2I(int(45.0*1e6), int(-134.5*1e6)))
        if "Calc32" in txt or "Calc 32" in txt:
            d.SetPosition(pcbnew.VECTOR2I(int(45.0*1e6), int(-135.5*1e6)))

def add_rect(board, x1, y1, x2, y2, layer, thickness=0.15):
    l1 = pcbnew.PCB_SHAPE(board)
    l1.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l1.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    l1.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y1*1e6)))
    l1.SetLayer(layer)
    l1.SetWidth(int(thickness*1e6))
    board.Add(l1)
    
    l2 = pcbnew.PCB_SHAPE(board)
    l2.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l2.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y2*1e6)))
    l2.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    l2.SetLayer(layer)
    l2.SetWidth(int(thickness*1e6))
    board.Add(l2)
    
    l3 = pcbnew.PCB_SHAPE(board)
    l3.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l3.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
    l3.SetEnd(pcbnew.VECTOR2I(int(x1*1e6), int(y2*1e6)))
    l3.SetLayer(layer)
    l3.SetWidth(int(thickness*1e6))
    board.Add(l3)
    
    l4 = pcbnew.PCB_SHAPE(board)
    l4.SetShape(pcbnew.SHAPE_T_SEGMENT)
    l4.SetStart(pcbnew.VECTOR2I(int(x2*1e6), int(y1*1e6)))
    l4.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
    l4.SetLayer(layer)
    l4.SetWidth(int(thickness*1e6))
    board.Add(l4)

def add_text(board, text, x, y, layer, mirrored=False):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(text)
    t.SetPosition(pcbnew.VECTOR2I(int(x*1e6), int(y*1e6)))
    t.SetLayer(layer)
    t.SetTextThickness(int(0.15*1e6))
    t.SetTextSize(pcbnew.VECTOR2I(int(1.2*1e6), int(1.2*1e6)))
    if mirrored: t.SetMirrored(True)
    board.Add(t)

# LCD Area: Top=132.0, Bottom=89.0
lcd_y_min = -132.0
lcd_y_max = -89.0
add_rect(board, 13.3, lcd_y_min, 76.7, lcd_y_max, pcbnew.F_SilkS)
add_text(board, "LCD Screen Area", 45.0, -110.5, pcbnew.F_SilkS)

# Battery Area
add_rect(board, 50.8, -23.9, 74.8, -5.4, pcbnew.B_SilkS)
add_text(board, "CR2032 BATTERY", 62.8, -14.65, pcbnew.B_SilkS, mirrored=True)

# Bosses
add_rect(board, 12.6, -10.95, 22.6, 0.0, pcbnew.B_SilkS)
add_text(board, "BOSS", 17.6, -5.5, pcbnew.B_SilkS, mirrored=True)

add_rect(board, 70.6, -10.95, 80.6, 0.0, pcbnew.B_SilkS)
add_text(board, "BOSS", 75.6, -5.5, pcbnew.B_SilkS, mirrored=True)

# JST label
add_text(board, "JST", 36.0, -105.0, pcbnew.B_SilkS, mirrored=True)

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Applied perfectly aligned layout!")
