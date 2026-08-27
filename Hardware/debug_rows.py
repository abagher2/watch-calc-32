import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")
footprints = board.GetFootprints()
buttons = []
for fp in footprints:
    val = fp.GetValue()
    if "Tactile" in val:
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

for r_idx, row in enumerate(rows):
    y = row[0].GetPosition().y / 1e6
    print(f"Row {r_idx}: Y={y}, {len(row)} buttons")
    for b in row:
        x = b.GetPosition().x / 1e6
        ref = b.GetReference()
        print(f"  {ref} at X={x}")
