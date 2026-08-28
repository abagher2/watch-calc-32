import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")

j1 = board.FindFootprintByReference("J1")
print("J1 Nets:")
for pad in j1.Pads():
    print(f"  Pad {pad.GetPadName()}: '{pad.GetNetname()}' (NetCode: {pad.GetNetCode()})")
