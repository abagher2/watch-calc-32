#!/bin/bash
echo "Regenerating all SCAD files and STLs..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 generate_scad.py

echo "Zipping manufacturing files..."
./generate_manufacturing_files.sh
echo "Zipping complete!"
