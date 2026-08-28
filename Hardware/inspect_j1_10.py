import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Find if J1 Pad 10 connects to anything besides C12
j1 = board.FindFootprintByReference("J1")
pad10 = j1.FindPadByNumber("10")
print(f"J1 Pad 10 Net: {pad10.GetNetname()}")

# Find all pads on this net
net_code = pad10.GetNetCode()
connected = []
for fp in board.GetFootprints():
    for pad in fp.Pads():
        if pad.GetNetCode() == net_code:
            connected.append(f"{fp.GetReference()} Pad {pad.GetPadName()}")
print("Connected to:", ", ".join(connected))

