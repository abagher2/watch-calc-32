import sys
import pcbnew

def check_unrouted(kicad_pcb_path):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    
    unrouted_nets = set()
    for netcode, net in board.GetNetInfo().NetsByNetcode().items():
        if net.GetNetCode() == 0:
            continue # Ignore empty net
            
        unrouted = board.GetUnroutedNetCount(net.GetNetCode())
        if unrouted > 0:
            unrouted_nets.add(net.GetNetname())
            print(f"Unrouted Net: {net.GetNetname()} ({unrouted} missing connections)")
            
    if not unrouted_nets:
        print("0 unrouted nets! PCB is fully routed.")
    else:
        print(f"Total unrouted nets: {len(unrouted_nets)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python check_unrouted.py <kicad_pcb>")
        sys.exit(1)
    check_unrouted(sys.argv[1])