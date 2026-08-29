import sys
import pcbnew

def fix_board():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    # 1. Fix the capacitors (C1-C8) that got double-shifted to Y = -212
    # Their footprints are at Y = -106, but their pads got shifted.
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if ref in ["C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8"]:
            # The footprint's absolute position is correct
            fp_pos = fp.GetPosition()
            
            # Pad 1 should be at X - 1.0mm
            pad1 = fp.FindPadByNumber("1")
            if pad1:
                pad1.SetPosition(pcbnew.VECTOR2I(fp_pos.x - pcbnew.FromMM(1.0), fp_pos.y))
                
            # Pad 2 should be at X + 1.0mm
            pad2 = fp.FindPadByNumber("2")
            if pad2:
                pad2.SetPosition(pcbnew.VECTOR2I(fp_pos.x + pcbnew.FromMM(1.0), fp_pos.y))
                
    # 2. Move buttons UP by 20mm (Y -= 20.0) so they are just below the cutout
    shift_mm = 20.0
    shift_internal = pcbnew.FromMM(shift_mm)
    
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            new_pos = pcbnew.VECTOR2I(pos.x, pos.y - shift_internal)
            fp.SetPosition(new_pos)
            
    # 3. Restore Edge.Cuts bottom to Y = -16.0 (since buttons are moved up)
    new_bottom_y = pcbnew.FromMM(-16.0)
    for drawing in board.GetDrawings():
        if drawing.GetLayerName() == "Edge.Cuts":
            # If it's a bottom horizontal line (was at 6.8 or 6.0)
            if drawing.GetStart().y > pcbnew.FromMM(0) and drawing.GetEnd().y > pcbnew.FromMM(0):
                drawing.SetStart(pcbnew.VECTOR2I(drawing.GetStart().x, new_bottom_y))
                drawing.SetEnd(pcbnew.VECTOR2I(drawing.GetEnd().x, new_bottom_y))
            # If it's a vertical line extending to the bottom
            elif drawing.GetStart().y > pcbnew.FromMM(0):
                drawing.SetStart(pcbnew.VECTOR2I(drawing.GetStart().x, new_bottom_y))
            elif drawing.GetEnd().y > pcbnew.FromMM(0):
                drawing.SetEnd(pcbnew.VECTOR2I(drawing.GetEnd().x, new_bottom_y))

    pcbnew.SaveBoard(board_file, board)
    print("Fixed capacitor pads and moved buttons back up by 20mm.")

if __name__ == "__main__":
    fix_board()
