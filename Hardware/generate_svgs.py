import json
import re

with open("pcb_layout.json", "r") as f:
    rows = json.load(f)

# Shift arrays (matching the rows list, but skipping the softkeys Row 0)
# We will define a tuple: (Primary, Yellow_Shift, Blue_Shift)
labels = [
    # Row 1 (Math functions)
    [("SQRT", "x^2", "PARTS"), ("e^x", "10^x", "PROB"), ("LN", "LOG", "L.R."), 
     ("y^x", "xRootY", "x_y_bar"), ("1/x", "x!", "s_sigma"), ("Sigma+", "Sigma-", "SUMS")],
    
    # Row 2 (Trig / Store)
    [("STO", "CMPLX", "EQN"), ("RCL", "RND", "SCRL"), ("R_dn", "HYP", "R_up"),
     ("SIN", "ASIN", "PI"), ("COS", "ACOS", "%"), ("TAN", "ATAN", "%CHG")],
    
    # Row 3 (ENTER etc)
    [("ENTER", "LASTx", "SHOW"), ("x<>y", "MEM", "x<>?"), ("+/-", "MODES", "|x|"),
     ("E", "DISP", "INT_div"), ("<-", "CLEAR", "OFF")],
     
    # Row 4 (Numpad)
    [("XEQ", "FN=", "SOLVE_int"), ("7", "ScrollUp", "SOLVE_int"), ("8", "ScrollDown", "SOLVE_int"),
     ("9", "", "toMi"), ("/", "", "")],
     
    # Row 5 (Numpad)
    [("YELLOW", "", ""), ("4", "", ""), ("5", "", ""), ("6", "", ""), ("x", "", "")],
    
    # Row 6 (Numpad)
    [("BLUE", "", ""), ("1", "", ""), ("2", "", ""), ("3", "", ""), ("-", "", "")],
    
    # Row 7 (Numpad)
    [("C", "", ""), ("0", "", ""), (".", "", ""), ("PLOT", "", ""), ("+", "", "")]
]

# Simple robust 10x10 font scaled and stroked
font = {
    '0': "M 2 2 H 8 V 8 H 2 Z", '1': "M 5 2 V 8", '2': "M 2 2 H 8 V 5 H 2 V 8 H 8",
    '3': "M 2 2 H 8 V 8 H 2 M 2 5 H 8", '4': "M 2 2 V 5 H 8 V 8 M 8 2 V 5",
    '5': "M 8 2 H 2 V 5 H 8 V 8 H 2", '6': "M 8 2 H 2 V 8 H 8 V 5 H 2",
    '7': "M 2 2 H 8 V 8", '8': "M 2 2 H 8 V 8 H 2 Z M 2 5 H 8",
    '9': "M 8 8 V 2 H 2 V 5 H 8", '.': "M 4 7 H 6 V 9 H 4 Z",
    '+': "M 2 5 H 8 M 5 2 V 8", '-': "M 2 5 H 8", 'x': "M 2 2 L 8 8 M 2 8 L 8 2",
    '/': "M 8 2 L 2 8", '=': "M 2 3 H 8 M 2 7 H 8",
    'A': "M 2 8 V 2 H 8 V 8 M 2 5 H 8", 'B': "M 2 2 H 7 V 5 H 2 M 7 5 H 8 V 8 H 2 V 2",
    'C': "M 8 2 H 2 V 8 H 8", 'D': "M 2 2 H 6 L 8 4 V 6 L 6 8 H 2 Z",
    'E': "M 8 2 H 2 V 8 H 8 M 2 5 H 6", 'F': "M 8 2 H 2 V 8 M 2 5 H 6",
    'G': "M 8 2 H 2 V 8 H 8 V 5 H 5", 'H': "M 2 2 V 8 M 8 2 V 8 M 2 5 H 8",
    'I': "M 5 2 V 8 M 3 2 H 7 M 3 8 H 7", 'J': "M 7 2 V 7 L 5 8 L 3 7 V 5",
    'K': "M 2 2 V 8 M 8 2 L 2 5 L 8 8", 'L': "M 2 2 V 8 H 8",
    'M': "M 2 8 V 2 L 5 5 L 8 2 V 8", 'N': "M 2 8 V 2 L 8 8 V 2",
    'O': "M 2 2 H 8 V 8 H 2 Z", 'P': "M 2 8 V 2 H 8 V 5 H 2",
    'Q': "M 2 2 H 8 V 8 H 2 Z M 6 6 L 8 8", 'R': "M 2 8 V 2 H 8 V 5 H 2 M 5 5 L 8 8",
    'S': "M 8 2 H 2 V 5 H 8 V 8 H 2", 'T': "M 2 2 H 8 M 5 2 V 8",
    'U': "M 2 2 V 8 H 8 V 2", 'V': "M 2 2 L 5 8 L 8 2",
    'W': "M 2 2 V 8 L 5 5 L 8 8 V 2", 'X': "M 2 2 L 8 8 M 2 8 L 8 2",
    'Y': "M 2 2 L 5 5 L 8 2 M 5 5 V 8", 'Z': "M 2 2 H 8 L 2 8 H 8",
    '(': "M 6 2 L 3 5 L 6 8", ')': "M 4 2 L 7 5 L 4 8",
    '<': "M 8 2 L 2 5 L 8 8", '>': "M 2 2 L 8 5 L 2 8",
    '|': "M 5 2 V 8"
}

sunken_icons = {
    # Non-math semantic icons (Solid blocky shapes)
    "PLOT": "M 2 8 H 4 V 5 H 2 Z M 5 8 H 7 V 2 H 5 Z M 8 8 H 10 V 0 H 8 Z", # 📈
    "MEM": "M 2 2 H 5 L 6 3 H 9 V 8 H 2 Z", # 📁 Folder
    "DISP": "M 5 3 A 2 2 0 1 0 5 7 A 2 2 0 1 0 5 3 M 5 0 V 2 M 5 8 V 10 M 1 5 H 3 M 7 5 H 9 M 2 2 L 3 3 M 7 7 L 8 8 M 2 8 L 3 7 M 7 2 L 8 3", # ☀️
    "R/S": "M 2 2 L 7 5 L 2 8 Z M 8 2 H 10 V 8 H 8 Z", # ⏯️
    "SST": "M 2 2 L 6 5 L 2 8 Z M 6 2 L 10 5 L 6 8 Z", # ⏭️ Next Track (replaces footprints for easier poly)
    "Rv": "M 2 1 H 8 L 5 4 Z M 2 5 H 8 L 5 8 Z", # ⏬
    "CLEAR": "M 5 2 H 10 V 8 H 5 L 1 5 Z", # ⌫
    "L.SHIFT": "M 2 5 A 3 3 0 1 0 8 5 A 3 3 0 1 0 2 5", # 🟡
    "R.SHIFT": "M 2 2 H 8 V 8 H 2 Z", # 🟦
    "ScrollUp": "M 2 8 H 8 L 5 2 Z",
    "ScrollDown": "M 2 2 H 8 L 5 8 Z",
    "OFF": "M 2 5 A 3 3 0 1 0 8 5 A 3 3 0 1 0 2 5 M 5 2 V 5", # Power icon
}

# Add math icons mapped directly to text for now
def get_path(text, is_sunken=False):
    if is_sunken and text in sunken_icons:
        return sunken_icons[text]
    
    path = ""
    w = 10
    for i, char in enumerate(text):
        if char.upper() in font:
            p = font[char.upper()]
            # Translate path by i*w
            parts = p.split()
            for j in range(len(parts)):
                if parts[j].lstrip('-').replace('.','').isdigit():
                    if j > 0 and parts[j-1] in ['M', 'L', 'H']: # X coord
                        parts[j] = str(float(parts[j]) + i*w)
                    elif j > 1 and parts[j-2] in ['M', 'L']: # Y coord (Wait, V is Y coord only)
                        pass
                if parts[j] == 'V': # Next is Y coord
                    pass
            path += " ".join(parts) + " "
    return path.strip()

def transform_path(path_str, dx, dy, scale):
    out = []
    parts = path_str.split()
    i = 0
    while i < len(parts):
        cmd = parts[i]
        out.append(cmd)
        if cmd in ['M', 'L']:
            out.append(str(float(parts[i+1])*scale + dx))
            out.append(str(float(parts[i+2])*scale + dy))
            i += 3
        elif cmd == 'H':
            out.append(str(float(parts[i+1])*scale + dx))
            i += 2
        elif cmd == 'V':
            out.append(str(float(parts[i+1])*scale + dy))
            i += 2
        elif cmd == 'A':
            # A rx ry x-axis-rotation large-arc-flag sweep-flag x y
            out.extend([str(float(parts[i+1])*scale), str(float(parts[i+2])*scale)])
            out.extend(parts[i+3:i+6])
            out.append(str(float(parts[i+6])*scale + dx))
            out.append(str(float(parts[i+7])*scale + dy))
            i += 8
        elif cmd == 'Z':
            i += 1
        else:
            i += 1
    return " ".join(out)

svg_embossed = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000">']
svg_sunken = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000">']

# We iterate over rows (skip Row 0 which is soft keys in `rows`)
for row_idx, r in enumerate(rows[1:]):
    if row_idx >= len(labels): break
    label_row = labels[row_idx]
    
    for col_idx, btn in enumerate(r):
        if col_idx >= len(label_row): break
        pri, yel, blu = label_row[col_idx]
        
        # OpenSCAD coord to SVG coord (10x scale)
        # origin in SCAD is bottom-left, SVG is top-left
        # wait, we must match OpenSCAD exactly!
        # If OpenSCAD does `translate([ox, oy])`, we should place the graphic at `(ox*10, 1000 - oy*10)`.
        # Because we will use `scale([0.1, 0.1, 1]) mirror([0,1,0]) import()` in OpenSCAD!
        # `mirror([0,1,0])` turns `(x, y)` into `(x, -y)`. 
        # So we just place it at `(ox*10, oy*10)` directly in the SVG !!
        
        cx = btn['ox'] * 10
        cy = btn['oy'] * 10
        bw = 10 * 10
        if btn['ref'] == 'B1': bw = 15.75 * 10 # ENTER key is wider
        bh = 9 * 10
        
        # Center coordinates of the key
        kx = cx + bw/2
        ky = cy + bh/2
        
        # 1. Primary (Embossed, Center)
        if pri:
            p = get_path(pri, False)
            if p:
                pw = len(pri) * 10
                scale = 0.4
                dx = kx - (pw * scale)/2
                dy = ky - (10 * scale)/2
                t_path = transform_path(p, dx, dy, scale)
                # 0.8mm physical = 8 units stroke width
                svg_embossed.append(f'<path d="{t_path}" fill="none" stroke="black" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>')
                
        # 2. Yellow (Sunken, Top-Left)
        if yel:
            p = get_path(yel, True)
            if p:
                pw = len(yel) * 10 if yel not in sunken_icons else 10
                scale = 0.2
                # Top left of the keycap
                dx = cx + 15
                dy = cy + bh - 15 - (10 * scale) # SCAD Y increases up! So Top is cy + bh!
                t_path = transform_path(p, dx, dy, scale)
                if yel in sunken_icons:
                    svg_sunken.append(f'<path d="{t_path}" fill="black" />')
                else:
                    svg_sunken.append(f'<path d="{t_path}" fill="none" stroke="black" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>')

        # 3. Blue (Sunken, Bottom-Right)
        if blu:
            p = get_path(blu, True)
            if p:
                pw = len(blu) * 10 if blu not in sunken_icons else 10
                scale = 0.2
                dx = cx + bw - 15 - (pw * scale)
                dy = cy + 15
                t_path = transform_path(p, dx, dy, scale)
                if blu in sunken_icons:
                    svg_sunken.append(f'<path d="{t_path}" fill="black" />')
                else:
                    svg_sunken.append(f'<path d="{t_path}" fill="none" stroke="black" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>')

svg_embossed.append('</svg>')
svg_sunken.append('</svg>')

with open("Layout_Embossed.svg", "w") as f:
    f.write("\n".join(svg_embossed))

with open("Layout_Sunken.svg", "w") as f:
    f.write("\n".join(svg_sunken))

print("SVG generation complete.")
