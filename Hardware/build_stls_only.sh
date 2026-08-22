#!/bin/bash
set -e
KICAD_PYTHON="/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3"

echo "Generating SCAD files..."
$KICAD_PYTHON generate_scad.py

echo "Compiling STLs in parallel..."
mkdir -p ../scratch/stl
for scad in designs/*.scad; do
    base=$(basename "$scad" .scad)
    echo "  -> Compiling $base.stl..."
    openscad -o "../scratch/stl/$base.stl" "$scad" &
done

wait
echo "All STLs successfully generated and saved to scratch/stl/!"
