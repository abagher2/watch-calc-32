import pcbnew
import sys
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
items_deleted = 0
for track in list(board.GetTracks()):
    if track.GetNetCode() == 0:
        board.Remove(track)
        items_deleted += 1
print(f"Deleted {items_deleted} no-net tracks/vias")
pcbnew.SaveBoard("Hardware/calculator.kicad_pcb", board)
