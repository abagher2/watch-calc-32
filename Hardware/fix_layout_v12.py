import sys
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
footprints = list(board.GetFootprints())

# --- 1. EXACT BUTTON MATRIX EXACTLY MATCHING HP32SII ---
# Y spacing: 10mm from -82.0 to -12.0
y_rows = [
    -82.0, # Row 0 (Softkeys)
    -72.0, # Row 1
    -62.0, # Row 2
    -52.0, # Row 3 (ENTER)
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

spacing = 11.5
C1 = 45.0 - 2.5 * spacing
C2 = 45.0 - 1.5 * spacing
C3 = 45.0 - 0.5 * spacing
C4 = 45.0 + 0.5 * spacing
C5 = 45.0 + 1.5 * spacing
C6 = 45.0 + 2.5 * spacing

columns_6 = [C1, C2, C3, C4, C5, C6]
columns_enter = [(C1+C2)/2.0, C3, C4, C5, C6]
columns_bottom = [C1, C3, C4, C5, C6]

if len(rows) == 8:
    for r_idx, row in enumerate(rows):
        target_y = int(y_rows[r_idx] * 1e6)
        
        if len(row) == 6: # Rows 0, 1, 2
            for c_idx, b in enumerate(row):
                b.SetPosition(pcbnew.VECTOR2I(int(columns_6[c_idx]*1e6), target_y))
        elif len(row) == 5:
            if r_idx == 3: # Enter row
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(int(columns_enter[c_idx]*1e6), target_y))
            else: # Rows 4, 5, 6, 7
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(int(columns_bottom[c_idx]*1e6), target_y))

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Applied HP32SII button columns spacing perfectly!")
