import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew

board = pcbnew.LoadBoard('output/pcbs/calculator.kicad_pcb')
bbox = board.GetBoardEdgesBoundingBox()
pcb_width = bbox.GetWidth() / 1e6
pad_left = 2.0
pad_right = 2.0
fp_w = pcb_width + pad_left + pad_right
pad_bottom = 2.0
disp_y_raw = 118.15
disp_y_center = disp_y_raw + pad_bottom + 5.35
disp_top_edge = disp_y_center + 42.82 / 2
target_top_margin = (fp_w - 62.8) / 2
fp_h = disp_top_edge + target_top_margin

WALL = 1.8
py_ch = fp_h + 0.85
py_cw = fp_w + 2*WALL
CHASSIS_D = 1.5 + 3.0 + 1.6 + 1.6 + 6.0 + WALL # FRONT_LIP + plate_t + TACTILE_H + PCB_T + BATT_H + WALL
cap_t = 12.0 # Wait, let me check cap_t. It is usually 12mm or 13.5mm

print(f"fp_w: {fp_w:.3f}")
print(f"fp_h: {fp_h:.3f}")
print(f"Chassis Width (py_cw): {py_cw:.3f} mm")
print(f"Chassis Height (py_ch): {py_ch:.3f} mm")
print(f"Chassis Depth (CHASSIS_D): {CHASSIS_D:.3f} mm")
