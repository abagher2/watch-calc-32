import csv
import sys
import pcbnew
import os

def generate_rich_bom(kicad_pcb_path, output_csv):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Designator', 'Value', 'Footprint', 'Description', 'Quantity'])
        
        # Group identical components
        components = []
        for fp in board.GetFootprints():
            ref = fp.GetReference()
            val = fp.GetValue()
            
            fpid = fp.GetFPID().GetLibItemName().c_str()
            if not fpid:
                try:
                    fpid = str(fp.GetFPID().AsString())
                except:
                    fpid = "Unknown"
                    
            desc = ""
            if "SW_TACT" in fpid or "B" in ref or "SOFT" in ref:
                val = "ALPS SKQGABE010"
                desc = "SMD Tactile Switch for keys"
            elif "MCU1" in ref:
                val = "RP2350 Pico 2"
                desc = "Raspberry Pi Pico 2 Module (or equivalent RP2350 board)"
            elif "JST1" in ref:
                val = "JST-PH 2-Pin Male Header"
                desc = "Battery connector for wired CR2450 holder"
            elif "Disp" in ref:
                val = "8-Pin Female Header"
                desc = "For 2.13-inch Waveshare E-Ink Module"
                
            components.append({'ref': ref, 'val': val, 'fpid': fpid, 'desc': desc})
            
        # Write to BOM
        for comp in components:
            writer.writerow([comp['ref'], comp['val'], comp['fpid'], comp['desc'], 1])
            
    print(f"Rich BOM exported to {output_csv}")

if __name__ == "__main__":
    generate_rich_bom('calculator.kicad_pcb', 'output/WatchCalc32_PCBWay_Manufacturing/PCBA_Files/bom.csv')
