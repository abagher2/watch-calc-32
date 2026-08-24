import sys
import pcbnew

board = pcbnew.LoadBoard("output/pcbs/calculator.kicad_pcb")

for fp in board.GetFootprints():
    if fp.GetReference() == "JST1":
        for pad in fp.Pads():
            net = pad.GetNetname()
            pos = pad.GetPosition()
            print(f"JST1 Pad {pad.GetName()}: Net {net} at ({pos.x/1e6}, {pos.y/1e6})")
