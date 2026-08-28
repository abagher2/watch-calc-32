import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

ys = []
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref.startswith("B") and len(ref) <= 3 and ref[1:].isdigit():
        ys.append(fp.GetPosition().y / 1e6)

if ys:
    print(f"Keys Y range: {min(ys)} to {max(ys)}")

