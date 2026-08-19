import sys
import pcbnew

def inject_logo(kicad_pcb_path):
    print(f"Loading {kicad_pcb_path} to inject logo...")
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    # 1. Find the exact position of Disp or MCU to place the logo above it
    ref_pos = None
    for fp in board.Footprints():
        if fp.GetReference() == "Disp":
            ref_pos = fp.GetPosition()
            break
            
    if not ref_pos:
        print("ERROR: Could not find Disp to reference position!")
        return
        
    start_x = ref_pos.x
    start_y = ref_pos.y - pcbnew.FromMM(8) # 8mm above the display
    
    # 2. Create the Text
    txt = pcbnew.PCB_TEXT(board)
    txt.SetText("WatchCalc 32")
    txt.SetPosition(pcbnew.VECTOR2I(start_x, start_y))
    txt.SetLayer(pcbnew.F_SilkS)
    txt.SetTextSize(pcbnew.VECTOR2I(pcbnew.FromMM(3), pcbnew.FromMM(3)))
    txt.SetTextThickness(pcbnew.FromMM(0.6))
    
    # Add text to board
    board.Add(txt)
    
    print(f"Saving updated board to {kicad_pcb_path}...")
    pcbnew.SaveBoard(kicad_pcb_path, board)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python inject_logo.py <source.kicad_pcb>")
        sys.exit(1)
    inject_logo(sys.argv[1])
