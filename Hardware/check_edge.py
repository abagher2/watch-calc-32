import pcbnew
b = pcbnew.LoadBoard('calculator.kicad_pcb')
edges = [d for d in b.GetDrawings() if d.GetLayerName() == "Edge.Cuts"]
for e in edges:
    print(f"Edge: ({e.GetStart().x/1e6}, {e.GetStart().y/1e6}) -> ({e.GetEnd().x/1e6}, {e.GetEnd().y/1e6})")
