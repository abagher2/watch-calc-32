import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def update_board():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # 1. Adjust buttons
        count_buttons = 0
        for fp in board.GetFootprints():
            try:
                ref = fp.GetReference()
            except:
                continue
                
            if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
                pos = fp.GetPosition()
                y_mm = pcbnew.ToMM(pos.y)
                
                row_idx = round((y_mm + 74.0) / 10.0)
                new_y_mm = 2.0 - ((7 - row_idx) * 10.8)
                
                new_pos = pcbnew.VECTOR2I(pos.x, int(pcbnew.FromMM(new_y_mm)))
                fp.SetPosition(new_pos)
                count_buttons += 1
                
        # 2. Replace J1
        j1_existing = board.FindFootprintByReference("J1")
        if j1_existing:
            board.Remove(j1_existing)
            
        lib_path = "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints/Connector_FFC-FPC.pretty"
        fp_name = "Hirose_FH12-28S-0.5SH_1x28-1MP_P0.50mm_Horizontal"
        
        try:
            j1_new = pcbnew.FootprintLoad(lib_path, fp_name)
            if j1_new:
                j1_new.SetReference("J1")
                j1_new.SetPosition(pcbnew.VECTOR2I(int(pcbnew.FromMM(45.0)), int(pcbnew.FromMM(-95.0))))
                
                if j1_new.GetLayer() == pcbnew.F_Cu:
                    j1_new.Flip(j1_new.GetPosition(), False)
                    
                board.Add(j1_new)
                print(f"Successfully added {fp_name} as J1 on the back layer.")
        except Exception as e:
            print(f"Failed to load footprint: {e}")
            
        pcbnew.SaveBoard(board_file, board)
        print(f"Adjusted {count_buttons} buttons to 10.8mm pitch.")
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    update_board()
