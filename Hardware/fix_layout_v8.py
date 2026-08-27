import sys
import pcbnew
import subprocess

board = pcbnew.LoadBoard('calculator.kicad_pcb')
drawings = list(board.GetDrawings())
footprints = list(board.GetFootprints())

# --- 1. SHIFT LCD (J1) UP ---
j1 = pcbnew.Cast_to_FOOTPRINT(board.FindFootprintByReference('J1'))
if j1:
    pos = j1.GetPosition()
    new_y = pos.y - int(18.7 * 1e6)
    new_x = int(45.0 * 1e6)
    j1.SetPosition(pcbnew.VECTOR2I(new_x, new_y))

# --- 2. EXACT BUTTON MATRIX ---
y_rows = [
    -86.5, # Row 0 (Softkeys)
    -76.0, # Row 1 (Sx...)
    -65.5, # Row 2 (ST...)
    -55.0, # Row 3 (ENTER...)
    -44.5, # Row 4 (XQ...)
    -34.0, # Row 5 (f...)
    -23.5, # Row 6 (g...)
    -13.0, # Row 7 (C...)
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

# --- 3. FIX TEXT POSITIONS ---
for text in drawings:
    if isinstance(text, pcbnew.PCB_TEXT):
        txt = text.GetText()
        if "SHARP" in txt:
            pos = text.GetPosition()
            text.SetPosition(pcbnew.VECTOR2I(pos.x, pos.y - int(18.7*1e6)))
        if "StackCalc" in txt:
            text.SetPosition(pcbnew.VECTOR2I(int(45.0*1e6), int(-134.0*1e6)))

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Applied exact matrix positions and shifted LCD up!")
