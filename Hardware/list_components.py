import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard("calculator.kicad_pcb")
for fp in board.GetFootprints():
    print(fp.GetReference())
