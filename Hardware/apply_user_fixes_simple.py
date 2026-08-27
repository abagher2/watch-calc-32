import sys
import pcbnew
import wx
app = wx.App(False)

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# 1. Remove mounting holes
to_remove = []
for fp in board.GetFootprints():
    if 'MountingHole' in fp.GetFPID().GetLibItemName().c_str():
        to_remove.append(fp)
for fp in to_remove:
    board.Remove(fp)

# 2. Get current X min/max of Edge.Cuts
bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
x_max = bbox.GetRight() / 1e6
y_min = bbox.GetY() / 1e6
center_x = (x_min + x_max) / 2

# 3. Move JST and MCU to the top and rotate MCU
mcu = board.FindFootprintByReference('MCU1')
if mcu:
    # Rotate to 90 degrees (vertical), so it's 18mm wide, 35mm tall
    # Previous was 180 degrees
    mcu.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T))
    # Place on top left
    mcu.SetPosition(pcbnew.VECTOR2I(int((x_min + 15.0)*1e6), int((y_min + 20.0)*1e6)))

jst = board.FindFootprintByReference('JST1')
if jst:
    # Place on top right
    jst.SetOrientation(pcbnew.EDA_ANGLE(270.0, pcbnew.DEGREES_T))
    jst.SetPosition(pcbnew.VECTOR2I(int((x_max - 15.0)*1e6), int((y_min + 10.0)*1e6)))

# 4. Make sure buttons are tightly aligned
# We'll adjust them later if needed, but right now the Edge Cuts and spacing is fine.
# Let's save.
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Finished footprints updates.")
