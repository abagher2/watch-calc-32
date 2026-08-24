import sys
import pcbnew
board = pcbnew.LoadBoard("output/pcbs/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_max = bbox.GetBottom() / 1e6
print(f"PCB x_min: {x_min}, y_max: {y_max}")
