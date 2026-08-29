import pcbnew
import sys

board_file = sys.argv[1]
board = pcbnew.LoadBoard(board_file)

caps_to_remove = []
for fp in board.Footprints():
    ref = fp.GetReference()
    if ref.startswith("C"):
        if ref in ["C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17"]:
            caps_to_remove.append(fp)

for fp in caps_to_remove:
    board.Remove(fp)

pcbnew.SaveBoard(board_file, board)
print(f"Removed {len(caps_to_remove)} old capacitors.")
