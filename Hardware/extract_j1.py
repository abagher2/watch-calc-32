import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
j1 = board.FindFootprintByReference("J1")
if j1:
    print(f"J1 Position: {j1.GetPosition().x / 1e6}, {j1.GetPosition().y / 1e6}")
    print(f"Layer: {j1.GetLayerName()}")
    for pad in j1.Pads():
        print(f"Pad {pad.GetNumber()}: Pos=({pad.GetPosition().x/1e6}, {pad.GetPosition().y/1e6}), Size=({pad.GetSize().x/1e6}, {pad.GetSize().y/1e6}), Shape={pad.GetShape()}")
