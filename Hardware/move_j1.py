import wx
app = wx.App(False)
import pcbnew
import sys

board = pcbnew.LoadBoard('calculator.kicad_pcb')
fp = board.FindFootprintByReference('J1')
if not fp:
    print("Could not find J1")
    sys.exit(1)

pos = fp.GetPosition()
print(f"Old J1 position: {pos.x/1e6}, {pos.y/1e6}")
pos.y = int(-127.54 * 1e6)
fp.SetPosition(pos)
print(f"New J1 position: {pos.x/1e6}, {pos.y/1e6}")

# Let's also move the bottom edge cuts up to Y = -16.0 to shorten the PCB!
# We will find any graphic line on Edge.Cuts that is near Y = -11.925
moved_edges = 0
for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.Edge_Cuts:
        if isinstance(dwg, pcbnew.PCB_SHAPE):
            # If it's a line segment at the bottom
            if dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
                start = dwg.GetStart()
                end = dwg.GetEnd()
                # If it's horizontal and at the bottom
                if abs(start.y - end.y) < 1000 and start.y > -15 * 1e6:
                    start.y = int(-16.0 * 1e6)
                    end.y = int(-16.0 * 1e6)
                    dwg.SetStart(start)
                    dwg.SetEnd(end)
                    moved_edges += 1
                # If it's vertical and ends at the bottom
                elif start.y > -15 * 1e6:
                    start.y = int(-16.0 * 1e6)
                    dwg.SetStart(start)
                    moved_edges += 1
                elif end.y > -15 * 1e6:
                    end.y = int(-16.0 * 1e6)
                    dwg.SetEnd(end)
                    moved_edges += 1

print(f"Moved {moved_edges} edge cut segments.")
pcbnew.SaveBoard('calculator.kicad_pcb', board)
