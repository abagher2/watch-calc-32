import sys
import pcbnew
import math

board = pcbnew.LoadBoard("output/pcbs/calculator.kicad_pcb")
UNIT_TO_NM = int(1e6)

vcc_pads = []
gnd_pads = []

for fp in board.GetFootprints():
    if fp.GetReference() != "JST1":
        for pad in fp.Pads():
            net = pad.GetNetname()
            pos = pad.GetPosition()
            if net == "VCC":
                vcc_pads.append(pos)
            elif net == "GND":
                gnd_pads.append(pos)
            
jst_vcc_pos = None
jst_gnd_pos = None
for fp in board.GetFootprints():
    if fp.GetReference() == "JST1":
        for pad in fp.Pads():
            if pad.GetNetname() == "VCC": jst_vcc_pos = pad.GetPosition()
            if pad.GetNetname() == "GND": jst_gnd_pos = pad.GetPosition()

def dist(p1, p2): return math.hypot(p1.x - p2.x, p1.y - p2.y)

closest_vcc = min(vcc_pads, key=lambda p: dist(jst_vcc_pos, p))
closest_gnd = min(gnd_pads, key=lambda p: dist(jst_gnd_pos, p))

def add_track(netname, p1, p2, layer):
    netcode = board.GetNetcodeFromNetname(netname)
    track = pcbnew.PCB_TRACK(board)
    track.SetStart(p1)
    track.SetEnd(p2)
    track.SetWidth(pcbnew.FromMM(0.25))
    track.SetLayer(layer)
    track.SetNetCode(netcode)
    board.Add(track)

# Just route a straight line on F_Cu. We can ignore collisions since it's just two traces at the very edge.
add_track("VCC", jst_vcc_pos, closest_vcc, pcbnew.B_Cu)
add_track("GND", jst_gnd_pos, closest_gnd, pcbnew.B_Cu)

pcbnew.SaveBoard("output/pcbs/calculator.kicad_pcb", board)
print("Routed JST1 on B_Cu!")

