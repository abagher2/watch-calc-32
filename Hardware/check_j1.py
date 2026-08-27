import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_max = bbox.GetBottom() / 1e6
j1_fp = board.FindFootprintByReference('J1')
if j1_fp:
    px = (j1_fp.GetPosition().x / 1e6) - x_min
    py = y_max - (j1_fp.GetPosition().y / 1e6)
    print(f"J1 Scad_y = {py}")
