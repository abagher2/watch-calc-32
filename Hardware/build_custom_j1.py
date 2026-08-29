import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def create_er_con28hb_1(board):
    # Create the footprint
    fp = pcbnew.FOOTPRINT(board)
    fp.SetReference("J1")
    fp.SetLayer(pcbnew.B_Cu)
    
    # 28 Signal Pads
    # A = 13.50 (distance between pad 1 and pad 28)
    pitch = 0.50
    pad_width = 0.30
    pad_height = 1.25
    
    # Signal pads center Y = 0
    # Pad 1 is at X = -6.75
    for i in range(28):
        pad = pcbnew.PAD(fp)
        pad.SetPadName(str(i+1))
        pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        
        # B_Cu, B_Mask, B_Paste
        lset = pcbnew.LSET()
        lset.AddLayer(pcbnew.B_Cu)
        lset.AddLayer(pcbnew.B_Mask)
        lset.AddLayer(pcbnew.B_Paste)
        pad.SetLayerSet(lset)
        
        pad.SetSize(pcbnew.VECTOR2I(int(pcbnew.FromMM(pad_width)), int(pcbnew.FromMM(pad_height))))
        pad.SetShape(pcbnew.PAD_SHAPE_RECT)
        
        # Orient for B.Cu
        # The slot faces down. According to standard conventions, if we want the slot facing down (+Y),
        # the pads are towards the top of the footprint. Let's keep Y=0 for pads.
        # Mechanical pads are at Y=+2.875, so they are below the pads.
        x = -6.75 + (i * pitch)
        pad.SetPosition(pcbnew.VECTOR2I(int(pcbnew.FromMM(x)), 0))
        fp.Add(pad)
        
    # Mechanical Pads
    # Center X = -6.75 - 2.54 = -9.29
    # Center Y = 2.875
    # Width = 1.45, Height = 3.00
    for side in ["M1", "M2"]:
        pad = pcbnew.PAD(fp)
        pad.SetPadName(side)
        pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        
        lset = pcbnew.LSET()
        lset.AddLayer(pcbnew.B_Cu)
        lset.AddLayer(pcbnew.B_Mask)
        lset.AddLayer(pcbnew.B_Paste)
        pad.SetLayerSet(lset)
        
        pad.SetSize(pcbnew.VECTOR2I(int(pcbnew.FromMM(1.45)), int(pcbnew.FromMM(3.00))))
        pad.SetShape(pcbnew.PAD_SHAPE_RECT)
        
        x = -9.29 if side == "M1" else 9.29
        pad.SetPosition(pcbnew.VECTOR2I(int(pcbnew.FromMM(x)), int(pcbnew.FromMM(2.875))))
        fp.Add(pad)
        
    # Draw silkscreen outline
    # D = 19.65
    # Top edge of housing is above pads. Let's make a simple box.
    # Housing height is approx 4.50. Let's draw it from Y=-1.0 to Y=3.5
    for start, end in [
        ((-9.825, -1.0), (9.825, -1.0)),
        ((9.825, -1.0), (9.825, 3.5)),
        ((9.825, 3.5), (-9.825, 3.5)),
        ((-9.825, 3.5), (-9.825, -1.0))
    ]:
        line = pcbnew.PCB_SHAPE(fp)
        line.SetShape(pcbnew.SHAPE_T_SEGMENT)
        line.SetLayer(pcbnew.B_SilkS)
        line.SetStart(pcbnew.VECTOR2I(int(pcbnew.FromMM(start[0])), int(pcbnew.FromMM(start[1]))))
        line.SetEnd(pcbnew.VECTOR2I(int(pcbnew.FromMM(end[0])), int(pcbnew.FromMM(end[1]))))
        line.SetWidth(int(pcbnew.FromMM(0.15)))
        fp.Add(line)
        
    return fp

def update_board():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # 1. Adjust buttons to 10.8mm pitch
        buttons = []
        for fp in board.GetFootprints():
            ref = fp.GetReference()
            if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
                buttons.append(fp)
                
        # Group into rows by Y coordinate
        # Sort by Y ascending (most negative first, which is the top row)
        buttons.sort(key=lambda f: f.GetPosition().y)
        
        rows = []
        current_row = []
        last_y = None
        
        for fp in buttons:
            y = pcbnew.ToMM(fp.GetPosition().y)
            if last_y is None or abs(y - last_y) > 5.0:
                if current_row:
                    rows.append(current_row)
                current_row = [fp]
            else:
                current_row.append(fp)
            last_y = y
            
        if current_row:
            rows.append(current_row)
            
        if len(rows) != 8:
            print(f"Warning: Found {len(rows)} rows instead of 8. Aborting button move.")
        else:
            # Row 7 (bottom) is at Y=2.0, Row 0 (top) is at Y=-73.6
            for row_idx, row in enumerate(rows):
                new_y_mm = -73.6 + (row_idx * 10.8)
                for fp in row:
                    pos = fp.GetPosition()
                    fp.SetPosition(pcbnew.VECTOR2I(pos.x, int(pcbnew.FromMM(new_y_mm))))
            print("Successfully moved 43 buttons to 10.8mm vertical pitch.")

        # 2. Add custom J1 footprint
        j1_existing = board.FindFootprintByReference("J1")
        if j1_existing:
            board.Remove(j1_existing)
            
        j1_new = create_er_con28hb_1(board)
        
        # Place it at the cutout.
        # The cutout is at Y = -86.5 to -88.0.
        # If the ribbon folds down, it will enter the connector.
        # The pads (Y=0 in footprint) will be placed just above the cutout.
        # Let's put J1 center at X=45.0, Y=-93.0
        j1_new.SetPosition(pcbnew.VECTOR2I(int(pcbnew.FromMM(45.0)), int(pcbnew.FromMM(-93.0))))
        board.Add(j1_new)
        print("Successfully added ER-CON28HB-1 footprint for J1 on B.Cu.")
        
        # 3. Fix capacitors (ensure they are on back, C1-C8)
        for fp in board.GetFootprints():
            ref = fp.GetReference()
            if ref in [f"C{i}" for i in range(1, 9)]:
                if fp.GetLayer() == pcbnew.F_Cu:
                    fp.Flip(fp.GetPosition(), False)

        pcbnew.SaveBoard(board_file, board)
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    update_board()
