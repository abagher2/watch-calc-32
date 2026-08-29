import wx
app = wx.App(False)
import pcbnew
import sys

def get_or_create_net(board, net_name):
    net = board.FindNet(net_name)
    if net is None:
        net = pcbnew.NETINFO_ITEM(board, net_name)
        board.Add(net)
    return net

def run(board_file="calculator.kicad_pcb"):
    if len(sys.argv) > 1:
        board_file = sys.argv[1]
    board = pcbnew.LoadBoard(board_file)

    net_cs = get_or_create_net(board, "Net-(J1-Pad2)").GetNetCode()
    net_rst = get_or_create_net(board, "Net-(J1-Pad3)").GetNetCode()
    net_a0 = get_or_create_net(board, "Net-(J1-Pad4)").GetNetCode()
    net_sck = get_or_create_net(board, "Net-(J1-Pad13)").GetNetCode()
    net_mosi = get_or_create_net(board, "Net-(J1-Pad14)").GetNetCode()
    
    net_3v3 = get_or_create_net(board, "+3V3").GetNetCode()
    net_gnd = get_or_create_net(board, "GND").GetNetCode()
    
    net_vout = get_or_create_net(board, "Net-(J1-Pad17)").GetNetCode()
    net_cap1n = get_or_create_net(board, "Net-(J1-Pad18)").GetNetCode()
    net_cap1p = get_or_create_net(board, "Net-(J1-Pad19)").GetNetCode()
    net_cap2n = get_or_create_net(board, "Net-(J1-Pad20)").GetNetCode()
    net_cap2p = get_or_create_net(board, "Net-(J1-Pad21)").GetNetCode()
    net_v1 = get_or_create_net(board, "Net-(J1-Pad22)").GetNetCode()
    net_v2 = get_or_create_net(board, "Net-(J1-Pad23)").GetNetCode()
    net_v3 = get_or_create_net(board, "Net-(J1-Pad24)").GetNetCode()
    net_v4 = get_or_create_net(board, "Net-(J1-Pad25)").GetNetCode()
    net_v0 = get_or_create_net(board, "Net-(J1-Pad26)").GetNetCode()

    j1 = None
    # Find all required footprints in one pass
    for fp in board.Footprints():
        ref = fp.GetReference()
        if ref == "J1":
            j1 = fp

    if not j1:
        print("Could not find J1")
        sys.exit(1)

    # Delete old J1 pads
    for pad in list(j1.Pads()):
        j1.Remove(pad)

    # Add 28 new pads to J1 (0.5mm pitch)
    # The pads are 0.3mm x 1.25mm
    j1_x = pcbnew.FromMM(45.0)  # Move J1 horizontally clear of Pico
    j1_y = pcbnew.FromMM(-100.0)  # Move closer to the cutout
    j1.SetPosition(pcbnew.VECTOR2I(j1_x, j1_y))
    
    # 28 pads, 27 intervals of 0.5mm = 13.5mm total width
    # We will center the pads on J1's position
    start_x = j1_x - pcbnew.FromMM(13.5 / 2.0)
    
    # Optional: Mechanical pads
    j1_pads = {}
    
    # Left mechanical pad
    pad_m1 = pcbnew.PAD(j1)
    pad_m1.SetNumber("M1")
    pad_m1.SetShape(pcbnew.PAD_SHAPE_RECT)
    pad_m1.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
    pad_m1.SetLayerSet(pad_m1.SMDMask())
    pad_m1.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.45), pcbnew.FromMM(3.0)))
    pad_m1.SetPosition(pcbnew.VECTOR2I(j1_x - pcbnew.FromMM(18.35 / 2.0), j1_y + pcbnew.FromMM(1.5)))
    j1.Add(pad_m1)
    j1_pads["M1"] = pad_m1
    
    # Right mechanical pad
    pad_m2 = pcbnew.PAD(j1)
    pad_m2.SetNumber("M2")
    pad_m2.SetShape(pcbnew.PAD_SHAPE_RECT)
    pad_m2.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
    pad_m2.SetLayerSet(pad_m2.SMDMask())
    pad_m2.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.45), pcbnew.FromMM(3.0)))
    pad_m2.SetPosition(pcbnew.VECTOR2I(j1_x + pcbnew.FromMM(18.35 / 2.0), j1_y + pcbnew.FromMM(1.5)))
    j1.Add(pad_m2)
    j1_pads["M2"] = pad_m2

    for i in range(28):
        pad = pcbnew.PAD(j1)
        pad.SetNumber(str(i+1))
        pad.SetShape(pcbnew.PAD_SHAPE_RECT)
        pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        pad.SetLayerSet(pad.SMDMask())
        pad.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(0.3), pcbnew.FromMM(1.25)))
        pad.SetPosition(pcbnew.VECTOR2I(start_x + pcbnew.FromMM(i * 0.5), j1_y))
        j1.Add(pad)
        j1_pads[str(i+1)] = pad

    def create_0805_capacitor(board, ref, x, y):
        fp = pcbnew.FOOTPRINT(board)
        fp.SetReference(ref)
        
        pad1 = pcbnew.PAD(fp)
        pad1.SetNumber("1")
        pad1.SetShape(pcbnew.PAD_SHAPE_RECT)
        pad1.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        pad1.SetLayerSet(pad1.SMDMask())
        pad1.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.2), pcbnew.FromMM(1.3)))
        pad1.SetPosition(pcbnew.VECTOR2I(x - pcbnew.FromMM(1.0), y))
        fp.Add(pad1)
        
        pad2 = pcbnew.PAD(fp)
        pad2.SetNumber("2")
        pad2.SetShape(pcbnew.PAD_SHAPE_RECT)
        pad2.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        pad2.SetLayerSet(pad2.SMDMask())
        pad2.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.2), pcbnew.FromMM(1.3)))
        pad2.SetPosition(pcbnew.VECTOR2I(x + pcbnew.FromMM(1.0), y))
        fp.Add(pad2)
        
        fp.SetPosition(pcbnew.VECTOR2I(x, y))
        board.Add(fp)
        return fp, pad1, pad2

    # 3. Add 8 Capacitors
    caps = {}
    caps_pads = {}
    
    cap_start_x = j1_x - pcbnew.FromMM(10)
    cap_start_y = j1_y - pcbnew.FromMM(6)
    
    c_refs = ["C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8"]
    for i, ref in enumerate(c_refs):
        cx = cap_start_x + pcbnew.FromMM(i * 2.5)
        cy = cap_start_y
        fp, p1, p2 = create_0805_capacitor(board, ref, cx, cy)
        caps[ref] = fp
        caps_pads[ref] = {"1": p1, "2": p2}

    def connect_j1(pad_num, netcode):
        if str(pad_num) in j1_pads:
            j1_pads[str(pad_num)].SetNetCode(netcode)

    def connect_cap(ref, pad_num, netcode):
        if ref in caps_pads and str(pad_num) in caps_pads[ref]:
            caps_pads[ref][str(pad_num)].SetNetCode(netcode)

    def connect_pico(pad_num, netcode):
        for pad in board.GetPads():
            try:
                parent = pad.GetParent()
                if parent and parent.GetReference() in ["U1", "MCU1"] and pad.GetNumber() == str(pad_num):
                    pad.SetNetCode(netcode)
                    break
            except AttributeError:
                pass

    connect_j1(2, net_cs)
    connect_j1(3, net_rst)
    connect_j1(4, net_a0)
    connect_j1(5, net_gnd) 
    connect_j1(6, net_gnd) 
    connect_j1(13, net_sck)
    connect_j1(14, net_mosi)
    connect_j1(15, net_3v3) 
    connect_j1(16, net_gnd) 
    
    connect_j1(17, net_vout)
    connect_j1(18, net_cap1n)
    connect_j1(19, net_cap1p)
    connect_j1(20, net_cap2n)
    connect_j1(21, net_cap2p)
    connect_j1(22, net_v1)
    connect_j1(23, net_v2)
    connect_j1(24, net_v3)
    connect_j1(25, net_v4)
    connect_j1(26, net_v0)
    
    connect_j1(27, net_gnd) 
    connect_j1(28, net_gnd) 

    connect_cap("C1", 1, net_cap1n)
    connect_cap("C1", 2, net_cap1p)
    connect_cap("C2", 1, net_cap2n)
    connect_cap("C2", 2, net_cap2p)
    connect_cap("C3", 1, net_vout)
    connect_cap("C3", 2, net_gnd)
    connect_cap("C4", 1, net_v1)
    connect_cap("C4", 2, net_gnd)
    connect_cap("C5", 1, net_v2)
    connect_cap("C5", 2, net_gnd)
    connect_cap("C6", 1, net_v3)
    connect_cap("C6", 2, net_gnd)
    connect_cap("C7", 1, net_v4)
    connect_cap("C7", 2, net_gnd)
    connect_cap("C8", 1, net_v0)
    connect_cap("C8", 2, net_gnd)

    connect_pico(17, net_cs)    # P2 (Pad 17) -> GP2
    connect_pico(3, net_rst)    # RST (Pad 3) -> Hardware Reset
    connect_pico(18, net_a0)    # P3 (Pad 18) -> GP3
    connect_pico(8, net_sck)    # P18 (Pad 8) -> GP18
    connect_pico(7, net_mosi)   # P19 (Pad 7) -> GP19

    pcbnew.SaveBoard(board_file, board)
    print("Updated J1 footprint to 28-pin and configured charge pump!")

if __name__ == "__main__":
    run()
