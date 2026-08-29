import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def shift_up():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # Move MCU1 up by 5mm
        mcu = board.FindFootprintByReference("MCU1")
        if mcu:
            pos = mcu.GetPosition()
            new_y = pos.y - pcbnew.FromMM(5.0)  # more negative is UP
            mcu.SetPosition(pcbnew.VECTOR2I(pos.x, new_y))
            print("Moved MCU1 up by 5mm.")
            
        # Move J1 up by 5mm
        j1 = board.FindFootprintByReference("J1")
        if j1:
            pos = j1.GetPosition()
            new_y = pos.y - pcbnew.FromMM(5.0)
            j1.SetPosition(pcbnew.VECTOR2I(pos.x, new_y))
            print("Moved J1 up by 5mm.")
            
        # Move C1-C8 up by 5mm
        moved_caps = 0
        for i in range(1, 9):
            cap = board.FindFootprintByReference(f"C{i}")
            if cap:
                pos = cap.GetPosition()
                new_y = pos.y - pcbnew.FromMM(5.0)
                cap.SetPosition(pcbnew.VECTOR2I(pos.x, new_y))
                moved_caps += 1
        print(f"Moved {moved_caps} capacitors up by 5mm.")

        pcbnew.SaveBoard(board_file, board)
        print("Success! Board saved.")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    shift_up()
