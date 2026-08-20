import re
import sys

vertices = []
with open(sys.argv[1], 'r') as f:
    for line in f:
        match = re.search(r'vertex\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)', line)
        if match:
            vertices.append((float(match.group(1)), float(match.group(2)), float(match.group(3))))

if not vertices:
    print("No vertices found.")
else:
    xs = [v[0] for v in vertices]
    ys = [v[1] for v in vertices]
    zs = [v[2] for v in vertices]
    print(f"X: {min(xs)} to {max(xs)}")
    print(f"Y: {min(ys)} to {max(ys)}")
    print(f"Z: {min(zs)} to {max(zs)}")
