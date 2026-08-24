import pcbnew
import sys
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for zone in list(board.Zones()):
    board.Remove(zone)
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb_nozones", board)
