import sys
import pcbnew

board = pcbnew.LoadBoard(sys.argv[1])
try:
    pcbnew.ExportSpecctraDSN(board, sys.argv[2])
    print("Exported DSN successfully!")
except Exception as e:
    print(f"Failed to export DSN: {e}")
