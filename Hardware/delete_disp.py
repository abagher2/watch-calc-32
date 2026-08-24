import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# Remove E-Ink Display
disp = board.FindFootprintByReference("Disp")
if disp:
    board.Remove(disp)
    print("Deleted old E-Ink Disp footprint.")
    
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
