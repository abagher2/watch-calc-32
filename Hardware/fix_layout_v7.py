import sys
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
drawings = list(board.GetDrawings())
footprints = list(board.GetFootprints())

# 1. NEW BOARD EDGES (Expanded HP32SII Target)
x_min = 9.0
x_max = 81.0
y_min = -137.0
y_max = 0.0

# Remove old Edge.Cuts
for d in drawings:
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

# 2. SCALE BUTTON MATRIX
# Current centers:
center_x = 45.048777
center_y = -52.000000

# Scale factors:
scale_x = 1.2243
scale_y = 1.2833

for fp in footprints:
    ref = fp.GetReference()
    if ref.startswith("B") or ref.startswith("SOFT"):
        pos = fp.GetPosition()
        cur_x = pos.x / 1e6
        cur_y = pos.y / 1e6
        
        # Apply scaling from center
        new_x = center_x + (cur_x - center_x) * scale_x
        new_y = center_y + (cur_y - center_y) * scale_y
        
        fp.SetPosition(pcbnew.VECTOR2I(int(new_x * 1e6), int(new_y * 1e6)))

# 3. RELOCATE BATTERY & OTHER BACK COMPONENTS
# We spread them out a bit to match the wider board
mcu = pcbnew.Cast_to_FOOTPRINT(board.FindFootprintByReference('MCU1'))
if mcu:
    mcu.SetPosition(pcbnew.VECTOR2I(int(23.0*1e6), int(-110.5*1e6)))

jst = pcbnew.Cast_to_FOOTPRINT(board.FindFootprintByReference('JST1'))
if jst:
    jst.SetPosition(pcbnew.VECTOR2I(int(45.05*1e6), int(-128.0*1e6)))

# Battery center (Y moved higher to -123.0 for shorter Top Cap tongue)
batt_x = 62.0
batt_y = -123.0

# Clear old drawings on Dwgs.User (we will redraw them)
for d in drawings:
    if d.GetLayer() == pcbnew.Dwgs_User:
        board.Remove(d)

def add_circle(board, layer, cx, cy, r, thickness=0.2):
    circle = pcbnew.PCB_SHAPE(board)
    circle.SetShape(pcbnew.SHAPE_T_CIRCLE)
    circle.SetCenter(pcbnew.VECTOR2I(int(cx*1e6), int(cy*1e6)))
    circle.SetEnd(pcbnew.VECTOR2I(int((cx+r)*1e6), int(cy*1e6)))
    circle.SetLayer(layer)
    circle.SetWidth(int(thickness*1e6))
    board.Add(circle)

# Dwgs.User Battery Overlay
dwg = pcbnew.Dwgs_User
add_circle(board, dwg, batt_x, batt_y, 12.0, 0.4) # Battery bucket overlay

# Move (Pico Module) text
for text in drawings:
    if isinstance(text, pcbnew.PCB_TEXT):
        if "Pico" in text.GetText() or "PICO" in text.GetText():
            text.SetPosition(pcbnew.VECTOR2I(int(23.0*1e6), int(-110.5*1e6)))

# Save
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Maximized HP32SII layout applied.")
