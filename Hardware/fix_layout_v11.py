import sys
import pcbnew

board = pcbnew.LoadBoard('calculator.kicad_pcb')
drawings = list(board.GetDrawings())

# 1. Clean up ALL messy overlapping texts
for d in drawings:
    if isinstance(d, pcbnew.PCB_TEXT):
        txt = d.GetText()
        if any(word in txt for word in ["StackCalc", "Calc32", "Calc 32", "SHARP", "LS027", "BATTERY", "JST", "BOSS", "LCD Screen Area"]):
            board.Remove(d)

def add_text(board, text, x, y, layer, mirrored=False):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(text)
    t.SetPosition(pcbnew.VECTOR2I(int(x*1e6), int(y*1e6)))
    t.SetLayer(layer)
    t.SetTextThickness(int(0.2*1e6))
    t.SetTextSize(pcbnew.VECTOR2I(int(1.5*1e6), int(1.5*1e6)))
    if mirrored: t.SetMirrored(True)
    board.Add(t)

# 2. Add clean, properly spaced labels at the top
add_text(board, "StackCalc 32", 45.0, -128.0, pcbnew.F_SilkS)
add_text(board, "SHARP LS027B7DH01", 45.0, -124.0, pcbnew.F_SilkS)
add_text(board, "LCD Screen Area", 45.0, -120.0, pcbnew.F_SilkS)

# 3. Add prominent JST label next to the connector
# The JST is at X=36.0, Y=-110.5 on the BACK.
add_text(board, "JST (BATTERY) ->", 36.0, -105.0, pcbnew.B_SilkS, mirrored=True)
add_text(board, "JST (ON BACK)", 36.0, -105.0, pcbnew.F_SilkS)

# 4. Add prominent CR2032 Battery label on the Battery pocket outline
# The battery box is X = 50.8 to 74.8, Y = -23.9 to -5.4
add_text(board, "CR2032 BATTERY POCKET", 62.8, -14.65, pcbnew.B_SilkS, mirrored=True)
add_text(board, "CR2032 BATTERY (BACK)", 62.8, -14.65, pcbnew.F_SilkS)

# 5. Add Boss labels back
add_text(board, "BOSS", 17.6, -5.5, pcbnew.B_SilkS, mirrored=True)
add_text(board, "BOSS", 75.6, -5.5, pcbnew.B_SilkS, mirrored=True)

# Remove ALL tracks to ensure a clean freerouting run
for t in board.GetTracks():
    board.Remove(t)

pcbnew.SaveBoard('calculator.kicad_pcb', board)
print("Cleaned up labels, added prominent battery/JST labels, and saved!")
