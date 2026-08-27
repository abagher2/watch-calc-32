import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
for m in b.GetFootprints():
    if "BT" in m.GetReference() or "Battery" in m.GetReference():
        print(f"{m.GetReference()} pos: {m.GetPosition().x/1e6}, {m.GetPosition().y/1e6}")
