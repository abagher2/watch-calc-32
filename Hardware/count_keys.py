import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
switches = [m for m in b.GetFootprints() if m.GetReference().startswith("B") or m.GetReference().startswith("SOFT")]
print(f"Total keys: {len(switches)}")
