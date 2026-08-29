import sys
import pcbnew

def resize_and_move():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    new_bottom_y = pcbnew.FromMM(6.8)
    old_bottom_y = pcbnew.FromMM(-16.0)
    
    # 1. Extend Edge.Cuts to Y = 6.8
    for drawing in board.GetDrawings():
        if drawing.GetLayerName() == "Edge.Cuts":
            # If it's the bottom horizontal line
            if drawing.GetStart().y == old_bottom_y and drawing.GetEnd().y == old_bottom_y:
                new_start = pcbnew.VECTOR2I(drawing.GetStart().x, new_bottom_y)
                new_end = pcbnew.VECTOR2I(drawing.GetEnd().x, new_bottom_y)
                drawing.SetStart(new_start)
                drawing.SetEnd(new_end)
            # If it's a vertical side line ending at old_bottom_y
            elif drawing.GetStart().y == old_bottom_y:
                new_start = pcbnew.VECTOR2I(drawing.GetStart().x, new_bottom_y)
                drawing.SetStart(new_start)
            elif drawing.GetEnd().y == old_bottom_y:
                new_end = pcbnew.VECTOR2I(drawing.GetEnd().x, new_bottom_y)
                drawing.SetEnd(new_end)
                
    # 2. Move buttons DOWN by 22.0mm
    shift_mm = 22.0
    shift_internal = pcbnew.FromMM(shift_mm)
    
    count = 0
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            # Increasing Y moves the component DOWN
            new_pos = pcbnew.VECTOR2I(pos.x, pos.y + shift_internal)
            fp.SetPosition(new_pos)
            count += 1
            
    pcbnew.SaveBoard(board_file, board)
    print(f"Extended PCB bottom edge to Y=6.8 and moved {count} buttons DOWN by {shift_mm}mm.")

if __name__ == "__main__":
    resize_and_move()
