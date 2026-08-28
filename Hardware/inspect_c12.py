import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")
for fp in board.GetFootprints():
    if fp.GetReference() == "C12":
        print(f"Found {fp.GetReference()} at {fp.GetPosition().x/1e6}, {fp.GetPosition().y/1e6}")
        for pad in fp.Pads():
            net = pad.GetNetname()
            print(f"  Pad {pad.GetPadName()}: Net = {net}")
