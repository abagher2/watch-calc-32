import sys
import pcbnew

board = pcbnew.LoadBoard("output/pcbs/calculator.kicad_pcb")
connectivity = board.GetConnectivity()
unconnected = connectivity.GetUnconnectedEdges()
for edge in unconnected:
    print(f"Net {edge.GetNet()} from ({edge.GetSource().x/1e6}, {edge.GetSource().y/1e6}) to ({edge.GetTarget().x/1e6}, {edge.GetTarget().y/1e6})")
