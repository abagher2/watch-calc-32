import sys
import pcbnew

def unify_boxes():
    board_file = "calculator.kicad_pcb"
    board = pcbnew.LoadBoard(board_file)
    
    # Target bounding box (matches pcb_h=142.4 and pcb_w=72.0 from SCAD)
    # This also guarantees the buttons will fit nicely.
    min_x = pcbnew.FromMM(9.0)
    max_x = pcbnew.FromMM(81.0)
    min_y = pcbnew.FromMM(-138.0)
    max_y = pcbnew.FromMM(4.4)
    
    # 1. Update Edge.Cuts to perfectly match the target box
    outer_lines = []
    for drawing in board.GetDrawings():
        if drawing.GetLayerName() == "Edge.Cuts":
            start_x_mm = pcbnew.ToMM(drawing.GetStart().x)
            start_y_mm = pcbnew.ToMM(drawing.GetStart().y)
            # Skip the small LCD cutout
            if start_x_mm > 30 and start_x_mm < 60 and start_y_mm > -90 and start_y_mm < -80:
                continue 
            outer_lines.append(drawing)
            
    if len(outer_lines) >= 4:
        outer_lines[0].SetStart(pcbnew.VECTOR2I(int(min_x), int(min_y)))
        outer_lines[0].SetEnd(pcbnew.VECTOR2I(int(max_x), int(min_y)))
        outer_lines[1].SetStart(pcbnew.VECTOR2I(int(max_x), int(min_y)))
        outer_lines[1].SetEnd(pcbnew.VECTOR2I(int(max_x), int(max_y)))
        outer_lines[2].SetStart(pcbnew.VECTOR2I(int(max_x), int(max_y)))
        outer_lines[2].SetEnd(pcbnew.VECTOR2I(int(min_x), int(max_y)))
        outer_lines[3].SetStart(pcbnew.VECTOR2I(int(min_x), int(max_y)))
        outer_lines[3].SetEnd(pcbnew.VECTOR2I(int(min_x), int(min_y)))
        for drawing in outer_lines[4:]:
            board.Remove(drawing)
            
    # 2. Update all Copper Zones to perfectly match the target box
    # We rebuild the polygon for each zone.
    for zone in board.Zones():
        # Clear existing polygon and add a new perfectly aligned rectangle
        outline = zone.Outline()
        outline.RemoveAllContours()
        outline.NewOutline()
        outline.Append(int(min_x), int(min_y))
        outline.Append(int(max_x), int(min_y))
        outline.Append(int(max_x), int(max_y))
        outline.Append(int(min_x), int(max_y))
        
    # 3. Move buttons UP by 2.0mm (Y -= 2.0)
    # This ensures they have 1.575mm padding from the bottom edge Y=4.4
    shift_mm = 2.0
    shift_internal = pcbnew.FromMM(shift_mm)
    
    count = 0
    for fp in board.GetFootprints():
        try:
            ref = fp.GetReference()
        except:
            continue
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            new_pos = pcbnew.VECTOR2I(pos.x, int(pos.y - shift_internal))
            fp.SetPosition(new_pos)
            count += 1
            
    pcbnew.SaveBoard(board_file, board)
    print(f"Unification complete. Edge.Cuts and Zones matched, {count} buttons moved.")

if __name__ == "__main__":
    unify_boxes()
