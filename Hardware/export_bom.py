import sys
import csv
import pcbnew

def export_bom(kicad_pcb_path, output_csv):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Designator', 'Value', 'Footprint'])
        
        for fp in board.Footprints():
            ref = fp.GetReference()
            val = fp.GetValue()
            # In KiCad 7, footprint name can be obtained from FPID
            fpid = fp.GetFPID().GetLibItemName().c_str()
            if not fpid:
                try:
                    fpid = str(fp.GetFPID().AsString())
                except:
                    fpid = "Unknown"
            writer.writerow([ref, val, fpid])
            
    print(f"BOM exported to {output_csv}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python export_bom.py <board.kicad_pcb> <output.csv>")
        sys.exit(1)
    export_bom(sys.argv[1], sys.argv[2])
