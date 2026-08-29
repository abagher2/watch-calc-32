import sys
import pcbnew

def shift_buttons():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    # 1. Shift all buttons UP by 4mm (decrease Y by 4.0mm)
    shift_mm = 4.0
    shift_internal = pcbnew.FromMM(shift_mm)
    
    count = 0
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        # Buttons are B1-B37 and SOFT1-SOFT6
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            # In KiCad, decreasing Y moves the component UP on the board
            new_pos = pcbnew.VECTOR2I(pos.x, pos.y - shift_internal)
            fp.SetPosition(new_pos)
            count += 1
            
    pcbnew.SaveBoard(board_file, board)
    print(f"Shifted {count} buttons UP by {shift_mm}mm.")

if __name__ == "__main__":
    shift_buttons()
