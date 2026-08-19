import sys
import pcbnew

def route_unconnected(board_path):
    board = pcbnew.LoadBoard(board_path)
    
    UNIT_TO_NM = int(1e6) # Kicad uses nm
    
    def add_track(netname, x1, y1, x2, y2, layer):
        netcode = board.GetNetcodeFromNetname(netname)
        track = pcbnew.PCB_TRACK(board)
        track.SetStart(pcbnew.VECTOR2I(int(x1 * UNIT_TO_NM), int(y1 * UNIT_TO_NM)))
        track.SetEnd(pcbnew.VECTOR2I(int(x2 * UNIT_TO_NM), int(y2 * UNIT_TO_NM)))
        track.SetWidth(pcbnew.FromMM(0.15))
        track.SetLayer(layer)
        track.SetNetCode(netcode)
        board.Add(track)
        
    def add_via(netname, x, y):
        netcode = board.GetNetcodeFromNetname(netname)
        via = pcbnew.PCB_VIA(board)
        via.SetPosition(pcbnew.VECTOR2I(int(x * UNIT_TO_NM), int(y * UNIT_TO_NM)))
        via.SetNetCode(netcode)
        via.SetWidth(pcbnew.FromMM(0.40))
        via.SetDrill(pcbnew.FromMM(0.20))
        via.SetLayerPair(pcbnew.F_Cu, pcbnew.B_Cu)
        board.Add(via)
        
    # Net P0: B2-1 (11.9, -96.85) to B4-1 (26.4, -96.85)
    # Go left to X=9.0, then via, then across
    add_track('P0', 11.9, -96.85, 9.0, -96.85, pcbnew.F_Cu)
    add_via('P0', 9.0, -96.85)
    add_track('P0', 9.0, -96.85, 26.4, -96.85, pcbnew.In1_Cu)
    add_via('P0', 26.4, -96.85)
    
    # Net P4: B3-1 (11.9, -111.85) to B5-1 (26.4, -111.85)
    add_track('P4', 11.9, -111.85, 9.0, -111.85, pcbnew.F_Cu)
    add_via('P4', 9.0, -111.85)
    add_track('P4', 9.0, -111.85, 26.4, -111.85, pcbnew.In1_Cu)
    add_via('P4', 26.4, -111.85)

    # Net P7: B3-2 (11.9, -108.15) to B2-2 (11.9, -93.15)
    # Go left to X=8.0, then via, then up
    add_track('P7', 11.9, -108.15, 8.0, -108.15, pcbnew.F_Cu)
    add_via('P7', 8.0, -108.15)
    add_track('P7', 8.0, -108.15, 8.0, -93.15, pcbnew.In2_Cu)
    add_via('P7', 8.0, -93.15)
    add_track('P7', 8.0, -93.15, 11.9, -93.15, pcbnew.F_Cu)
    
    # And connect P7 to B1-2 (19.15, -78.15)
    # B2-2 is (11.9, -93.15). We go UP to Y=-91.15 to avoid the NC pad at Y=-93.15
    add_track('P7', 11.9, -93.15, 11.9, -91.15, pcbnew.F_Cu)
    add_via('P7', 11.9, -91.15)
    add_track('P7', 11.9, -91.15, 19.15, -91.15, pcbnew.In2_Cu)
    add_track('P7', 19.15, -91.15, 19.15, -78.15, pcbnew.In2_Cu)
    add_via('P7', 19.15, -78.15)
    
    print("Manual routes added!")
    pcbnew.SaveBoard(board_path, board)

if __name__ == "__main__":
    route_unconnected(sys.argv[1])
