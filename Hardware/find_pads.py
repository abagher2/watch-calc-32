import sys
import pcbnew
import math

board = pcbnew.LoadBoard("output/pcbs/calculator.kicad_pcb")

vbat_pads = []
gnd_pads = []

for fp in board.GetFootprints():
    for pad in fp.Pads():
        net = pad.GetNetname()
        pos = pad.GetPosition()
        x = pos.x / 1e6
        y = pos.y / 1e6
        if net == "+3V3":
            vbat_pads.append((fp.GetReference(), pad.GetName(), x, y))
        elif net == "GND":
            gnd_pads.append((fp.GetReference(), pad.GetName(), x, y))

def dist(p1, p2):
    return math.hypot(p1[2]-p2[2], p1[3]-p2[3])

jst_vbat = [p for p in vbat_pads if p[0] == "JST1"][0]
jst_gnd = [p for p in gnd_pads if p[0] == "JST1"][0]

vbat_pads.remove(jst_vbat)
gnd_pads.remove(jst_gnd)

closest_vbat = min(vbat_pads, key=lambda p: dist(jst_vbat, p))
closest_gnd = min(gnd_pads, key=lambda p: dist(jst_gnd, p))

print(f"JST VBAT: {jst_vbat}")
print(f"Closest VBAT: {closest_vbat}")
print(f"JST GND: {jst_gnd}")
print(f"Closest GND: {closest_gnd}")

