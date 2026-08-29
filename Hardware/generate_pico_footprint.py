import sys
import wx
app = wx.App(False)
import pcbnew
import traceback

def create_pico2_footprint():
    try:
        board_file = "calculator.kicad_pcb"
        board = pcbnew.LoadBoard(board_file)
        
        # Remove old MCU1
        old_mcu = board.FindFootprintByReference("MCU1")
        if old_mcu:
            board.Remove(old_mcu)
            
        fp = pcbnew.FOOTPRINT(board)
        fp.SetReference("MCU1")
        fp.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(21.5), pcbnew.FromMM(-110.5)))
        fp.SetOrientation(pcbnew.EDA_ANGLE(0, pcbnew.DEGREES_T)) # Vertical
        fp.SetLayer(pcbnew.B_Cu)
        
        pad_pitch = 2.54
        row_width = 17.78
        start_y = -24.13
        
        net_map = {
            "3": "GND", "8": "GND", "13": "GND", "18": "GND", "23": "GND", "28": "GND", "33": "GND", "38": "GND",
            "39": "RAW", "36": "VCC", "30": "RST",
            "5": "SPI_MOSI", "4": "SPI_SCK", "2": "SPI_CS", "6": "SPI_DC", "7": "SPI_RES",
            "9": "P0", "10": "P1", "11": "P4", "12": "P5", "14": "P6", "15": "P7", "16": "P8", "17": "P9",
            "19": "P10", "20": "P14", "21": "P15", "22": "P16", "24": "P20", "25": "P21"
        }
        
        label_map = {
            1: "GP0", 2: "GP1", 3: "GND", 4: "GP2", 5: "GP3", 6: "GP4", 7: "GP5", 8: "GND", 9: "GP6", 10: "GP7",
            11: "GP8", 12: "GP9", 13: "GND", 14: "GP10", 15: "GP11", 16: "GP12", 17: "GP13", 18: "GND", 19: "GP14", 20: "GP15",
            21: "GP16", 22: "GP17", 23: "GND", 24: "GP18", 25: "GP19", 26: "GP20", 27: "GP21", 28: "GND", 29: "GP22", 30: "RUN",
            31: "GP26", 32: "GP27", 33: "GND", 34: "GP28", 35: "ADC_V", 36: "3V3", 37: "3V3_E", 38: "GND", 39: "VSYS", 40: "VBUS"
        }
        
        for i in range(1, 41):
            pad = pcbnew.PAD(fp)
            pad.SetPadName(str(i))
            pad.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
            pad.SetShape(pcbnew.PAD_SHAPE_RECT)
            
            size = pcbnew.VECTOR2I(pcbnew.FromMM(1.7), pcbnew.FromMM(1.7))
            pad.SetSize(size)
            pad.SetDrillSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.0), pcbnew.FromMM(1.0)))
            pad.SetLayerSet(pad.PTHMask())
            
            # Pad 1 is on the LEFT of the BACK view.
            # When viewing from the FRONT, the back-left is the FRONT-RIGHT.
            # So Pad 1 needs positive X in absolute coordinates.
            if i <= 20:
                px = row_width / 2.0 # Positive X -> Right on front, Left on back
                py = start_y + (i - 1) * pad_pitch
            else:
                px = -row_width / 2.0 # Negative X -> Left on front, Right on back
                py = start_y + (40 - i) * pad_pitch
                
            abs_x = fp.GetPosition().x + pcbnew.FromMM(px)
            abs_y = fp.GetPosition().y + pcbnew.FromMM(py)
            pad.SetPosition(pcbnew.VECTOR2I(abs_x, abs_y))
            
            net_name = net_map.get(str(i))
            if net_name:
                net = board.FindNet(net_name)
                if not net:
                    net = pcbnew.NETINFO_ITEM(board, net_name)
                    board.Add(net)
                pad.SetNetCode(net.GetNetCode())
            
            fp.Add(pad)
            
            # Add silkscreen label for the pad
            text = pcbnew.PCB_TEXT(fp)
            text.SetText(label_map[i])
            text.SetLayer(pcbnew.B_SilkS)
            text.SetTextSize(pcbnew.VECTOR2I(pcbnew.FromMM(0.8), pcbnew.FromMM(0.8)))
            text.SetTextThickness(pcbnew.FromMM(0.15))
            text.SetMirrored(True) # Text on back must be mirrored so it reads correctly when looking at back
            
            # Place text inside the Pico outline
            if i <= 20:
                tx = px - 1.5 # Move left from pad (in front view -> right from pad)
                text.SetHorizJustify(pcbnew.GR_TEXT_H_ALIGN_RIGHT)
            else:
                tx = px + 1.5
                text.SetHorizJustify(pcbnew.GR_TEXT_H_ALIGN_LEFT)
            
            text_abs_x = fp.GetPosition().x + pcbnew.FromMM(tx)
            text.SetPosition(pcbnew.VECTOR2I(text_abs_x, abs_y))
            fp.Add(text)
            
        # Add Pico Outline on B.SilkS
        rect = pcbnew.FP_SHAPE(fp)
        rect.SetShape(pcbnew.SHAPE_T_RECT)
        rect.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(-10.5), pcbnew.FromMM(-25.5)))
        rect.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(10.5), pcbnew.FromMM(25.5)))
        rect.SetLayer(pcbnew.B_SilkS)
        rect.SetWidth(pcbnew.FromMM(0.2))
        fp.Add(rect)
        
        # Add USB Port Outline (at top, facing UP)
        # Top of Pico is Y = -25.5
        usb = pcbnew.FP_SHAPE(fp)
        usb.SetShape(pcbnew.SHAPE_T_RECT)
        usb.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(-3.75), pcbnew.FromMM(-25.5)))
        usb.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(3.75), pcbnew.FromMM(-27.5)))
        usb.SetLayer(pcbnew.B_SilkS)
        usb.SetWidth(pcbnew.FromMM(0.2))
        fp.Add(usb)
        
        # USB Label
        usb_label = pcbnew.PCB_TEXT(fp)
        usb_label.SetText("USB")
        usb_label.SetLayer(pcbnew.B_SilkS)
        usb_label.SetTextSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.2), pcbnew.FromMM(1.2)))
        usb_label.SetTextThickness(pcbnew.FromMM(0.2))
        usb_label.SetMirrored(True)
        usb_label.SetPosition(pcbnew.VECTOR2I(fp.GetPosition().x, fp.GetPosition().y + pcbnew.FromMM(-23.0)))
        fp.Add(usb_label)

        board.Add(fp)
        
        j1 = board.FindFootprintByReference("J1")
        if j1:
            j1.FindPadByNumber("2").SetNetCode(board.FindNet("SPI_CS").GetNetCode())
            j1.FindPadByNumber("3").SetNetCode(board.FindNet("SPI_RES").GetNetCode())
            j1.FindPadByNumber("4").SetNetCode(board.FindNet("SPI_DC").GetNetCode())
            j1.FindPadByNumber("13").SetNetCode(board.FindNet("SPI_SCK").GetNetCode())
            j1.FindPadByNumber("14").SetNetCode(board.FindNet("SPI_MOSI").GetNetCode())

        pcbnew.SaveBoard(board_file, board)
        print("Successfully regenerated Pico 2 footprint with correct mirrored geometry, silkscreen outline, USB, and labels!")
        
    except Exception as e:
        print("Fatal error:")
        traceback.print_exc()

if __name__ == "__main__":
    create_pico2_footprint()
