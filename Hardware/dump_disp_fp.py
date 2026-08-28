import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if "Disp" in ref or "OLED" in ref or ref == "J1":
        print(f"Found {ref} at {fp.GetPosition().x/1e6}, {fp.GetPosition().y/1e6}")
