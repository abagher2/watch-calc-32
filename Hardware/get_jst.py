import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for fp in board.GetFootprints():
    if "JST1" in fp.GetReference():
        print(f"JST1 is at {fp.GetPosition()[0]/1000000.0}, {fp.GetPosition()[1]/1000000.0}")
