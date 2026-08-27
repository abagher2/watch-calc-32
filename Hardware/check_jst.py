import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
for m in b.GetFootprints():
    if m.GetReference() == "J1":
        print(f"J1 pos: {m.GetPosition().x/1e6}, {m.GetPosition().y/1e6}")
