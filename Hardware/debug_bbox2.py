import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
bbox = board.GetBoardEdgesBoundingBox()
print(f"bbox X: {bbox.GetX() / 1e6}, Width: {bbox.GetWidth() / 1e6}")
print(f"bbox Y: {bbox.GetY() / 1e6}, Height: {bbox.GetHeight() / 1e6}")
print(f"bbox Right: {bbox.GetRight() / 1e6}")
print(f"bbox Bottom: {bbox.GetBottom() / 1e6}")
