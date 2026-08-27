import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")
for fp in board.GetFootprints():
    ref = fp.GetReference()
    val = fp.GetValue()
    if ref.startswith("B") or ref.startswith("SOFT") or ref.startswith("C") or ref.startswith("R"):
        continue
    print(f"Ref: {ref}, Val: {val}")
