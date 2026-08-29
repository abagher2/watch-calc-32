import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def rewire():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        j1 = board.FindFootprintByReference("J1")
        mcu = board.FindFootprintByReference("MCU1")
        
        # 1. First, move the displaced button nets to the free pads on the right
        # Pad 22 will get P1
        # Pad 23 will get P2
        # Pad 24 will get P4
        
        net_p1 = board.FindNet("P1")
        if net_p1: mcu.FindPadByNumber("22").SetNetCode(net_p1.GetNetCode())
        
        net_p2 = board.FindNet("P2")
        if net_p2: mcu.FindPadByNumber("23").SetNetCode(net_p2.GetNetCode())
        
        net_p4 = board.FindNet("P4")
        if net_p4: mcu.FindPadByNumber("24").SetNetCode(net_p4.GetNetCode())

        # 2. Assign the hardware SPI0 pins to the MCU and J1
        # spi0 CS = GP1 (Pad 13)
        # spi0 SCK = GP2 (Pad 17)
        # spi0 TX = GP3 (Pad 18)
        # DC = GP4 (Pad 19)
        
        spi_map = {
            "SPI_CS": {"j1": "2", "mcu": "13"},
            "SPI_SCK": {"j1": "13", "mcu": "17"},
            "SPI_MOSI": {"j1": "14", "mcu": "18"},
            "SPI_DC": {"j1": "4", "mcu": "19"}
        }
        
        for net_name, pads in spi_map.items():
            net = board.FindNet(net_name)
            if not net:
                net = pcbnew.NETINFO_ITEM(board, net_name)
                board.Add(net)
                
            j1.FindPadByNumber(pads["j1"]).SetNetCode(net.GetNetCode())
            mcu.FindPadByNumber(pads["mcu"]).SetNetCode(net.GetNetCode())
            
        pcbnew.SaveBoard(board_file, board)
        print("Hardware SPI wiring complete on KiCad!")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    rewire()
