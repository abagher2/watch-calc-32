import pcbnew
board = pcbnew.LoadBoard("Hardware/calculator.kicad_pcb")
for fp in board.GetFootprints():
    if "MCU1" in fp.GetReference():
        print(f"Pico at X={fp.GetPosition().x/1e6}, Y={fp.GetPosition().y/1e6}")
