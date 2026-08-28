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
                desc = "Battery connector for wired CR2450 battery; 2.00mm pitch, side entry"
            elif "C" in ref:
                val = "1uF 10V X5R"
                sku = "CL05A105KQ5NNNC"
                desc = "0402 LCD charge pump / decoupling capacitor"
            elif ref == "J1":
                val = "10-pin 0.5mm FPC Connector"
                sku = "FH12-10S-0.5SH(55)"
                desc = "Bottom-contact ZIF FPC connector for LCD. (Placed at J1)"
                
            components.append({'ref': ref, 'val': val, 'fpid': fpid, 'sku': sku, 'desc': desc})

        
        # Add the LCD Screen as a separate line item
        components.append({
            'ref': 'DISP1',
            'val': 'ERC13265FS-1 (2.5-inch LCD)',
            'fpid': 'Mechanical',
            'sku': 'ERC13265FS-1',
            'desc': 'ST7565R/ST7567 Controller 132x65 FSTN LCD.'
        })

        # Write to BOM


        for comp in components:
            writer.writerow([comp['ref'], comp['val'], comp['fpid'], comp['sku'], comp['desc'], 1])
            
    print(f"Rich BOM exported to {output_csv}")

if __name__ == "__main__":
    import sys
    out_csv = sys.argv[2] if len(sys.argv) > 2 else 'bom.csv'
    generate_rich_bom(sys.argv[1] if len(sys.argv) > 1 else 'output/pcbs/calculator.kicad_pcb', out_csv)
