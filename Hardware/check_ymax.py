import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
print(f"y_max = {bbox.GetBottom()/1e6}")
