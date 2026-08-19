import sys
import pcbnew

def set_routing_rules(board_path):
    board = pcbnew.LoadBoard(board_path)
    board.SetCopperLayerCount(4)
    
    # Get design settings
    design_settings = board.GetDesignSettings()
    
    min_width = pcbnew.FromMM(0.090)
    clearance = pcbnew.FromMM(0.090)
    via_diameter = pcbnew.FromMM(0.40)
    via_drill = pcbnew.FromMM(0.20)
    
    design_settings.m_TrackMinWidth = min_width
    design_settings.m_ViasMinSize = via_diameter
    design_settings.m_ViasMinDrill = via_drill
    design_settings.m_HoleClearance = pcbnew.FromMM(0.150)
    design_settings.m_MinThroughDrill = pcbnew.FromMM(0.150)
    
    # Update default netclass
    default_nc = design_settings.m_NetSettings.GetDefaultNetclass()
    default_nc.SetTrackWidth(min_width)
    default_nc.SetClearance(clearance)
    default_nc.SetViaDiameter(via_diameter)
    default_nc.SetViaDrill(via_drill)
    
    print(f"Set trace width and clearance to 0.100mm, via 0.5/0.3 for {board_path}")
    pcbnew.SaveBoard(board_path, board)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python set_rules.py <board.kicad_pcb>")
        sys.exit(1)
    set_routing_rules(sys.argv[1])
