import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
fp = board.FindFootprintByReference("J1")
if fp:
    print(f"J1 found! Pads: {len(fp.Pads())}")
else:
    print("J1 not found!")
