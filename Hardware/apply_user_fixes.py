import sys
import os
import pcbnew
import math

def run():
    import wx
    app = wx.App(False)
    board = pcbnew.LoadBoard('calculator.kicad_pcb')

    # 1. Remove mounting holes
    for fp in board.GetFootprints():
        if 'MountingHole' in fp.GetFPID().GetLibItemName().c_str():
            board.Remove(fp)

    # 2. Update texts
    for dwg in board.GetDrawings():
        if isinstance(dwg, pcbnew.PCB_TEXT):
            if 'WatchCalc 32' in dwg.GetText():
                dwg.SetText('StackCalc 32')
            if 'Calc32' in dwg.GetText():
                dwg.SetText('StackCalc 32')

    # 3. Setup exactly 70.65 x 143.15 mm board outline
    target_w = 70.65
    target_h = 143.15
    # Let's say top left is at X=10.0, Y=-150.0
    x_min = 10.0
    y_min = -150.0
    x_max = x_min + target_w
    y_max = y_min + target_h

    # First, delete old Edge.Cuts
    edges = [d for d in board.GetDrawings() if d.GetLayer() == pcbnew.Edge_Cuts]
    for d in edges:
        board.Remove(d)

    # Create new Edge.Cuts rectangle
    def add_line(x1, y1, x2, y2):
        seg = pcbnew.PCB_SHAPE(board, pcbnew.SHAPE_T_SEGMENT)
        seg.SetLayer(pcbnew.Edge_Cuts)
        seg.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
        seg.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
        seg.SetWidth(int(0.1*1e6))
        board.Add(seg)

    add_line(x_min, y_min, x_max, y_min)
    add_line(x_max, y_min, x_max, y_max)
    add_line(x_max, y_max, x_min, y_max)
    add_line(x_min, y_max, x_min, y_min)

    # 4. Center the components
    # We want to center the buttons in X.
    # What are the current buttons?
    buttons = []
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if ref.startswith('B') or ref.startswith('SOFT'):
            buttons.append(fp)
    
    # Current button bounding box
    min_bx = 99999
    max_bx = -99999
    for b in buttons:
        x = b.GetPosition().x / 1e6
        min_bx = min(min_bx, x)
        max_bx = max(max_bx, x)
    
    current_center_x = (min_bx + max_bx) / 2
    target_center_x = (x_min + x_max) / 2
    shift_x = target_center_x - current_center_x

    # Shift all buttons and display in X
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if ref.startswith('B') or ref.startswith('SOFT') or 'Disp' in ref or 'J1' in ref:
            pos = fp.GetPosition()
            pos.x += int(shift_x * 1e6)
            fp.SetPosition(pos)

    # 5. Move JST and MCU to the top and rotate MCU
    mcu = board.FindFootprintByReference('MCU1')
    if mcu:
        # Rotate to 90 degrees (vertical)
        mcu.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T))
        mcu.SetPosition(pcbnew.VECTOR2I(int((x_min + 12.0)*1e6), int((y_min + 20.0)*1e6)))

    jst = board.FindFootprintByReference('JST1')
    if jst:
        # Move to top right
        jst.SetOrientation(pcbnew.EDA_ANGLE(180.0, pcbnew.DEGREES_T))
        jst.SetPosition(pcbnew.VECTOR2I(int((x_max - 15.0)*1e6), int((y_min + 10.0)*1e6)))

    # 6. Add LCD outline on F.Silkscreen
    # LCD is roughly 62.8 x 42.8
    # Center it on X
    lcd_x1 = target_center_x - 62.8/2
    lcd_x2 = target_center_x + 62.8/2
    lcd_y1 = y_min + 25.0
    lcd_y2 = lcd_y1 + 42.8

    def add_silk_line(x1, y1, x2, y2):
        seg = pcbnew.PCB_SHAPE(board, pcbnew.SHAPE_T_SEGMENT)
        seg.SetLayer(pcbnew.F_Silkscreen)
        seg.SetStart(pcbnew.VECTOR2I(int(x1*1e6), int(y1*1e6)))
        seg.SetEnd(pcbnew.VECTOR2I(int(x2*1e6), int(y2*1e6)))
        seg.SetWidth(int(0.2*1e6))
        board.Add(seg)
    
    add_silk_line(lcd_x1, lcd_y1, lcd_x2, lcd_y1)
    add_silk_line(lcd_x2, lcd_y1, lcd_x2, lcd_y2)
    add_silk_line(lcd_x2, lcd_y2, lcd_x1, lcd_y2)
    add_silk_line(lcd_x1, lcd_y2, lcd_x1, lcd_y1)

    text = pcbnew.PCB_TEXT(board)
    text.SetText('LCD SCREEN')
    text.SetPosition(pcbnew.VECTOR2I(int(target_center_x*1e6), int((lcd_y1 + 21.4)*1e6)))
    text.SetLayer(pcbnew.F_Silkscreen)
    text.SetTextSize(pcbnew.VECTOR2I(int(2*1e6), int(2*1e6)))
    text.SetTextThickness(int(0.3*1e6))
    board.Add(text)

    # 7. Make sure LCD J1 connector is inside the LCD bounds
    j1 = board.FindFootprintByReference('J1')
    if j1:
        # Move J1 slightly above the LCD or aligned with top of LCD
        j1.SetPosition(pcbnew.VECTOR2I(int(target_center_x*1e6), int(lcd_y1*1e6)))

    # 8. Align buttons: shift them down so they start below LCD
    # Let's find the current top-most button Y
    min_by = 99999
    for b in buttons:
        min_by = min(min_by, b.GetPosition().y / 1e6)
    
    # We want the top-most button to be around lcd_y2 + 5.0
    target_by = lcd_y2 + 5.0
    shift_y = target_by - min_by
    for b in buttons:
        pos = b.GetPosition()
        pos.y += int(shift_y * 1e6)
        b.SetPosition(pos)

    pcbnew.SaveBoard('calculator_updated.kicad_pcb', board)
    print("Done applying user fixes. Saved as calculator_updated.kicad_pcb")

if __name__ == '__main__':
    run()
