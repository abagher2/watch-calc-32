import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
for m in b.GetFootprints():
    if "Pico" in m.GetReference() or m.GetReference() == "MCU1":
        print(f"Pico pos: {m.GetPosition().x/1e6}, {m.GetPosition().y/1e6}")
        bbox = m.GetBoundingBox()
        print(f"Pico bbox: Y from {bbox.GetY()/1e6} to {bbox.GetBottom()/1e6}")
