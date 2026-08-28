import pcbnew
import sys
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
fp = board.FindFootprintByReference("MCU1")
if fp:
    print(f"MCU1 pos: {fp.GetPosition().x / 1e6}, {fp.GetPosition().y / 1e6}")
    print(f"MCU1 rot: {fp.GetOrientationDegrees()}")
else:
    print("MCU1 not found")

disp_fp = board.FindFootprintByReference("J1")
if disp_fp:
    print(f"J1 pos: {disp_fp.GetPosition().x / 1e6}, {disp_fp.GetPosition().y / 1e6}")
    print(f"J1 rot: {disp_fp.GetOrientationDegrees()}")

bbox = board.GetBoardEdgesBoundingBox()
print(f"Bbox: X {bbox.GetX()/1e6} to {bbox.GetRight()/1e6}, width: {bbox.GetWidth()/1e6}")
print(f"Bbox: Y {bbox.GetY()/1e6} to {bbox.GetBottom()/1e6}, height: {bbox.GetHeight()/1e6}")
