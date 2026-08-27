import wx
app = wx.App()
import pcbnew
board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
y_max = board.GetBoardEdgesBoundingBox().GetBottom() / 1e6
for fp in board.GetFootprints():
    if fp.GetReference().startswith("SOFT"):
        sy = y_max - fp.GetPosition().y / 1e6
        print(f"{fp.GetReference()}: sy={sy}")
