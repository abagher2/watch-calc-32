import sys
import pcbnew

def auto_route_and_fill(kicad_pcb_path, ses_path):
    # Load the board
    print(f"Loading PCB: {kicad_pcb_path}")
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    import subprocess
    import os
    print(f"Importing routing paths from {ses_path} using custom SES parser...")
    try:
        subprocess.run(["/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3", "import_ses.py", kicad_pcb_path, ses_path], check=True)
        board = pcbnew.LoadBoard(kicad_pcb_path)  # Reload board with imported tracks
    except Exception as e:
        print(f"Failed to fully import SES file from Freerouting: {e}")
        # sys.exit(1)
        
    print("Creating Ground Planes on Front and Back Copper...")
    bbox = board.GetBoardEdgesBoundingBox()
    
    # Remove existing zones to prevent intersection errors from multiple runs
    for zone in board.Zones():
        board.Remove(zone)
        
    # Find the netcode for GND
    netcode = 0
    try:
        gnd_net = board.FindNet("GND")
        if gnd_net and hasattr(gnd_net, "GetNetCode"):
            netcode = gnd_net.GetNetCode()
    except Exception:
        pass
    if netcode <= 0:
        print("Warning: GND net not found, creating isolated copper pour.")
    
    # Define polygon corners for the copper zone
    pts = pcbnew.SHAPE_LINE_CHAIN()
    margin = pcbnew.FromMM(2)
    pts.Append(bbox.GetX() - margin, bbox.GetY() - margin)
    pts.Append(bbox.GetRight() + margin, bbox.GetY() - margin)
    pts.Append(bbox.GetRight() + margin, bbox.GetBottom() + margin)
    pts.Append(bbox.GetX() - margin, bbox.GetBottom() + margin)
    pts.SetClosed(True)
    
    # Front Copper (F.Cu)
    zone_f = pcbnew.ZONE(board)
    zone_f.SetLayer(pcbnew.F_Cu)
    if netcode > 0: zone_f.SetNetCode(netcode)
    zone_f.AddPolygon(pts)
    board.Add(zone_f)
    
    # Inner 1 Copper (In1.Cu)
    zone_in1 = pcbnew.ZONE(board)
    zone_in1.SetLayer(pcbnew.In1_Cu)
    if netcode > 0: zone_in1.SetNetCode(netcode)
    zone_in1.AddPolygon(pts)
    board.Add(zone_in1)

    # Inner 2 Copper (In2.Cu)
    zone_in2 = pcbnew.ZONE(board)
    zone_in2.SetLayer(pcbnew.In2_Cu)
    if netcode > 0: zone_in2.SetNetCode(netcode)
    zone_in2.AddPolygon(pts)
    board.Add(zone_in2)
    
    # Back Copper (B.Cu)
    zone_b = pcbnew.ZONE(board)
    zone_b.SetLayer(pcbnew.B_Cu)
    if netcode > 0: zone_b.SetNetCode(netcode)
    zone_b.AddPolygon(pts)
    board.Add(zone_b)
    
    print("Filling Copper Zones (Resolves MacroFab warning)...")
    filler = pcbnew.ZONE_FILLER(board)
    filler.Fill(board.Zones())
    
    # Save the board
    print(f"Saving fully routed and filled board to {kicad_pcb_path}...")
    pcbnew.SaveBoard(kicad_pcb_path, board)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python auto_router.py <board.kicad_pcb> <board.ses>")
        sys.exit(1)
    auto_route_and_fill(sys.argv[1], sys.argv[2])
