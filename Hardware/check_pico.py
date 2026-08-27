import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref == "MCU1":
        bb = fp.GetBoundingBox()
        print(f"Pico footprint: {ref}, value: {fp.GetValue()}")
        print(f"  Center: {fp.GetPosition().x/1e6}, {fp.GetPosition().y/1e6}")
        print(f"  Box: X={bb.GetX()/1e6} to {bb.GetRight()/1e6}, Y={bb.GetY()/1e6} to {bb.GetBottom()/1e6}")

for t in board.GetDrawings():
    if t.GetLayerName() == "F.SilkS":
        if isinstance(t, pcbnew.PCB_TEXT):
            if "ERC" in t.GetText() or "StackCalc" in t.GetText():
                print(f"Silkscreen text: {t.GetText()} at {t.GetPosition().x/1e6}, {t.GetPosition().y/1e6}")
