import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# Find J1
j1 = board.FindFootprintByReference("J1")
if j1:
    nets = ["P21", "P20", "P19", "P18", "P11", "VCC", "VCC", "GND", "GND", "GND"]
    for p in j1.Pads():
        idx = int(p.GetNumber()) - 1
        if 0 <= idx < len(nets):
            net = board.FindNet(nets[idx])
            if net:
                p.SetNetCode(net.GetNetCode())
                
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
