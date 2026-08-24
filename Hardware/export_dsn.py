import sys
import pcbnew
import os

def export_dsn(kicad_pcb_path, dsn_path):
    board = pcbnew.LoadBoard(os.path.abspath(kicad_pcb_path))
    print(f"Exporting Specctra DSN to {os.path.abspath(dsn_path)}...")
    success = pcbnew.ExportSpecctraDSN(board, os.path.abspath(dsn_path))
    if not success:
        print("Failed to export DSN file.")
        sys.exit(1)

if __name__ == "__main__":
    export_dsn(sys.argv[1], sys.argv[2])
