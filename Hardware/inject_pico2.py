import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def create_pico2_footprint():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # 1. Remove old MCU1
        old_mcu = board.FindFootprintByReference("MCU1")
        if old_mcu:
            board.Remove(old_mcu)
            
        # 2. Create new Pico footprint
        fp = pcbnew.FOOTPRINT(board)
        fp.SetReference("MCU1")
        fp.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(21.5), pcbnew.FromMM(-112.5)))
        fp.SetOrientation(pcbnew.EDA_ANGLE(0, pcbnew.DEGREES_T)) # Vertical
        fp.SetLayer(pcbnew.B_Cu)
        
        # 3. Add 40 pads
        pad_pitch = 2.54
        row_width = 17.78
        start_y = -24.13
        
        # Map of netnames to pads
        net_map = {
            "3": "GND", "8": "GND", "13": "GND", "18": "GND", "23": "GND", "28": "GND", "33": "GND", "38": "GND",
            "39": "RAW", "36": "VCC", "30": "RST",
            "5": "SPI_MOSI", "4": "SPI_SCK", "2": "SPI_CS", "6": "SPI_DC", "7": "SPI_RES",
            "9": "P0", "10": "P1", "11": "P4", "12": "P5", "14": "P6", "15": "P7", "16": "P8", "17": "P9",
            "19": "P10", "20": "P14", "21": "P15", "22": "P16", "24": "P20", "25": "P21"
        }
        
        for i in range(1, 41):
            pad = pcbnew.PAD(fp)
            pad.SetPadName(str(i))
            pad.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
            pad.SetShape(pcbnew.PAD_SHAPE_RECT) # Using rect or oval
            
            size = pcbnew.VECTOR2I(pcbnew.FromMM(1.7), pcbnew.FromMM(1.7))
            pad.SetSize(size)
            pad.SetDrillSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.0), pcbnew.FromMM(1.0)))
            
            pad.SetLayerSet(pad.PTHMask())
            
            if i <= 20:
                px = -row_width / 2.0
                py = start_y + (i - 1) * pad_pitch
            else:
                px = row_width / 2.0
                py = start_y + (40 - i) * pad_pitch
                
            abs_x = fp.GetPosition().x + pcbnew.FromMM(px)
            abs_y = fp.GetPosition().y + pcbnew.FromMM(py)
            pad.SetPosition(pcbnew.VECTOR2I(abs_x, abs_y))
            
            # Assign net
            net_name = net_map.get(str(i))
            if net_name:
                net = board.FindNet(net_name)
                if not net:
                    net = pcbnew.NETINFO_ITEM(board, net_name)
                    board.Add(net)
                pad.SetNetCode(net.GetNetCode())
            
            fp.Add(pad)
            
        board.Add(fp)
        
        # 4. We also need to map J1 SPI pads!
        j1 = board.FindFootprintByReference("J1")
        if j1:
            j1.FindPadByNumber("2").SetNetCode(board.FindNet("SPI_CS").GetNetCode())
            j1.FindPadByNumber("3").SetNetCode(board.FindNet("SPI_RES").GetNetCode())
            j1.FindPadByNumber("4").SetNetCode(board.FindNet("SPI_DC").GetNetCode())
            j1.FindPadByNumber("13").SetNetCode(board.FindNet("SPI_SCK").GetNetCode())
            j1.FindPadByNumber("14").SetNetCode(board.FindNet("SPI_MOSI").GetNetCode())

        pcbnew.SaveBoard(board_file, board)
        print("Successfully generated SC1632 Pico 2 footprint and wired all nets!")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    create_pico2_footprint()
