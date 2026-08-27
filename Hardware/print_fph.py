import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew
import generate_scad

print(f"fp_w = {generate_scad.fp_w}")
print(f"fp_h = {generate_scad.fp_h}")
print(f"ch = {generate_scad.py_ch}")
