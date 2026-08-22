import trimesh
import numpy as np
import shapely
from shapely.geometry import Polygon

mesh = trimesh.load_mesh('../scratch/stl/faceplate_fdm.stl')
# Z=1.3mm is slice 13 at 0.1mm height
slice_z = 1.3
cross_section = mesh.section(plane_origin=[0, 0, slice_z], plane_normal=[0, 0, 1])

if cross_section is not None:
    polys, _ = cross_section.to_planar()
    print(f"Found {len(polys)} polygons at Z={slice_z}")
    # We expect 1 main faceplate polygon, and several button polygons.
    # Let's print their bounding boxes to see.
    for i, p in enumerate(polys):
        bounds = p.bounds
        print(f"Poly {i}: {bounds}, Area: {p.area:.2f}")
else:
    print("No intersection at Z=1.3")
