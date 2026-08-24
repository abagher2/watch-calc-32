import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
fp = board.FindFootprintByReference("Disp")
print(f"Disp footprint layer: {fp.GetLayerName()}")
print(f"Number of pads: {len(fp.Pads())}")
for p in fp.Pads():
    print(f"Pad {p.GetNumber()}: Net={p.GetNetname()}, Shape={p.GetShape()}, LayerSet={p.GetLayerSet().LayerMaskToString()}")
