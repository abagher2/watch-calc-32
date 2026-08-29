import sys
import pcbnew

def final_fix():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    # 1. Update Edge.Cuts to exactly match the Chassis Cavity
    min_x = pcbnew.FromMM(9.2)
    max_x = pcbnew.FromMM(80.8)
    min_y = pcbnew.FromMM(-135.5)
    max_y = pcbnew.FromMM(6.8)
    
    outer_lines = []
    for drawing in board.GetDrawings():
        if drawing.GetLayerName() == "Edge.Cuts":
            start_x_mm = pcbnew.ToMM(drawing.GetStart().x)
            start_y_mm = pcbnew.ToMM(drawing.GetStart().y)
            if start_x_mm > 30 and start_x_mm < 60 and start_y_mm > -90 and start_y_mm < -80:
                continue # Skip the cutout
            outer_lines.append(drawing)
            
    # We should have 4 outer lines. Let's just reposition them to form the box.
    if len(outer_lines) >= 4:
        outer_lines[0].SetStart(pcbnew.VECTOR2I(int(min_x), int(min_y)))
        outer_lines[0].SetEnd(pcbnew.VECTOR2I(int(max_x), int(min_y)))
        
        outer_lines[1].SetStart(pcbnew.VECTOR2I(int(max_x), int(min_y)))
        outer_lines[1].SetEnd(pcbnew.VECTOR2I(int(max_x), int(max_y)))
        
        outer_lines[2].SetStart(pcbnew.VECTOR2I(int(max_x), int(max_y)))
        outer_lines[2].SetEnd(pcbnew.VECTOR2I(int(min_x), int(max_y)))
        
        outer_lines[3].SetStart(pcbnew.VECTOR2I(int(min_x), int(max_y)))
        outer_lines[3].SetEnd(pcbnew.VECTOR2I(int(min_x), int(min_y)))
        
        # If there are extra lines (like duplicates), remove them
        for drawing in outer_lines[4:]:
            board.Remove(drawing)
    else:
        print("Error: Could not find 4 outer lines.")

    # 2. Fix the capacitors (C1-C8) that got double-shifted to Y = -212
    for fp in board.GetFootprints():
        try:
            ref = fp.GetReference()
        except:
            continue
        if ref in ["C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8"]:
            fp_pos = fp.GetPosition()
            pad1 = fp.FindPadByNumber("1")
            if pad1:
                pad1.SetPosition(pcbnew.VECTOR2I(int(fp_pos.x - pcbnew.FromMM(1.0)), int(fp_pos.y)))
            pad2 = fp.FindPadByNumber("2")
            if pad2:
                pad2.SetPosition(pcbnew.VECTOR2I(int(fp_pos.x + pcbnew.FromMM(1.0)), int(fp_pos.y)))

    # 3. Move buttons DOWN by 16.0mm (Y += 16.0)
    shift_mm = 16.0
    shift_internal = pcbnew.FromMM(shift_mm)
    
    count = 0
    for fp in board.GetFootprints():
        try:
            ref = fp.GetReference()
        except:
            continue
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            new_pos = pcbnew.VECTOR2I(pos.x, int(pos.y + shift_internal))
            fp.SetPosition(new_pos)
            count += 1
            
    pcbnew.SaveBoard(board_file, board)
    print(f"Set Edge.Cuts to Chassis bounds, fixed capacitors, and moved {count} buttons DOWN by {shift_mm}mm.")

if __name__ == "__main__":
    final_fix()
