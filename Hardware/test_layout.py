import pcbnew

board_path = "output/pcbs/calculator.kicad_pcb"
board = pcbnew.LoadBoard(board_path)

bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_max = bbox.GetBottom() / 1e6
y_min = bbox.GetY() / 1e6
print(f"KiCad X_min: {x_min}, Y_min: {y_min}, Y_max: {y_max}")

# Set JST near top right
x_jst = x_min + 62.0
y_jst = -135.0
print(f"JST at KiCad X:{x_jst}, Y:{y_jst}")

# SCAD coordinates:
# SCAD X = KiCad X - x_min = 62.0
# SCAD Y = Y_max - KiCad Y = -8.925 - (-135.0) = 126.075
print(f"JST in SCAD -> X: 62.0, Y: {y_max - y_jst}")

