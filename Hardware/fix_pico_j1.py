import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Move MCU1
mcu = board.FindFootprintByReference('MCU1')
if mcu:
    mcu.SetPosition(pcbnew.VECTOR2I(int(23.0 * 1e6), int(-110.5 * 1e6)))
    mcu.SetOrientation(pcbnew.EDA_ANGLE(270.0, pcbnew.DEGREES_T))
    if mcu.GetLayer() == pcbnew.F_Cu:
        mcu.Flip(mcu.GetPosition(), False)

# Move J1
j1 = board.FindFootprintByReference('J1')
if j1:
    # Place J1 right next to the slot on the back
    j1.SetPosition(pcbnew.VECTOR2I(int(45.0 * 1e6), int(-92.0 * 1e6)))
    # Ensure it's on B_Cu
    if j1.GetLayer() == pcbnew.F_Cu:
        j1.Flip(j1.GetPosition(), False)

for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard("calculator.kicad_pcb", board)
