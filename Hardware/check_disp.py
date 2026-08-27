import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard("output/pcbs/calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_max = bbox.GetBottom() / 1e6
for fp in board.GetFootprints():
    if "Disp" in fp.GetReference() or "OLED" in fp.GetReference():
        px = (fp.GetPosition().x / 1e6) - x_min
        py = y_max - (fp.GetPosition().y / 1e6)
        print(f"{fp.GetReference()} pos: PCB_x={fp.GetPosition().x/1e6}, PCB_y={fp.GetPosition().y/1e6} | Scad_x={px}, Scad_y={py}")
