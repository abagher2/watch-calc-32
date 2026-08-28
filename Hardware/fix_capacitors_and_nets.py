import pcbnew
import os

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# 1. Remove ALL existing C10, C11, C12
to_remove = []
for fp in board.GetFootprints():
    if fp.GetReference() in ["C10", "C11", "C12"]:
        to_remove.append(fp)
for fp in to_remove:
    board.Remove(fp)

# 2. Add C10, C11, C12 back ON THE BOTTOM LAYER near J1 (which is at X=45, Y=-92)
fp_dir = "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints/Capacitor_SMD.pretty"
c_fp_name = "C_0402_1005Metric"

def add_cap(ref, x, y):
    fp = pcbnew.FootprintLoad(fp_dir, c_fp_name)
    fp.SetReference(ref)
    fp.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(x), pcbnew.FromMM(y)))
    fp.Flip(fp.GetPosition(), False) # Put them on the back!
    board.Add(fp)
    return fp

c10 = add_cap("C10", 35, -92)
c11 = add_cap("C11", 45, -96)
c12 = add_cap("C12", 55, -92)

# 3. Setup Nets
def get_or_create_net(net_name):
    net = board.FindNet(net_name)
    if net is None:
        net = pcbnew.NETINFO_ITEM(board, net_name)
        board.Add(net)
    return net

net_3v3 = get_or_create_net("+3V3")
net_gnd = get_or_create_net("GND")
net_cs = get_or_create_net("Net-(J1-Pad1)")
net_rst = get_or_create_net("Net-(J1-Pad2)")
net_a0 = get_or_create_net("Net-(J1-Pad3)")
net_sck = get_or_create_net("Net-(J1-Pad4)")
net_mosi = get_or_create_net("Net-(J1-Pad5)")

net_v0 = get_or_create_net("Net-(J1-Pad8)")
net_xv0 = get_or_create_net("Net-(J1-Pad9)")
net_vg = get_or_create_net("Net-(J1-Pad10)")

j1 = board.FindFootprintByReference("J1")
if j1:
    j1.FindPadByNumber("1").SetNet(net_cs)
    j1.FindPadByNumber("2").SetNet(net_rst)
    j1.FindPadByNumber("3").SetNet(net_a0)
    j1.FindPadByNumber("4").SetNet(net_sck)
    j1.FindPadByNumber("5").SetNet(net_mosi)
    j1.FindPadByNumber("6").SetNet(net_3v3)
    j1.FindPadByNumber("7").SetNet(net_gnd)
    j1.FindPadByNumber("8").SetNet(net_v0)
    j1.FindPadByNumber("9").SetNet(net_xv0)
    j1.FindPadByNumber("10").SetNet(net_vg)

# Pico is MCU1
mcu = board.FindFootprintByReference("MCU1")
if mcu:
    p22 = mcu.FindPadByNumber("22")
    if p22: p22.SetNet(net_cs)
    p26 = mcu.FindPadByNumber("26")
    if p26: p26.SetNet(net_rst)
    p27 = mcu.FindPadByNumber("27")
    if p27: p27.SetNet(net_a0)
    p24 = mcu.FindPadByNumber("24")
    if p24: p24.SetNet(net_sck)
    p25 = mcu.FindPadByNumber("25")
    if p25: p25.SetNet(net_mosi)
    
    gnd_pads = ["18", "23", "28", "33", "38"] # Standard pico gnd pins
    for gp in gnd_pads:
        pad = mcu.FindPadByNumber(gp)
        if pad: pad.SetNet(net_gnd)
    p36 = mcu.FindPadByNumber("36") # 3v3 out
    if p36: p36.SetNet(net_3v3)

# Connect Capacitors
c10.FindPadByNumber("1").SetNet(net_v0)
c10.FindPadByNumber("2").SetNet(net_gnd)

c11.FindPadByNumber("1").SetNet(net_xv0)
c11.FindPadByNumber("2").SetNet(net_gnd)

c12.FindPadByNumber("1").SetNet(net_vg)
c12.FindPadByNumber("2").SetNet(net_gnd)

# Clear old routing
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
print("Cleaned up C10/C11/C12 duplicates, re-assigned nets, and wiped tracks.")
