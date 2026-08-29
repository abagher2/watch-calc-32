import sys
import pcbnew

def flip_to_back():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    count_c = 0
    # 1. Flip C1-C8 to the back layer
    for fp in board.GetFootprints():
        try:
            ref = fp.GetReference()
        except:
            continue
            
        if ref in ["C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8"]:
            if fp.GetLayer() == pcbnew.F_Cu:
                fp.Flip(fp.GetPosition(), False)
                count_c += 1
                
        # 2. Fix J1 pads to be on the back layer
        if ref == "J1":
            for pad in fp.Pads():
                lset = pcbnew.LSET()
                lset.AddLayer(pcbnew.B_Cu)
                lset.AddLayer(pcbnew.B_Mask)
                lset.AddLayer(pcbnew.B_Paste)
                pad.SetLayerSet(lset)
                
    pcbnew.SaveBoard(board_file, board)
    print(f"Flipped {count_c} capacitors to back, and fixed J1 pads to back.")

if __name__ == "__main__":
    flip_to_back()
