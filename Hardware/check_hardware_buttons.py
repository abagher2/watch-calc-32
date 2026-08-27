import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard('calculator.kicad_pcb')
y_max = board.GetBoardEdgesBoundingBox().GetBottom() / 1e6
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if ref.startswith("B") and len(ref) <= 3 and ref[1:].isdigit():
        sy = y_max - fp.GetPosition().y / 1e6
        print(f"{ref}: sy={sy}")
