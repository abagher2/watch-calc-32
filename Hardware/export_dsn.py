import sys
import pcbnew

def export_dsn(kicad_pcb_path, dsn_path):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    print(f"Exporting Specctra DSN to {dsn_path}...")
    success = pcbnew.ExportSpecctraDSN(board, dsn_path)
    if not success:
        print("Failed to export DSN file.")
        sys.exit(1)

if __name__ == "__main__":
    export_dsn(sys.argv[1], sys.argv[2])
