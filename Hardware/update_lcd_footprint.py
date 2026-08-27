import pcbnew
import os

board = pcbnew.LoadBoard("calculator.kicad_pcb")

fp_dir = "/Applications/KiCad/KiCad.app/Contents/SharedSupport/footprints/Capacitor_SMD.pretty"
c_fp_name = "C_0402_1005Metric"

def add_cap(ref, x, y):
    fp = pcbnew.FootprintLoad(fp_dir, c_fp_name)
    fp.SetReference(ref)
    fp.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(x), pcbnew.FromMM(y)))
    board.Add(fp)
    return fp

# Create 3 capacitors near J1 (J1 is at X=45, Y=-110.5)
c1 = add_cap("C10", 35, -108)
c2 = add_cap("C11", 45, -108)
c3 = add_cap("C12", 55, -108)

# Find J1 and Pico
j1 = board.FindFootprintByReference("J1")
pico = board.FindFootprintByReference("U1") # Assuming Pico is U1 or similar

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

# Connect J1 Pads
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

# Connect Pico Pads
if pico:
    # Pico physical pins: 
    # CS = GPIO 17 -> Pin 22
    # RST = GPIO 20 -> Pin 26
    # A0 = GPIO 21 -> Pin 27
    # SCK = GPIO 18 -> Pin 24
    # MOSI = GPIO 19 -> Pin 25
    p22 = pico.FindPadByNumber("22")
    if p22: p22.SetNet(net_cs)
    
    p26 = pico.FindPadByNumber("26")
    if p26: p26.SetNet(net_rst)
        
    p27 = pico.FindPadByNumber("27")
    if p27: p27.SetNet(net_a0)
        
    p24 = pico.FindPadByNumber("24")
    if p24: p24.SetNet(net_sck)
        
    p25 = pico.FindPadByNumber("25")
    if p25: p25.SetNet(net_mosi)

# Connect Capacitors
c1.FindPadByNumber("1").SetNet(net_v0)
c1.FindPadByNumber("2").SetNet(net_gnd)

c2.FindPadByNumber("1").SetNet(net_xv0)
c2.FindPadByNumber("2").SetNet(net_gnd)

c3.FindPadByNumber("1").SetNet(net_vg)
c3.FindPadByNumber("2").SetNet(net_gnd)

# Clear old routing
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
print("Updated J1 nets and added C10, C11, C12 for ST7567 charge pump!")
