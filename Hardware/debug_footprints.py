import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
for f in board.GetFootprints():
    ref = f.GetReference()
    pos = f.GetPosition()
    print(f"{ref}: {pos.x / 1e6}, {pos.y / 1e6}")
