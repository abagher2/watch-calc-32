def get_max_y(stl_file):
    max_y = -9999
    with open(stl_file, 'r') as f:
        for line in f:
            if line.strip().startswith('vertex'):
                parts = line.strip().split()
                if len(parts) == 4:
                    y = float(parts[2])
                    if y > max_y:
                        max_y = y
    return max_y

print(f"dummy_pcb max Y: {get_max_y('../scratch/stl/dummy_pcb.stl')}")
