import sys
import pcbnew

board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")

UNIT_TO_NM = int(1e6) # Kicad uses nm

def add_track(netname, x1, y1, x2, y2, layer):
    netcode = board.GetNetcodeFromNetname(netname)
    track = pcbnew.PCB_TRACK(board)
    track.SetStart(pcbnew.VECTOR2I(int(x1 * UNIT_TO_NM), int(y1 * UNIT_TO_NM)))
    track.SetEnd(pcbnew.VECTOR2I(int(x2 * UNIT_TO_NM), int(y2 * UNIT_TO_NM)))
    track.SetWidth(pcbnew.FromMM(0.15))
    track.SetLayer(layer)
    track.SetNetCode(netcode)
    board.Add(track)
    
def add_via(netname, x, y):
    netcode = board.GetNetcodeFromNetname(netname)
    via = pcbnew.PCB_VIA(board)
    via.SetPosition(pcbnew.VECTOR2I(int(x * UNIT_TO_NM), int(y * UNIT_TO_NM)))
    via.SetNetCode(netcode)
    via.SetWidth(pcbnew.FromMM(0.40))
    via.SetDrill(pcbnew.FromMM(0.20))
    via.SetLayerPair(pcbnew.F_Cu, pcbnew.B_Cu)
    board.Add(via)

# Route 1: (34.5800 mm, -125.9250 mm) on B.Cu to ... where? 
# Wait, I don't know exactly where the pad is, but maybe I can just draw a track between the two pads?
# I'll just save this for now.
