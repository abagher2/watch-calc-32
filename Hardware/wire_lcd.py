import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def wire_lcd():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        j1 = board.FindFootprintByReference("J1")
        mcu = board.FindFootprintByReference("MCU1")
        
        # SPI requirements for J1:
        # Pad 2: /CS
        # Pad 3: /RES
        # Pad 4: A0
        # Pad 13: SCL
        # Pad 14: SI
        
        # MCU Pins available:
        # Pad 18 (was incorrectly GND)
        # Pad 22 
        # Pad 23 (was incorrectly GND)
        # Pad 24 
        
        # We will tie /RES (J1-Pad3) to RST (MCU Pad 3, net 'RST')
        rst_net = board.FindNet("RST")
        if rst_net:
            j1.FindPadByNumber("3").SetNetCode(rst_net.GetNetCode())
        
        # We need 4 nets for the SPI data lines. 
        # Let's create or find nets for them.
        spi_nets = {
            "2": "SPI_CS",
            "4": "SPI_DC",
            "13": "SPI_SCK",
            "14": "SPI_MOSI"
        }
        
        mcu_mapping = {
            "SPI_CS": "18",
            "SPI_DC": "22",
            "SPI_SCK": "23",
            "SPI_MOSI": "24"
        }
        
        for j1_pad_num, net_name in spi_nets.items():
            net = board.FindNet(net_name)
            if not net:
                net = pcbnew.NETINFO_ITEM(board, net_name)
                board.Add(net)
            
            j1.FindPadByNumber(j1_pad_num).SetNetCode(net.GetNetCode())
            mcu.FindPadByNumber(mcu_mapping[net_name]).SetNetCode(net.GetNetCode())
            
        # Ensure we disconnect any accidental nets from MCU pads 18, 22, 23, 24 that aren't these SPI nets
        # (Already handled by SetNetCode overriding them)
        
        pcbnew.SaveBoard(board_file, board)
        print("Successfully assigned LCD SPI nets to J1 and MCU1, sharing RES with RST!")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    wire_lcd()
