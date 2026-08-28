import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for fp in board.GetFootprints():
    if fp.GetReference() == "J1":
        print(f"J1 at {fp.GetPosition().x/1e6}, {fp.GetPosition().y/1e6}")
