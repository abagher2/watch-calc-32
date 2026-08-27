import sys
import re
import pcbnew
import wx
app = wx.App(False)

board = pcbnew.LoadBoard('calculator.kicad_pcb')

# 1. Edge.Cuts setup: 70.65 x 143.15
x_min = 10.0
x_max = 80.65
y_min = -158.15
y_max = -15.0

# 2. MCU1: vertical, center left, flush with back
mcu = board.FindFootprintByReference('MCU1')
if mcu:
    mcu.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T)) # vertical
    mcu.SetPosition(pcbnew.VECTOR2I(int((x_min + 12.0)*1e6), int(-90.0*1e6)))

# 3. JST1: closest to the top, center (tapered chassis tallest part)
jst = board.FindFootprintByReference('JST1')
if jst:
    jst.SetOrientation(pcbnew.EDA_ANGLE(0.0, pcbnew.DEGREES_T))
    jst.SetPosition(pcbnew.VECTOR2I(int(((x_min + x_max)/2)*1e6), int((y_min + 6.0)*1e6)))

# 4. Buttons: Scale vertically to avoid LCD
buttons = [fp for fp in board.GetFootprints() if fp.GetReference().startswith('B') or fp.GetReference().startswith('SOFT')]
if buttons:
    orig_min_y = min(b.GetPosition().y/1e6 for b in buttons)
    orig_max_y = max(b.GetPosition().y/1e6 for b in buttons)
    
    # We want them from -82.0 to -22.0
    t = -82.0
    b = -22.0
    
    for fp in buttons:
        pos = fp.GetPosition()
        y = pos.y / 1e6
        if abs(orig_max_y - orig_min_y) > 0.1:
            new_y = t + (y - orig_min_y) * (b - t) / (orig_max_y - orig_min_y)
        else:
            new_y = t
        pos.y = int(new_y * 1e6)
        fp.SetPosition(pos)

# 5. Remove mounting holes
to_remove = []
for fp in board.GetFootprints():
    if 'MountingHole' in fp.GetFPID().GetLibItemName().c_str():
        to_remove.append(fp)
for fp in to_remove:
    board.Remove(fp)

# Save board (we will fix Edge.Cuts with regex since pcbnew API for drawing is annoying)
pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Footprints updated.")

# Fix Edge.Cuts textually
with open('calculator.kicad_pcb', 'r') as f:
    content = f.read()

content = re.sub(r'\(gr_line\s*\(start.*?\)\s*\(layer "Edge\.Cuts"\).*?\)\s*\)\n', '', content, flags=re.DOTALL)
content = re.sub(r'\(gr_arc\s*\(start.*?\)\s*\(layer "Edge\.Cuts"\).*?\)\s*\)\n', '', content, flags=re.DOTALL)

# Also rename WatchCalc 32
content = content.replace('WatchCalc 32', 'StackCalc 32')

new_edges = f"""
  (gr_line
    (start {x_min} {y_min})
    (end {x_max} {y_min})
    (stroke (width 0.15) (type solid))
    (layer "Edge.Cuts")
    (uuid "00000000-0000-0000-0000-000000000001")
  )
  (gr_line
    (start {x_max} {y_min})
    (end {x_max} {y_max})
    (stroke (width 0.15) (type solid))
    (layer "Edge.Cuts")
    (uuid "00000000-0000-0000-0000-000000000002")
  )
  (gr_line
    (start {x_max} {y_max})
    (end {x_min} {y_max})
    (stroke (width 0.15) (type solid))
    (layer "Edge.Cuts")
    (uuid "00000000-0000-0000-0000-000000000003")
  )
  (gr_line
    (start {x_min} {y_max})
    (end {x_min} {y_min})
    (stroke (width 0.15) (type solid))
    (layer "Edge.Cuts")
    (uuid "00000000-0000-0000-0000-000000000004")
  )
"""
content = content.replace('\n)', new_edges + '\n)')

with open('calculator.kicad_pcb', 'w') as f:
    f.write(content)
print("Edge cuts and text updated.")
