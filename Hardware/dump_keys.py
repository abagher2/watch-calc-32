import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
min_y = 0
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref.startswith("K"):
        y = fp.GetPosition().y / 1e6
        if y < min_y:
            min_y = y
print(f"Highest K key is at Y={min_y}")
