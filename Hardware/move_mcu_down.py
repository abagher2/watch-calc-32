import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def move_mcu():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        mcu = board.FindFootprintByReference("MCU1")
        if mcu:
            # Move to -102.5
            pos = mcu.GetPosition()
            pos.y = pcbnew.FromMM(-102.5)
            mcu.SetPosition(pos)
            
        pcbnew.SaveBoard(board_file, board)
        print("Successfully moved MCU1 down 8mm to Y = -102.5")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    move_mcu()
