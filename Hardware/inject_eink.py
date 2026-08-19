import sys
import pcbnew

def inject_eink(kicad_pcb_path):
    print(f"Loading {kicad_pcb_path} to inject E-Ink SPI footprint...")
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    # 1. Find the exact position of upper_c3_r4 by looking at the MCU which we placed relative to it
    mcu = None
    for fp in board.Footprints():
        if fp.GetReference() == "U1" or fp.GetReference() == "MCU1" or fp.GetValue() == "promicro":
            mcu = fp
            break
            
    if not mcu:
        print("ERROR: Could not find MCU to reference position!")
        return
        
    # Convert MCU to SMD to free up bottom layer routing
    for pad in mcu.Pads():
        pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        pad.SetLayerSet(pad.SMDMask())
        pad.SetDrillSize(pcbnew.VECTOR2I(0, 0))
        
    # Flip MCU to bottom
    if mcu.GetLayer() == pcbnew.F_Cu:
        mcu.Flip(mcu.GetPosition(), False)
        
    # Also find JST and flip it to bottom (and make SMD)
    for fp in board.Footprints():
        if "JST" in fp.GetReference() or "JST" in fp.GetValue():
            for pad in fp.Pads():
                pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
                pad.SetLayerSet(pad.SMDMask())
                pad.SetDrillSize(pcbnew.VECTOR2I(0, 0))
            if fp.GetLayer() == pcbnew.F_Cu:
                fp.Flip(fp.GetPosition(), False)
        
    mcu_pos = mcu.GetPosition()
    # E-Ink screen should be 15mm to the left of the MCU, at the same Y height
    start_x = mcu_pos.x - pcbnew.FromMM(15)
    start_y = mcu_pos.y
    
    # 2. Create the Footprint
    fp = pcbnew.FOOTPRINT(board)
    fp.SetReference("Disp")
    fp.SetValue("E-Ink")
    fp.SetPosition(pcbnew.VECTOR2I(start_x, start_y))
    fp.SetLayer(pcbnew.F_Cu)
    
    # Reference is auto-created by SetReference
    
    # 3. Add 8 through-hole pads and connect them to nets!
    # E-Ink pins: VCC, GND, BUSY, RST, DC, CS, DIN, CLK
    nets = ["VCC", "GND", "P21", "P20", "P19", "P18", "P11", "P10"]
    for i, net_name in enumerate(nets):
        pad = pcbnew.PAD(fp)
        pad.SetNumber(str(i+1))
        
        fp.Add(pad)
        pad_x_offset = pcbnew.FromMM(i * 2.54)
        pad.SetPosition(pcbnew.VECTOR2I(start_x + pad_x_offset, start_y))
        
        pad.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.7), pcbnew.FromMM(1.7)))
        pad.SetDrillSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.0), pcbnew.FromMM(1.0)))
        pad.SetShape(pcbnew.PAD_SHAPE_CIRCLE if i > 0 else pcbnew.PAD_SHAPE_RECT)
        pad.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
        pad.SetLayerSet(pad.PTHMask())
        
        # Connect to net
        net = board.FindNet(net_name)
        if net:
            pad.SetNetCode(net.GetNetCode())
            
        # Pad is already added to footprint above
        
    # Add footprint to board
    board.Add(fp)
    
    print(f"Saving updated board to {kicad_pcb_path}...")
    pcbnew.SaveBoard(kicad_pcb_path, board)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python inject_eink.py <source.kicad_pcb>")
        sys.exit(1)
    inject_eink(sys.argv[1])
