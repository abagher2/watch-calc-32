import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
for m in b.GetFootprints():
    if m.GetReference().startswith("J"):
        print(f"{m.GetReference()} pos: {m.GetPosition().x/1e6}, {m.GetPosition().y/1e6}")
