import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Note: We do NOT delete Edge.Cuts or Cmts.User here, because we already ran v16 to set the 71.0mm board width.
# We will just rewrite the button positions and clear tracks!

spacing = 11.5 # Standard spacing
C1 = 45.0 - 2.5 * spacing
C2 = 45.0 - 1.5 * spacing
C3 = 45.0 - 0.5 * spacing
C4 = 45.0 + 0.5 * spacing
C5 = 45.0 + 1.5 * spacing
C6 = 45.0 + 2.5 * spacing

columns_6 = [C1, C2, C3, C4, C5, C6]
columns_enter = [(C1+C2)/2.0, C3, C4, C5, C6]
columns_bottom = [C1, C3, C4, C5, C6]

spacing_top = 9.45
C1_t = 45.0 - 2.5 * spacing_top
C2_t = 45.0 - 1.5 * spacing_top
C3_t = 45.0 - 0.5 * spacing_top
C4_t = 45.0 + 0.5 * spacing_top
C5_t = 45.0 + 1.5 * spacing_top
C6_t = 45.0 + 2.5 * spacing_top
columns_6_top = [C1_t, C2_t, C3_t, C4_t, C5_t, C6_t]

footprints = board.GetFootprints()
buttons = []
for fp in footprints:
    ref = fp.GetReference()
    if ref.startswith("B") or ref.startswith("SOFT"):
        # Make sure it's actually a button by checking its value or just relying on the reference
        # The SOFT1..SOFT6 and B1..B37 are all the buttons we care about.
        buttons.append(pcbnew.Cast_to_FOOTPRINT(fp))

# Sort by Y ascending (Top to Bottom)
buttons.sort(key=lambda b: b.GetPosition().y)

rows = []
cur_row = []
cur_y = buttons[0].GetPosition().y if buttons else 0
for b in buttons:
    if abs(b.GetPosition().y - cur_y) > 2*1e6: # > 2mm difference
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
            if r_idx == 0:
                # Row 0: Softkeys (tight spacing)
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_6_top[c_idx]), target_y))
            else:
                # Row 1 and 2: Standard 6 columns
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_6[c_idx]), target_y))
        elif len(row) == 5:
            if r_idx == 3: 
                # Row 3: Enter row (Double wide first column)
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_enter[c_idx]), target_y))
            else: 
                # Rows 4, 5, 6, 7: Standard 5 columns
                for c_idx, b in enumerate(row):
                    b.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(columns_bottom[c_idx]), target_y))
else:
    print("ERROR: Did not detect exactly 8 rows!")

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Adjusted button spacing for all 8 rows, cleared tracks.")
