import sys
import pcbnew

def cleanup():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    # 1. Hide all reference labels
    for fp in board.GetFootprints():
        fp.Reference().SetVisible(False)
        
    # 2. Remove stray fiducials that are way off the board
    stray_refs = ["FID1", "FID2", "FID3"]
    fps_to_remove = []
    for fp in board.GetFootprints():
        if fp.GetReference() in stray_refs:
            fps_to_remove.append(fp)
            
    for fp in fps_to_remove:
        board.Remove(fp)
        
    pcbnew.SaveBoard(board_file, board)
    print("Cleaned up board: hid all reference labels and removed stray fiducials.")

if __name__ == "__main__":
    cleanup()
