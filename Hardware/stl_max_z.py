def get_max_z(stl_file):
    max_z = -9999
    with open(stl_file, 'r') as f:
        for line in f:
            if line.strip().startswith('vertex'):
                parts = line.strip().split()
                if len(parts) == 4:
                    z = float(parts[3])
                    if z > max_z:
                        max_z = z
    return max_z

print(f"dummy_pcb max Z: {get_max_z('../scratch/stl/dummy_pcb.stl')}")
