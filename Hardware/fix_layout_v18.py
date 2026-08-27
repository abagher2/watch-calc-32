import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

spacing = 11.5 # Standard spacing for upper matrix
C1 = 45.0 - 2.5 * spacing
C2 = 45.0 - 1.5 * spacing
C3 = 45.0 - 0.5 * spacing
C4 = 45.0 + 0.5 * spacing
C5 = 45.0 + 1.5 * spacing
C6 = 45.0 + 2.5 * spacing

columns_upper = [C1, C2, C3, C4, C5, C6]
columns_enter = [(C1+C2)/2.0, C3, C4, C5, C6]

total_dist = C6 - C1
# gap1 = 1.2 * base_gap
# gap2 = gap3 = gap4 = base_gap
# total = 4.2 * base_gap
base_gap = total_dist / 4.2
gap1 = 1.2 * base_gap

columns_lower = [
    C1,
    C1 + gap1,
    C1 + gap1 + base_gap,
    C1 + gap1 + 2 * base_gap,
    C6
]

footprints = board.GetFootprints()
buttons = []
for fp in footprints:
    ref = fp.GetReference()
    if ref.startswith("B") or ref.startswith("SOFT"):
        buttons.append(pcbnew.Cast_to_FOOTPRINT(fp))

# Sort by Y ascending (Top to Bottom)
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

print(f"Detected {len(rows)} rows.")

if len(rows) == 8:
    for r_idx, row in enumerate(rows):
        target_y = int(row[0].GetPosition().y) # Keep same Y
        if len(row) == 6:
            # Row 0 (Softkeys), Row 1, Row 2: Standard 6 columns
            for c_idx, b in enumerate(row):
                b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_upper[c_idx]), target_y))
        elif len(row) == 5:
            if r_idx == 3: 
                # Row 3: Enter row (Double wide first column, rest align to upper)
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_enter[c_idx]), target_y))
            else: 
                # Rows 4, 5, 6, 7: Lower matrix (5 columns, wider spacing)
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_lower[c_idx]), target_y))
else:
    print("ERROR: Did not detect exactly 8 rows!")

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Adjusted button spacing (standard upper, uniform lower matrix), cleared tracks.")
