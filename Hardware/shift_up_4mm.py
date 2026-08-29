import sys
import pcbnew

def shift_up():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    # Move buttons UP by 4.0mm
    shift_mm = 4.0
    shift_internal = pcbnew.FromMM(shift_mm)
    
    count = 0
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            # Decreasing Y moves the component UP
            new_pos = pcbnew.VECTOR2I(pos.x, pos.y - shift_internal)
            fp.SetPosition(new_pos)
            count += 1
            
    pcbnew.SaveBoard(board_file, board)
    print(f"Moved {count} buttons UP by {shift_mm}mm.")

if __name__ == "__main__":
    shift_up()
