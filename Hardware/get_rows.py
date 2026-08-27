import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
footprints = b.GetFootprints()
buttons = []
for fp in footprints:
    ref = fp.GetReference()
    if ref.startswith("B") or ref.startswith("SOFT"):
        buttons.append(fp)
buttons.sort(key=lambda b: b.GetPosition().y)
cur_y = buttons[0].GetPosition().y if buttons else 0
rows = []
cur_row = []
for b in buttons:
    if abs(b.GetPosition().y - cur_y) > 2*1e6:
        rows.append(cur_row)
        cur_row = []
        cur_y = b.GetPosition().y
    cur_row.append(b)
if cur_row: rows.append(cur_row)
for i, r in enumerate(rows):
    print(f"Row {i}: {len(r)} keys (Y={r[0].GetPosition().y/1e6})")
