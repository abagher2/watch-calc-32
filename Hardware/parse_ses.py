import sys
import re
import pcbnew

def parse_ses(kicad_pcb_path, ses_path):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    with open(ses_path, 'r') as f:
        content = f.read()
    
    # Extract resolution
    res_match = re.search(r'\(resolution\s+(\w+)\s+(\d+)\)', content)
    mult = 1.0
    if res_match:
        unit, val = res_match.groups()
        if unit == 'um' and val == '10':
            mult = 100.0 # 10 units = 1 um = 1000 nm => 1 unit = 100 nm
    
    nets = {}
    for net in board.GetNetsByName().values():
        nets[net.GetNetname()] = net
    
    # Clear existing tracks
    for track in list(board.Tracks()):
        board.Remove(track)
        
    net_blocks = re.findall(r'\(net\s+([^\s\)]+)\s+(.*?)(?=\(net\s|\)$)', content, re.DOTALL)
    if not net_blocks:
        # Maybe quotes?
        net_blocks = re.findall(r'\(net\s+"([^"]+)"\s+(.*?)(?=\(net\s|\)$)', content, re.DOTALL)
        if not net_blocks:
            # Fallback regex
            net_blocks = re.findall(r'\(net\s+([^\s\)]+)\s+(.*?)(?=\(net\s|\(class\s|\)$)', content, re.DOTALL)

    added_tracks = 0
    added_vias = 0
    
    for net_name, net_content in net_blocks:
        if net_name not in nets:
            continue
        net = nets[net_name]
        
        # Paths
        paths = re.findall(r'\(path\s+([^\s]+)\s+(\d+)\s+(.*?)\)', net_content, re.DOTALL)
        for layer_name, width_str, points_str in paths:
            if layer_name == 'F.Cu':
                layer = pcbnew.F_Cu
            elif layer_name == 'B.Cu':
                layer = pcbnew.B_Cu
            elif layer_name == 'In1.Cu':
                layer = pcbnew.In1_Cu
            elif layer_name == 'In2.Cu':
                layer = pcbnew.In2_Cu
            else:
                layer = pcbnew.F_Cu
            width = int(int(width_str) * mult)
            
            # Points
            pts = []
            for m in re.finditer(r'(-?\d+)\s+(-?\d+)', points_str):
                x = int(int(m.group(1)) * mult)
                y = int(int(m.group(2)) * mult)
                pts.append(pcbnew.VECTOR2I(x, y))
                
            for i in range(len(pts) - 1):
                track = pcbnew.PCB_TRACK(board)
                track.SetStart(pts[i])
                track.SetEnd(pts[i+1])
                track.SetWidth(width)
                track.SetLayer(layer)
                track.SetNetCode(net.GetNetCode())
                board.Add(track)
                added_tracks += 1
                
        # Vias
        vias = re.findall(r'\(via\s+"([^"]+)"\s+(-?\d+)\s+(-?\d+)', net_content)
        for via_type, x_str, y_str in vias:
            x = int(int(x_str) * mult)
            y = int(int(y_str) * mult)
            
            # Extract via dimensions
            # Format: "Via[0-1]_450:300_um" -> diam 450, drill 300
            m = re.search(r'_(\d+):(\d+)_um', via_type)
            if m:
                diam = int(int(m.group(1)) * 1000) # um to nm
                drill = int(int(m.group(2)) * 1000)
                # Enforce minimum 0.5mm diam
                if diam < 500000:
                    diam = 500000
            else:
                diam = pcbnew.FromMM(0.50)
                drill = pcbnew.FromMM(0.3)
                
            via = pcbnew.PCB_VIA(board)
            via.SetPosition(pcbnew.VECTOR2I(x, y))
            via.SetWidth(diam)
            via.SetDrill(drill)
            via.SetNetCode(net.GetNetCode())
            board.Add(via)
            added_vias += 1

    print(f"Imported {added_tracks} tracks and {added_vias} vias.")
    pcbnew.SaveBoard(kicad_pcb_path, board)

if __name__ == "__main__":
    parse_ses(sys.argv[1], sys.argv[2])
