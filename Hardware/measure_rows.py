import wx
app = wx.App(False)
import pcbnew
board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
y_max = board.GetBoardEdgesBoundingBox().GetBottom() / 1e6
rows = set()
for fp in board.GetFootprints():
    ref = fp.GetReference()
    if (ref.startswith("SOFT") or ref.startswith("B")) and len(ref) <= 5:
        sy = y_max - fp.GetPosition().y / 1e6
        rows.add(round(sy, 2))
print(sorted(list(rows), reverse=True))
