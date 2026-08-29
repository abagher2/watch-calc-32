import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def tweak_buttons():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # Adjust buttons to 11.3mm pitch
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
            # Row 0 (top) is at Y=-82.0, Pitch is 11.3mm
            for row_idx, row in enumerate(rows):
                new_y_mm = -82.0 + (row_idx * 11.3)
                for fp in row:
                    pos = fp.GetPosition()
                    fp.SetPosition(pcbnew.VECTOR2I(pos.x, int(pcbnew.FromMM(new_y_mm))))
            print("Successfully moved 43 buttons to 11.3mm vertical pitch (Y=-82.0 to Y=-2.9).")

        pcbnew.SaveBoard(board_file, board)
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    tweak_buttons()
