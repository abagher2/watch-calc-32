import sys
import pcbnew

def inject_eink(kicad_pcb_path):
    print(f"Loading {kicad_pcb_path} to inject Sharp LCD SPI footprint...")
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    # 1. Find MCU
    mcu = None
    for fp in board.GetFootprints():
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
        
    if mcu.GetLayer() == pcbnew.F_Cu:
        mcu.Flip(mcu.GetPosition(), False)
        
    for fp in board.GetFootprints():
        if "JST" in fp.GetReference() or "JST" in fp.GetValue():
            for pad in fp.Pads():
                pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
                pad.SetLayerSet(pad.SMDMask())
                pad.SetDrillSize(pcbnew.VECTOR2I(0, 0))
            if fp.GetLayer() == pcbnew.F_Cu:
                fp.Flip(fp.GetPosition(), False)
        
    # Sharp LCD 10-pin FPC Connector (0.5mm pitch)
    # Position absolute based on previous manual placement
    start_x = pcbnew.FromMM(45.0)
    start_y = pcbnew.FromMM(-130.0)
    
    # 2. Create the Footprint
    fp = pcbnew.FOOTPRINT(board)
    fp.SetReference("J1")
    fp.SetValue("Sharp_LCD")
    fp.SetPosition(pcbnew.VECTOR2I(start_x, start_y))
    fp.SetLayer(pcbnew.F_Cu)
    
    nets = ["P21", "P20", "P19", "P18", "P11", "VCC", "VCC", "GND", "GND", "GND"]
    # Pad spacing is 0.5mm, 10 pads total.
    pad_start_x = pcbnew.FromMM(42.75)
    pad_y = pcbnew.FromMM(-127.8)
    
    for i, net_name in enumerate(nets):
        pad = pcbnew.PAD(fp)
        pad.SetNumber(str(i+1))
        
        fp.Add(pad)
        pad_x = pad_start_x + pcbnew.FromMM(i * 0.5)
        pad.SetPosition(pcbnew.VECTOR2I(pad_x, pad_y))
        
        pad.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(0.3), pcbnew.FromMM(1.3)))
        pad.SetShape(pcbnew.PAD_SHAPE_RECT)
        pad.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        pad.SetLayerSet(pad.SMDMask())
        
        net = board.FindNet(net_name)
        if net:
            pad.SetNetCode(net.GetNetCode())
            
    board.Add(fp)
    
    print(f"Saving updated board to {kicad_pcb_path}...")
    pcbnew.SaveBoard(kicad_pcb_path, board)

if __name__ == "__main__":
    inject_eink(sys.argv[1])
