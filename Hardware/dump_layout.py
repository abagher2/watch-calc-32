import sys
import wx
app = wx.App(False)
import pcbnew
import json

board = pcbnew.LoadBoard("calculator.kicad_pcb")
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_max = bbox.GetBottom() / 1e6

fp_w = 72.0
pcb_width = (bbox.GetRight() - bbox.GetX()) / 1e6
pad_left = (fp_w - pcb_width) / 2
pad_bottom = 12.0

buttons = []
for fp in board.GetFootprints():
    ref = fp.GetReference()
    pos = fp.GetPosition()
    sx  = pos.x / 1e6 - x_min
    sy  = y_max - pos.y / 1e6
    if ref.startswith("SOFT") or (ref.startswith("B") and len(ref) <= 3 and ref[1:].isdigit()):
        ox = fp_w - (pad_left + sx)
        oy = pad_bottom + sy
        buttons.append({"ref": ref, "ox": ox, "oy": oy})

buttons.sort(key=lambda b: -b["oy"])
rows = []
cur_y = buttons[0]["oy"] if buttons else 0
cur_row = []
for b in buttons:
    if abs(b["oy"] - cur_y) > 5:
        cur_row.sort(key=lambda b: -b["ox"]) 
        rows.append(cur_row)
        cur_row = []
        cur_y = b["oy"]
    cur_row.append(b)
if cur_row:
    cur_row.sort(key=lambda b: -b["ox"])
    rows.append(cur_row)

print(json.dumps(rows, indent=2))
