import sys
import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

# Find C10, C11, C12
found = {"C10": [], "C11": [], "C12": []}
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref in found:
        found[ref].append(fp)

# Keep the first one, delete the rest
for ref, fps in found.items():
    print(f"Found {len(fps)} of {ref}")
    for fp in fps[1:]:
        board.Remove(fp)

c10 = found["C10"][0]
c11 = found["C11"][0]
c12 = found["C12"][0]

# Move them
c10.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(35), pcbnew.FromMM(-92)))
c11.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(45), pcbnew.FromMM(-96)))
c12.SetPosition(pcbnew.VECTOR2I(pcbnew.FromMM(55), pcbnew.FromMM(-92)))

print("Moved caps", flush=True)

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
    j1.FindPadByNumber("1").SetNetCode(net_cs.GetNetCode())
    j1.FindPadByNumber("2").SetNetCode(net_rst.GetNetCode())
    j1.FindPadByNumber("3").SetNetCode(net_a0.GetNetCode())
    j1.FindPadByNumber("4").SetNetCode(net_sck.GetNetCode())
    j1.FindPadByNumber("5").SetNetCode(net_mosi.GetNetCode())
    j1.FindPadByNumber("6").SetNetCode(net_3v3.GetNetCode())
    j1.FindPadByNumber("7").SetNetCode(net_gnd.GetNetCode())
    j1.FindPadByNumber("8").SetNetCode(net_v0.GetNetCode())
    j1.FindPadByNumber("9").SetNetCode(net_xv0.GetNetCode())
    j1.FindPadByNumber("10").SetNetCode(net_vg.GetNetCode())

mcu = board.FindFootprintByReference("MCU1")
if mcu:
    p22 = mcu.FindPadByNumber("22")
    if p22: p22.SetNetCode(net_cs.GetNetCode())
    p26 = mcu.FindPadByNumber("26")
    if p26: p26.SetNetCode(net_rst.GetNetCode())
    p27 = mcu.FindPadByNumber("27")
    if p27: p27.SetNetCode(net_a0.GetNetCode())
    p24 = mcu.FindPadByNumber("24")
    if p24: p24.SetNetCode(net_sck.GetNetCode())
    p25 = mcu.FindPadByNumber("25")
    if p25: p25.SetNetCode(net_mosi.GetNetCode())
    gnd_pads = ["18", "23", "28", "33", "38"]
    for gp in gnd_pads:
        pad = mcu.FindPadByNumber(gp)
        if pad: pad.SetNetCode(net_gnd.GetNetCode())
    p36 = mcu.FindPadByNumber("36")
    if p36: p36.SetNetCode(net_3v3.GetNetCode())

c10.FindPadByNumber("1").SetNetCode(net_v0.GetNetCode())
c10.FindPadByNumber("2").SetNetCode(net_gnd.GetNetCode())
c11.FindPadByNumber("1").SetNetCode(net_xv0.GetNetCode())
c11.FindPadByNumber("2").SetNetCode(net_gnd.GetNetCode())
c12.FindPadByNumber("1").SetNetCode(net_vg.GetNetCode())
c12.FindPadByNumber("2").SetNetCode(net_gnd.GetNetCode())

for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
print("SUCCESS!", flush=True)
