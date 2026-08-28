import csv
import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

# Export BOM
with open("bom.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Designator", "Value", "Footprint", "Description", "Quantity"])
    
    # Simple count by reference prefix / value to simulate grouped BOM or just raw items
    for fp in board.Footprints():
        ref = fp.GetReference()
        if not ref or ref.startswith("LOGO") or ref.startswith("G***"):
            continue
            
        val = fp.GetValue()
        try:
            fpid = str(fp.GetFPID().GetLibItemName().c_str())
            if not fpid:
                fpid = str(fp.GetFPID().AsString())
        except:
            fpid = "Unknown"
            
        desc = ""
        if ref.startswith("B") or ref.startswith("SOFT"):
            desc = "SMD Tactile Switch for keys"
            fpid = "SW_TACT_ALPS_SKQGABE010"
            val = "ALPS SKQGABE010"
        elif ref.startswith("J1"):
            desc = "10-pin 0.5mm pitch FPC Connector (Bottom Contact) - C261895"
            val = "Sharp Memory LCD FPC"
        elif ref.startswith("JST"):
            desc = "Battery connector for wired CR2450 holder"
        elif ref.startswith("MCU"):
            desc = "Raspberry Pi Pico 2 Module (or equivalent RP2350 board)"
            
        writer.writerow([ref, val, fpid, desc, 1])

print("Generated bom.csv")

# Export Centroids
with open("centroid.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Ref", "Val", "Package", "PosX", "PosY", "Rot", "Side", "Notes"])
    
    for fp in board.Footprints():
        ref = fp.GetReference()
        if not ref or ref.startswith("LOGO") or ref.startswith("G***"):
            continue
            
        val = fp.GetValue()
        try:
            fpid = str(fp.GetFPID().GetLibItemName().c_str())
            if not fpid:
                fpid = str(fp.GetFPID().AsString())
        except:
            fpid = "Unknown"
            
        x = fp.GetPosition().x / 1e6
        y = fp.GetPosition().y / 1e6
        rot = fp.GetOrientationDegrees()
        side = "bottom" if fp.IsFlipped() else "top"
        
        note = ""
        if ref == "J1":
            note = "CRITICAL: LCD connected to J1 must be shimmed exactly 0.07mm to reach 1.5mm coplanarity with tactile switches."
            
        writer.writerow([ref, val, fpid, f"{x:.6f}", f"{y:.6f}", f"{rot:.6f}", side, note])
        
print("Generated centroid.csv")
