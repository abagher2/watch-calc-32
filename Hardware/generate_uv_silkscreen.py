import sys
import pcbnew
import xml.etree.ElementTree as ET

def generate_svg(kicad_pcb_path, output_svg_path):
    board = pcbnew.LoadBoard(kicad_pcb_path)
    bbox = board.GetBoardEdgesBoundingBox()
    
    min_x = bbox.GetX() / 1e6
    min_y = bbox.GetY() / 1e6
    y_max = bbox.GetBottom() / 1e6
    width = bbox.GetWidth() / 1e6
    height = bbox.GetHeight() / 1e6
    fp_w = width + 4
    fp_h = height + 4
    
    print(f"Faceplate size: {fp_w}x{fp_h} mm")
    
    svg = ET.Element('svg', {
        'xmlns': 'http://www.w3.org/2000/svg',
        'width': f'{fp_w}mm',
        'height': f'{fp_h}mm',
        'viewBox': f'0 0 {fp_w} {fp_h}'
    })
    
    # (primary, yellow, blue, alpha)
    labels_grid = [
        [("", "", "", ""), ("", "", "", ""), ("", "", "", ""), ("", "", "", ""), ("", "", "", ""), ("", "", "", "")], # Soft keys
        [("√x", "x²", "PARTS", "A"), ("e^x", "10^x", "PROB", "B"), ("LN", "LOG", "L.R.", "C"), ("y^x", "x√y", "x̄,ȳ", "D"), ("1/x", "x!", "s,σ", "E"), ("Σ+", "Σ-", "SUMS", "F")],
        [("STO", "CMPLX", "EQN", "G"), ("RCL", "RND", "SCRL", "H"), ("R↓", "HYP", "R↑", "I"), ("SIN", "ASIN", "π", "J"), ("COS", "ACOS", "%", "K"), ("TAN", "ATAN", "%CHG", "L")],
        [("ENTER", "LASTx", "SHOW", "M"), ("x<>y", "MEM", "x><?", "N"), ("+/-", "MODES", "", "O"), ("E", "DISP", "INT÷", "P"), ("<-", "CLEAR", "", "")],
        [("XEQ", "FN=", "", ""), ("7", "↓", "SOLVE", "Q"), ("8", "↑", "∫", "R"), ("9", "▸km", "▸mi", "S"), ("÷", "x?y", "x?0", "")],
        [("yellow_shift", "", "", ""), ("4", "▸θ,r", "▸y,x", "T"), ("5", "▸HR", "▸HMS", "U"), ("6", "▸DEG", "▸RAD", "V"), ("×", "BASE", "FLAGS", "")],
        [("blue_shift", "", "", ""), ("1", "▸kg", "▸lb", "W"), ("2", "▸°C", "▸°F", "X"), ("3", "▸cm", "▸in", "Y"), ("-", "▸l", "▸gal", "")],
        [("C", "", "", ""), ("0", "REGS", "VIEW", "Z"), (".", "FDISP", "/c", ""), ("PLOT", "CONST", "", ""), ("+", "LBL", "RTN", "")]
    ]
    
    # Extract buttons and sort by Y, then X
    buttons = []
    disp_fp = None
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            x = pos.x / 1e6 - min_x
            y = y_max - pos.y / 1e6 
            buttons.append({'ref': ref, 'x': x, 'y': y, 'pos_y': pos.y / 1e6 - min_y})
        elif "Disp" in ref:
            disp_fp = fp

    buttons.sort(key=lambda b: b['y'], reverse=True)
    rows = []
    current_row = []
    if not buttons: return
        
    current_y = buttons[0]['y']
    for b in buttons:
        if abs(b['y'] - current_y) > 5:
            current_row.sort(key=lambda b: b['x'])
            rows.append(current_row)
            current_row = []
            current_y = b['y']
        current_row.append(b)
    if current_row:
        current_row.sort(key=lambda b: b['x'])
        rows.append(current_row)
        
    # Styles
    yellow_style = "font-family: Arial, sans-serif; font-size: 2px; fill: #FF9900; font-weight: bold; text-anchor: middle;"
    blue_style = "font-family: Arial, sans-serif; font-size: 2px; fill: #00CCFF; font-weight: bold; text-anchor: middle;"
    alpha_style = "font-family: Arial, sans-serif; font-size: 2px; fill: #888888; font-weight: normal; text-anchor: middle;"
    white_style = "font-family: Arial, sans-serif; font-size: 3.2px; fill: #FFFFFF; font-weight: bold; text-anchor: middle; dominant-baseline: middle;"
    f_style = "font-family: Arial, sans-serif; font-size: 3.5px; fill: #FF9900; font-weight: bold; text-anchor: middle; dominant-baseline: middle;"
    g_style = "font-family: Arial, sans-serif; font-size: 3.5px; fill: #00CCFF; font-weight: bold; text-anchor: middle; dominant-baseline: middle;"
    outline_style = "fill: none; stroke: #FFFFFF; stroke-width: 0.15; stroke-opacity: 0.3;"
    
    has_soft_keys = len(rows) >= 8
    grid_offset = 0 if has_soft_keys else 1
    
    for r_idx, row in enumerate(rows):
        grid_r = r_idx + grid_offset
        for c_idx, b in enumerate(row):
            if grid_r < len(labels_grid) and c_idx < len(labels_grid[grid_r]):
                primary, yellow, blue, alpha = labels_grid[grid_r][c_idx]
            else:
                primary, yellow, blue, alpha = ("", "", "", "")
                
            cx = b['x'] + 2
            cy = b['pos_y'] + 2
            
            # Primary Text
            if primary == "yellow_shift":
                # Print 'f' in yellow inside the button
                t_prim = ET.SubElement(svg, 'text', {'x': f"{cx:.2f}", 'y': f"{cy:.2f}", 'style': f_style})
                t_prim.text = "f"
            elif primary == "blue_shift":
                # Print 'g' in blue inside the button
                t_prim = ET.SubElement(svg, 'text', {'x': f"{cx:.2f}", 'y': f"{cy:.2f}", 'style': g_style})
                t_prim.text = "g"
            elif primary:
                # Normal primary white text
                t_prim = ET.SubElement(svg, 'text', {'x': f"{cx:.2f}", 'y': f"{cy:.2f}", 'style': white_style})
                t_prim.text = primary
            
            # Yellow Shift (Above left)
            if yellow:
                t_yel = ET.SubElement(svg, 'text', {'x': f"{cx - 3.2:.2f}", 'y': f"{cy - 3.5:.2f}", 'style': yellow_style})
                t_yel.text = yellow
                
            # Blue Shift (Above right)
            if blue:
                t_blu = ET.SubElement(svg, 'text', {'x': f"{cx + 3.2:.2f}", 'y': f"{cy - 3.5:.2f}", 'style': blue_style})
                t_blu.text = blue
                
            # Alpha Label (Below right)
            if alpha:
                t_alp = ET.SubElement(svg, 'text', {'x': f"{cx + 3.2:.2f}", 'y': f"{cy + 4.5:.2f}", 'style': alpha_style})
                t_alp.text = alpha

    if disp_fp:
        disp_cx = (disp_fp.GetPosition().x / 1e6) - min_x + 2
        disp_cy = (disp_fp.GetPosition().y / 1e6) - min_y + 2
        
        # WatchCalc text (White, italic, heavy weight)
        t_watchcalc = ET.SubElement(svg, 'text', {
            'x': str(disp_cx), 
            'y': str(disp_cy - 18.5), 
            'style': "font-family: Arial, sans-serif; font-size: 3.5px; fill: #FFFFFF; font-weight: 900; font-style: italic; text-anchor: middle;"
        })
        t_watchcalc.text = "WatchCalc"
        
        # 32 text (Cyan, italic, heavy weight, larger font)
        t_32 = ET.SubElement(svg, 'text', {
            'x': str(disp_cx), 
            'y': str(disp_cy - 14.5), 
            'style': "font-family: Arial, sans-serif; font-size: 5px; fill: #00CCFF; font-weight: 900; font-style: italic; text-anchor: middle;"
        })
        t_32.text = "32"

    tree = ET.ElementTree(svg)
    ET.indent(tree, space="  ", level=0)
    tree.write(output_svg_path, encoding='utf-8', xml_declaration=True)
    print(f"Saved UV Silkscreen overlay to {output_svg_path}")

if __name__ == "__main__":
    generate_svg(sys.argv[1], sys.argv[2])
