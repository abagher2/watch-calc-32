import csv
import sys
import pcbnew
import os
import wx
app = wx.App(False)

def generate_rich_bom(kicad_pcb_path, output_csv):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Designator', 'Value', 'Footprint', 'Part Number / SKU', 'Description', 'Quantity'])
        
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
            sku = ""
            if "SW_TACT" in fpid or "B" in ref or "SOFT" in ref:
                val = "ALPS SKQGABE010"
                sku = "SKQGABE010"
                desc = "SMD Tactile Switch for keys. **CRITICAL PCBA NOTE:** Z-height must be exactly 1.5mm off PCB surface."
            elif "MCU1" in ref:
                val = "RP2350 Pico 2"
                sku = "SC1632"
                desc = "Raspberry Pi Pico 2 (non-wireless, RP2350 with dual Arm Cortex-M33 cores and FPU)"
            elif "JST1" in ref:
                val = "JST PH 2-pin side-entry header"
                sku = "S2B-PH-K-S(LF)(SN)"
                desc = "Battery connector for wired CR2450 holder; 2.00mm pitch, side entry"
            elif "J1" in ref and "FH12" in fpid:
                val = "10-Pin FPC ZIF Connector (0.5mm Pitch)"
                sku = "FH12-10S-0.5SH(55)"
                desc = "For Sharp LS027B7DH01 Memory LCD. **CRITICAL PCBA NOTE:** Connects directly to Pico SPI pins."
                
            components.append({'ref': ref, 'val': val, 'fpid': fpid, 'sku': sku, 'desc': desc})
            
        # Write to BOM
        for comp in components:
            writer.writerow([comp['ref'], comp['val'], comp['fpid'], comp['sku'], comp['desc'], 1])
            
        # We need to manually add the Sharp LCD Screen to the BOM as a sourced part (not PCBA soldered)
        writer.writerow(['LCD1', 'Sharp 2.7" Memory LCD', 'Manual install', 'LS027B7DH01', 'Graphical Memory LCD 400x240. Connect to J1 during final assembly; shim 0.07mm to exactly 1.50mm above PCB.', 1])
            
    print(f"Rich BOM exported to {output_csv}")

if __name__ == "__main__":
    generate_rich_bom('Hardware/calculator.kicad_pcb', 'output/WatchCalc32_PCBWay_Manufacturing/PCBA_Files/bom.csv')
