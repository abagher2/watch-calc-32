import sys
import pcbnew

def fix_switch_pads(kicad_pcb_path):
    print(f"Loading {kicad_pcb_path} to fix switch pads...")
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    count = 0
    for fp in board.Footprints():
        if "SW_TACT" in fp.GetFPID().GetLibItemName().c_str() or "SW_TACT" in fp.GetFPID().GetLibNickname().c_str() or "SKQG" in fp.GetFPID().GetLibItemName().c_str():
            # Find pads
            pads_1 = []
            pads_2 = []
            for pad in fp.Pads():
                if pad.GetNumber() == "1":
                    pads_1.append(pad)
                elif pad.GetNumber() == "2":
                    pads_2.append(pad)
                    
            # Rename secondary pads so they don't trigger unconnected errors, and clear their nets
            if len(pads_1) > 1:
                for pad in pads_1[1:]:
                    pad.SetNumber("NC")
                    pad.SetNetCode(0)
                    count += 1
            if len(pads_2) > 1:
                for pad in pads_2[1:]:
                    pad.SetNumber("NC")
                    pad.SetNetCode(0)
                    count += 1
    print(f"Fixed {count} redundant pads.")
    pcbnew.SaveBoard(kicad_pcb_path, board)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python fix_switch_pads.py <source.kicad_pcb>")
        sys.exit(1)
    fix_switch_pads(sys.argv[1])