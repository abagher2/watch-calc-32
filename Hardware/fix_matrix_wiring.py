import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def fix_matrix():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        mcu = board.FindFootprintByReference("MCU1")
        
        pads_available = ["5", "6", "7", "8", "9", "10", "11", "12", "14", "20", "21", "22", "23", "24"]
        matrix_nets = ['P0', 'P1', 'P4', 'P5', 'P6', 'P7', 'P8', 'P9', 'P10', 'P14', 'P15', 'P16', 'P20', 'P21']
        
        # Unassign any matrix nets currently on the MCU that aren't in this mapping?
        # Actually just assign the pads to the nets. The old nets on these pads will be overwritten.
        
        for pad_name, net_name in zip(pads_available, matrix_nets):
            net = board.FindNet(net_name)
            if not net:
                net = pcbnew.NETINFO_ITEM(board, net_name)
                board.Add(net)
            
            mcu.FindPadByNumber(pad_name).SetNetCode(net.GetNetCode())
            
        pcbnew.SaveBoard(board_file, board)
        print("Successfully assigned the 14 Matrix nets to the 14 available MCU pads!")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    fix_matrix()
