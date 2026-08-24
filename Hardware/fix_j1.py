import pcbnew
import sys
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# Find J1
for fp in board.GetFootprints():
    if fp.GetReference() == "J1":
        print("Found J1. Assigning nets to pads...")
        for pad in fp.Pads():
            if pad.GetNetCode() <= 0:
                print(f"Pad {pad.GetNumber()} has no net. Assigning to GND temporarily.")
                gnd = board.FindNet("GND")
                if gnd:
                    pad.SetNetCode(gnd.GetNetCode())
                    
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
