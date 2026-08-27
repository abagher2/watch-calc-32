import wx
app = wx.App(False)
import pcbnew
import math

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# 1. Move J1 down by 2.46mm (to Y = -127.54)
fp_j1 = board.FindFootprintByReference('J1')
if fp_j1:
    pos = fp_j1.GetPosition()
    pos.y = int(-127.54 * 1e6)
    fp_j1.SetPosition(pos)
    print("Moved J1")

# 2. Modify Edge.Cuts
top_offset = int(-8.625 * 1e6)
bot_offset = int(-4.075 * 1e6)
top_y_thresh = -140 * 1e6
bot_y_thresh = -20 * 1e6

for dwg in board.GetDrawings():
    if dwg.GetLayer() == pcbnew.Edge_Cuts:
        if isinstance(dwg, pcbnew.PCB_SHAPE):
            bb = dwg.GetBoundingBox()
            cy = bb.Centre().y
            
            if dwg.GetShape() == pcbnew.SHAPE_T_SEGMENT:
                start = dwg.GetStart()
                end = dwg.GetEnd()
                
                # Top Edge
                if cy < top_y_thresh and abs(start.y - end.y) < 1000:
                    dwg.Move(pcbnew.VECTOR2I(0, top_offset))
                    print("Moved top edge")
                # Bottom Edge
                elif cy > bot_y_thresh and abs(start.y - end.y) < 1000:
                    dwg.Move(pcbnew.VECTOR2I(0, bot_offset))
                    print("Moved bottom edge")
                # Left/Right Edges
                elif abs(start.x - end.x) < 1000:
                    # They span from top to bottom
                    if start.y < end.y:
                        start.y += top_offset
                        end.y += bot_offset
                    else:
                        start.y += bot_offset
                        end.y += top_offset
                    dwg.SetStart(start)
                    dwg.SetEnd(end)
                    print("Resized vertical edge")
            
            elif dwg.GetShape() == pcbnew.SHAPE_T_ARC:
                if cy < top_y_thresh:
                    dwg.Move(pcbnew.VECTOR2I(0, top_offset))
                    print("Moved top arc")
                elif cy > bot_y_thresh:
                    dwg.Move(pcbnew.VECTOR2I(0, bot_offset))
                    print("Moved bottom arc")

pcbnew.SaveBoard('calculator.kicad_pcb', board)
