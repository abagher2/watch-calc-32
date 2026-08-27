import pcbnew
board = pcbnew.LoadBoard('calculator.kicad_pcb')
buttons = [fp for fp in board.GetFootprints() if fp.GetReference().startswith("B") or fp.GetReference().startswith("SOFT")]
buttons.sort(key=lambda b: b.GetPosition().y)
rows = []
cur = []
cur_y = buttons[0].GetPosition().y if buttons else 0
for b in buttons:
    if abs(b.GetPosition().y - cur_y) > 2*1e6:
        rows.append(cur)
        cur = []
        cur_y = b.GetPosition().y
    cur.append(b)
if cur: rows.append(cur)

print(f"Total buttons: {len(buttons)}")
print(f"Rows: {len(rows)}")
for i, r in enumerate(rows):
    print(f"Row {i}: {len(r)} buttons")
