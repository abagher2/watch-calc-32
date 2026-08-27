import pcbnew
import math

def add_slot(board, x1, y1, x2, y2, layer=pcbnew.Edge_Cuts, width=0.2):
    line1 = pcbnew.PCB_SHAPE(board)
    line1.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line1.SetStart(pcbnew.VECTOR2I(int(x1 * 1e6), int(y1 * 1e6)))
    line1.SetEnd(pcbnew.VECTOR2I(int(x2 * 1e6), int(y1 * 1e6)))
    line1.SetLayer(layer)
    line1.SetWidth(int(width * 1e6))
    board.Add(line1)
    
    line2 = pcbnew.PCB_SHAPE(board)
    line2.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line2.SetStart(pcbnew.VECTOR2I(int(x2 * 1e6), int(y1 * 1e6)))
    line2.SetEnd(pcbnew.VECTOR2I(int(x2 * 1e6), int(y2 * 1e6)))
    line2.SetLayer(layer)
    line2.SetWidth(int(width * 1e6))
    board.Add(line2)
    
    line3 = pcbnew.PCB_SHAPE(board)
    line3.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line3.SetStart(pcbnew.VECTOR2I(int(x2 * 1e6), int(y2 * 1e6)))
    line3.SetEnd(pcbnew.VECTOR2I(int(x1 * 1e6), int(y2 * 1e6)))
    line3.SetLayer(layer)
    line3.SetWidth(int(width * 1e6))
    board.Add(line3)
    
    line4 = pcbnew.PCB_SHAPE(board)
    line4.SetShape(pcbnew.SHAPE_T_SEGMENT)
    line4.SetStart(pcbnew.VECTOR2I(int(x1 * 1e6), int(y2 * 1e6)))
    line4.SetEnd(pcbnew.VECTOR2I(int(x1 * 1e6), int(y1 * 1e6)))
    line4.SetLayer(layer)
    line4.SetWidth(int(width * 1e6))
    board.Add(line4)

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# 1. Add FPC Pass-through Slot
slot_x_min = 45.0 - 8.0
slot_x_max = 45.0 + 8.0
slot_y_min = -88.0
slot_y_max = -86.5
add_slot(board, slot_x_min, slot_y_min, slot_x_max, slot_y_max)
print("Added 16x1.5mm FPC slot at Y=-87.25")

# 2. Move J1 to Bottom Layer
j1 = board.FindFootprintByReference("J1")
if j1:
    # If it is currently on the Front layer, flip it to the Back layer
    if j1.GetLayer() == pcbnew.F_Cu:
        j1.Flip(j1.GetPosition(), False)
    
    # Position it safely on the back, above the slot
    # The ribbon will fold up from Y=-87 towards Y=-105
    j1.SetPosition(pcbnew.VECTOR2I(int(45.0 * 1e6), int(-105.0 * 1e6)))
    
    # Optional: Orient it so the cable enters from the bottom
    j1.SetOrientation(pcbnew.EDA_ANGLE(0, pcbnew.DEGREES_T))
    print("Moved J1 to Bottom Layer at X=45.0, Y=-105.0")
else:
    print("Warning: Could not find J1")

# Remove ALL tracks to ensure a clean freerouting run since J1 moved!
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Saved calculator.kicad_pcb")
