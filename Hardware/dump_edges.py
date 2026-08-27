import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard('calculator.kicad_pcb')
for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.Edge_Cuts:
        if isinstance(dwg, pcbnew.PCB_SHAPE):
            print(f"Shape: {dwg.GetShape()}, Start: {dwg.GetStart().x/1e6}, {dwg.GetStart().y/1e6} End: {dwg.GetEnd().x/1e6}, {dwg.GetEnd().y/1e6}")
