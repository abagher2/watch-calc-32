import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def move_caps():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # We need to move C1-C8. 
        # J1 is at Y = -93.0, buttons start at Y = -82.0 (footprint extends to -84.8).
        # We will place them in a row at Y = -88.0.
        # X center is 45.0. 8 capacitors spaced by 2.5mm is 7 gaps = 17.5mm wide.
        # So X starts at 45.0 - (17.5 / 2) = 36.25.
        
        start_x = 36.25
        pitch = 2.5
        new_y = -88.0
        
        moved = 0
        for i in range(1, 9):
            ref = f"C{i}"
            fp = board.FindFootprintByReference(ref)
            if fp:
                new_x = start_x + ((i - 1) * pitch)
                fp.SetPosition(pcbnew.VECTOR2I(int(pcbnew.FromMM(new_x)), int(pcbnew.FromMM(new_y))))
                moved += 1
                
        pcbnew.SaveBoard(board_file, board)
        print(f"Successfully moved {moved} capacitors to a safe location at Y = -88.0.")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    move_caps()
