import pcbnew
import os
import sys

def get_or_create_net(board, net_name):
    net = board.FindNet(net_name)
    if net is None:
        net = pcbnew.NETINFO_ITEM(board, net_name)
        board.Add(net)
    return net

def add_cap(board, ref, x, y):
    fp_dir = "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints/Capacitor_SMD.pretty"
    c_fp_name = "C_0402_1005Metric"
    fp = pcbnew.FootprintLoad(fp_dir, c_fp_name)
    fp.SetReference(ref)
    fp.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(x), pcbnew.FromMM(y)))
    board.Add(fp)
    return fp

def run():
    board = pcbnew.LoadBoard("calculator.kicad_pcb")

    # 1. Delete old J1 and old capacitors C10-C12
    j1_old = board.FindFootprintByReference("J1")
    if j1_old:
        # Save position to reuse for new J1
        j1_pos = j1_old.GetPosition()
        j1_rot = j1_old.GetOrientation()
        board.Remove(j1_old)
    else:
        # Default fallback
        j1_pos = pcbnew.VECTOR2I(pcbnew.FromMM(45), pcbnew.FromMM(-110.5))
        j1_rot = 0
    
    for c_ref in ["C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17"]:
        c_old = board.FindFootprintByReference(c_ref)
        if c_old:
            board.Remove(c_old)

    # 2. Add new 28-pin J1 (Hirose FH12 28S 0.5mm is compatible with ER-CON28HB-1)
    j1_dir = "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints/Connector_FFC-FPC.pretty"
    j1_name = "Hirose_FH12-28S-0.5SH_1x28-1MP_P0.50mm_Horizontal"
    try:
        j1 = pcbnew.FootprintLoad(j1_dir, j1_name)
    except Exception as e:
        print(f"Failed to load Hirose 28-pin footprint: {e}")
        sys.exit(1)
        
    j1.SetReference("J1")
    j1.SetPosition(j1_pos)
    j1.SetOrientation(j1_rot)
    board.Add(j1)

    # 3. Add 8 Capacitors for ST7565/SPLC502 Charge Pump
    # Place them in a row above J1 (Y = -113 or so)
    # J1 is around X=45. The FPC is about 20mm wide. So X from 35 to 55.
    c_refs = ["C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17"]
    start_x = pcbnew.ToMM(j1_pos.x) - 10
    start_y = pcbnew.ToMM(j1_pos.y) - 4
    caps = {}
    for i, ref in enumerate(c_refs):
        caps[ref] = add_cap(board, ref, start_x + (i * 2.5), start_y)

    # 4. Wire the nets
    # SPI Pins from Pico:
    net_cs = get_or_create_net(board, "Net-(J1-Pad2)")
    net_rst = get_or_create_net(board, "Net-(J1-Pad3)")
    net_a0 = get_or_create_net(board, "Net-(J1-Pad4)")
    net_sck = get_or_create_net(board, "Net-(J1-Pad13)")
    net_mosi = get_or_create_net(board, "Net-(J1-Pad14)")
    
    net_3v3 = get_or_create_net(board, "+3V3")
    net_gnd = get_or_create_net(board, "GND")
    
    # Charge Pump Nets:
    net_vout = get_or_create_net(board, "Net-(J1-Pad17)")
    net_cap1n = get_or_create_net(board, "Net-(J1-Pad18)")
    net_cap1p = get_or_create_net(board, "Net-(J1-Pad19)")
    net_cap2n = get_or_create_net(board, "Net-(J1-Pad20)")
    net_cap2p = get_or_create_net(board, "Net-(J1-Pad21)")
    net_v1 = get_or_create_net(board, "Net-(J1-Pad22)")
    net_v2 = get_or_create_net(board, "Net-(J1-Pad23)")
    net_v3 = get_or_create_net(board, "Net-(J1-Pad24)")
    net_v4 = get_or_create_net(board, "Net-(J1-Pad25)")
    net_v0 = get_or_create_net(board, "Net-(J1-Pad26)")

    def connect(fp, pad_num, net):
        pad = fp.FindPadByNumber(str(pad_num))
        if pad:
            pad.SetNet(net)

    # Connect J1 Signal Pads
    connect(j1, 2, net_cs)
    connect(j1, 3, net_rst)
    connect(j1, 4, net_a0)
    connect(j1, 5, net_gnd) # WR (RD/WR) to GND in Serial
    connect(j1, 6, net_gnd) # RD (E) to GND in Serial
    connect(j1, 13, net_sck) # DB6 (SCL)
    connect(j1, 14, net_mosi) # DB7 (SI)
    connect(j1, 15, net_3v3) # VDD
    connect(j1, 16, net_gnd) # VSS
    
    # Connect J1 Charge Pump Pads
    connect(j1, 17, net_vout)
    connect(j1, 18, net_cap1n)
    connect(j1, 19, net_cap1p)
    connect(j1, 20, net_cap2n)
    connect(j1, 21, net_cap2p)
    connect(j1, 22, net_v1)
    connect(j1, 23, net_v2)
    connect(j1, 24, net_v3)
    connect(j1, 25, net_v4)
    connect(j1, 26, net_v0)
    
    # Connect Control Pins
    connect(j1, 27, net_gnd) # C86 = 8080 (or just GND for SPI)
    connect(j1, 28, net_gnd) # P/S = Serial

    # Connect Capacitors
    # C10: CAP1- to CAP1+
    connect(caps["C10"], 1, net_cap1n)
    connect(caps["C10"], 2, net_cap1p)
    
    # C11: CAP2- to CAP2+
    connect(caps["C11"], 1, net_cap2n)
    connect(caps["C11"], 2, net_cap2p)

    # C12: VOUT to GND
    connect(caps["C12"], 1, net_vout)
    connect(caps["C12"], 2, net_gnd)
    
    # C13: V1 to GND
    connect(caps["C13"], 1, net_v1)
    connect(caps["C13"], 2, net_gnd)
    
    # C14: V2 to GND
    connect(caps["C14"], 1, net_v2)
    connect(caps["C14"], 2, net_gnd)
    
    # C15: V3 to GND
    connect(caps["C15"], 1, net_v3)
    connect(caps["C15"], 2, net_gnd)
    
    # C16: V4 to GND
    connect(caps["C16"], 1, net_v4)
    connect(caps["C16"], 2, net_gnd)
    
    # C17: V0 to GND
    connect(caps["C17"], 1, net_v0)
    connect(caps["C17"], 2, net_gnd)

    # Connect Pico Pads
    pico = board.FindFootprintByReference("U1")
    if pico:
        connect(pico, 22, net_cs)    # GPIO 17
        connect(pico, 26, net_rst)   # GPIO 20
        connect(pico, 27, net_a0)    # GPIO 21
        connect(pico, 24, net_sck)   # GPIO 18
        connect(pico, 25, net_mosi)  # GPIO 19

    # Clear old routing
    for t in board.GetTracks():
        board.Remove(t)

    pcbnew.SaveBoard("calculator.kicad_pcb", board)
    print("Updated J1 footprint to 28-pin and configured charge pump!")

if __name__ == "__main__":
    run()
