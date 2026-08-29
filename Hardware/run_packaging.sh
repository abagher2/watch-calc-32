#!/bin/bash
set -e
KICAD_PYTHON="/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3"

echo "Updating STLs / Dummy PCB..."
$KICAD_PYTHON generate_scad.py

echo "Packaging Manufacturing Files..."
bash package_manufacturing.sh
