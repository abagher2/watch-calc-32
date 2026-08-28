import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# The current board is from 9.45 to 80.55
# We want it to go from 9.0 to 81.0
# The edges are in F.Cuts / Edge.Cuts

for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.Edge_Cuts and isinstance(dwg, pcbnew.PCB_SHAPE):
        if dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
            start = dwg.GetStart()
            end = dwg.GetEnd()
            
            # Left edge is currently X = 9.45 (9450000 nm) or 9.5?
            # Wait, dump_edges said: "Line from 9.5, -138.0 to 9.5, 0.0"
            # It's at 9.5. Let's move it to 9.0
            if abs(start.x/1e6 - 9.5) < 0.1 and abs(end.x/1e6 - 9.5) < 0.1:
                start.x = int(9.0 * 1e6)
                end.x = int(9.0 * 1e6)
                dwg.SetStart(start)
                dwg.SetEnd(end)
            
            # Right edge is currently X = 80.5
            elif abs(start.x/1e6 - 80.5) < 0.1 and abs(end.x/1e6 - 80.5) < 0.1:
                start.x = int(81.0 * 1e6)
                end.x = int(81.0 * 1e6)
                dwg.SetStart(start)
                dwg.SetEnd(end)
                
            # Top edge is currently from 9.5 to 80.5 at Y = -138.0
            elif abs(start.y/1e6 + 138.0) < 0.1 and abs(end.y/1e6 + 138.0) < 0.1:
                if abs(start.x/1e6 - 9.5) < 0.1: start.x = int(9.0 * 1e6)
                if abs(end.x/1e6 - 9.5) < 0.1: end.x = int(9.0 * 1e6)
                if abs(start.x/1e6 - 80.5) < 0.1: start.x = int(81.0 * 1e6)
                if abs(end.x/1e6 - 80.5) < 0.1: end.x = int(81.0 * 1e6)
                dwg.SetStart(start)
                dwg.SetEnd(end)
                
            # Bottom edge is currently from 9.5 to 80.5 at Y = 0.0
            elif abs(start.y/1e6 - 0.0) < 0.1 and abs(end.y/1e6 - 0.0) < 0.1:
                if abs(start.x/1e6 - 9.5) < 0.1: start.x = int(9.0 * 1e6)
                if abs(end.x/1e6 - 9.5) < 0.1: end.x = int(9.0 * 1e6)
                if abs(start.x/1e6 - 80.5) < 0.1: start.x = int(81.0 * 1e6)
                if abs(end.x/1e6 - 80.5) < 0.1: end.x = int(81.0 * 1e6)
                dwg.SetStart(start)
                dwg.SetEnd(end)

pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
print("Widened PCB to 72.0mm successfully.")

