import sys
import pcbnew
import math

def generate_faceplate(source_pcb, output_pcb):
    print(f"Loading {source_pcb}...")
    src_board = pcbnew.LoadBoard(source_pcb)
    
    # Create new empty board
    faceplate = pcbnew.BOARD()
    
    # Copy Edge.Cuts (Board outline and mounting holes)
    for drawing in src_board.GetDrawings():
        if drawing.GetLayer() == pcbnew.Edge_Cuts:
            # We must duplicate the object to add it to a new board
            clone = drawing.Duplicate()
            faceplate.Add(clone)
            
    # Iterate through footprints to create cutouts
    for fp in src_board.Footprints():
        ref = fp.GetReference()
        pos = fp.GetPosition()
        
        if ref.startswith("B"):
            # Button: Create a 10x10mm square cutout
            shape = pcbnew.PCB_SHAPE(faceplate)
            shape.SetShape(pcbnew.SHAPE_T_RECT)
            shape.SetLayer(pcbnew.Edge_Cuts)
            half_size = pcbnew.FromMM(5)
            
            shape.SetStart(pcbnew.VECTOR2I(pos.x - half_size, pos.y - half_size))
            shape.SetEnd(pcbnew.VECTOR2I(pos.x + half_size, pos.y + half_size))
            shape.SetWidth(pcbnew.FromMM(0.1))
            faceplate.Add(shape)
            
        elif ref == "OLED1":
            # Screen: Create a 27x27mm cutout
            shape = pcbnew.PCB_SHAPE(faceplate)
            shape.SetShape(pcbnew.SHAPE_T_RECT)
            shape.SetLayer(pcbnew.Edge_Cuts)
            
            # Absolute coordinates mapped from the F.SilkS indicator
            shape.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(35.5), pcbnew.FromMM(-139.5)))
            shape.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(62.5), pcbnew.FromMM(-112.5)))
            shape.SetWidth(pcbnew.FromMM(0.1))
            faceplate.Add(shape)
                    
    print(f"Saving faceplate to {output_pcb}...")
    pcbnew.SaveBoard(output_pcb, faceplate)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_faceplate.py <source.kicad_pcb> <output.kicad_pcb>")
        sys.exit(1)
    generate_faceplate(sys.argv[1], sys.argv[2])
