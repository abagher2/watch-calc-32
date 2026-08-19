import sys
import pcbnew
import re

def parse_ses_and_apply(board_path, ses_path):
    board = pcbnew.LoadBoard(board_path)
    
    with open(ses_path, 'r') as f:
        ses_data = f.read()

    # We will extract each net section
    net_pattern = re.compile(r'\(net\s+"?([^"\s]+)"?\s+((?:(?:\(wire\s+\(path[^)]+\)\s*\))|(?:\(via\s+"[^"]+"\s+[\d\-]+\s+[\d\-]+\s*\))|\s+)+)\)', re.DOTALL)
    wire_pattern = re.compile(r'\(wire\s+\(path\s+([^\s]+)\s+(\d+)\s+(.*?)\)\s*\)', re.DOTALL)
    via_pattern = re.compile(r'\(via\s+"([^"]+)"\s+([\d\-]+)\s+([\d\-]+)\s*\)')

    UNIT_TO_NM = 100
    
    layer_map = {
        'F.Cu': pcbnew.F_Cu,
        'In1.Cu': pcbnew.In1_Cu,
        'In2.Cu': pcbnew.In2_Cu,
        'B.Cu': pcbnew.B_Cu
    }
    
    for net_match in net_pattern.finditer(ses_data):
        netname = net_match.group(1)
        content = net_match.group(2)
        
        netcode = board.GetNetcodeFromNetname(netname)
        if netcode <= 0:
            print(f"Warning: net {netname} not found on board!")
            continue
            
        # Wires
        for wire_match in wire_pattern.finditer(content):
            layer_name = wire_match.group(1)
            width_units = int(wire_match.group(2))
            coords_str = wire_match.group(3)
            
            layer = layer_map.get(layer_name, pcbnew.F_Cu)
            width = width_units * UNIT_TO_NM
            if width < 100000:
                width = 100000
                
            coords = list(map(int, coords_str.strip().split()))
            for i in range(0, len(coords)-2, 2):
                x1 = coords[i] * UNIT_TO_NM
                y1 = -(coords[i+1] * UNIT_TO_NM)
                x2 = coords[i+2] * UNIT_TO_NM
                y2 = -(coords[i+3] * UNIT_TO_NM)
                
                track = pcbnew.PCB_TRACK(board)
                track.SetStart(pcbnew.VECTOR2I(x1, y1))
                track.SetEnd(pcbnew.VECTOR2I(x2, y2))
                track.SetWidth(width)
                track.SetLayer(layer)
                track.SetNetCode(netcode)
                board.Add(track)
                
        # Vias
        for via_match in via_pattern.finditer(content):
            x = int(via_match.group(2)) * UNIT_TO_NM
            y = -(int(via_match.group(3)) * UNIT_TO_NM)
            
            via = pcbnew.PCB_VIA(board)
            via.SetPosition(pcbnew.VECTOR2I(x, y))
            via.SetNetCode(netcode)
            via.SetWidth(pcbnew.FromMM(0.40))
            via.SetDrill(pcbnew.FromMM(0.20))
            via.SetLayerPair(pcbnew.F_Cu, pcbnew.B_Cu)
            board.Add(via)

    print("Custom SES import completed.")
    pcbnew.SaveBoard(board_path, board)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)
    parse_ses_and_apply(sys.argv[1], sys.argv[2])
