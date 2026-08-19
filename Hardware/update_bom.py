import sys
import pcbnew

def update_bom_values(kicad_pcb_path):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    print(f"Updating BOM Values in {kicad_pcb_path}...")
    
    for fp in board.Footprints():
        ref = fp.GetReference()
        
        if ref == "MCU1":
            fp.SetValue("RASPBERRY PI PICO")
            print(f"Set {ref} value to RASPBERRY PI PICO")
        elif ref == "OLED1":
            fp.SetValue("0.96 inch OLED I2C")
            print(f"Set {ref} value to 0.96 inch OLED I2C")
        elif "JST" in ref:
            fp.SetValue("JST-PH 2.0 2-Pin")
            print(f"Set {ref} value to JST-PH 2.0 2-Pin")
        elif ref.startswith("B"):
            fp.SetValue("Tactile Switch 6x6mm")
            
    pcbnew.SaveBoard(kicad_pcb_path, board)
    print("BOM update complete!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python update_bom.py <board.kicad_pcb>")
        sys.exit(1)
    update_bom_values(sys.argv[1])
