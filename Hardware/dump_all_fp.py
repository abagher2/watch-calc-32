import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for fp in board.GetFootprints():
    print(f"{fp.GetReference()} at {fp.GetPosition().y/1e6}")
