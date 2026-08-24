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
        [("", "", "", ""), ("", "", "", ""), ("", "", "", ""), ("", "", "", ""), ("", "", "", ""), ("", "", "", "")],
        [("√𝑥", "𝑥²", "PARTS", "A"), ("𝑒ˣ", "10ˣ", "PROB", "B"), ("LN", "LOG", "L.R.", "C"), ("𝑦ˣ", "ˣ√𝑦", "𝑥̄,𝑦̄", "D"), ("¹/𝑥", "𝑥!", "s,σ", "E"), ("Σ+", "Σ-", "SUMS", "F")],
        [("STO", "CMPLX", "EQN", "G"), ("RCL", "RND", "SCRL", "H"), ("R↓", "HYP", "R↑", "I"), ("SIN", "ASIN", "π", "J"), ("COS", "ACOS", "%", "K"), ("TAN", "ATAN", "%CHG", "L")],
        [("ENTER", "LAST𝑥", "SHOW", "M"), ("𝑥≷𝑦", "MEM", "𝑥≷?", "N"), ("+/-", "MODES", "|x|", "O"), ("E", "DISP", "÷R", "P"), ("<-", "CLEAR", "", "")],
        [("XEQ", "FN=", "", ""), ("7", "↓", "SOLVE", "Q"), ("8", "↑", "∫", "R"), ("9", "▸km", "▸mi", "S"), ("÷", "𝑥?𝑦", "𝑥?0", "")],
        [("yellow_shift", "", "", ""), ("4", "▸θ,𝑟", "▸𝑦,𝑥", "T"), ("5", "▸HR", "▸HMS", "U"), ("6", "▸DEG", "▸RAD", "V"), ("×", "BASE", "FLAGS", "")],
        [("blue_shift", "", "", ""), ("1", "▸kg", "▸lb", "W"), ("2", "▸°C", "▸°F", "X"), ("3", "▸cm", "▸in", "Y"), ("-", "▸l", "▸gal", "")],
        [("C", "", "OFF", ""), ("0", "REGS", "VIEW", "Z"), (".", "FDISP", "/c", ""), ("PLOT", "CNST", "", ""), ("+", "LBL", "RTN", "")],
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
        elif ref == "J1":
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
    white_style = "font-family: Arial, sans-serif; font-size: 3.2px; fill: #FFFFFF; font-weight: bold; text-anchor: middle; dominant-baseline: middle;"
    yellow_style = "font-family: Arial, sans-serif; font-size: 2px; fill: #FF9900; font-weight: bold;"
    blue_style = "font-family: Arial, sans-serif; font-size: 2px; fill: #00CCFF; font-weight: bold;"
    alpha_style = "font-family: Arial, sans-serif; font-size: 2px; fill: #888888; font-weight: normal;"
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
            elif primary == "C":
                # Print 'C' normally, then add 'ON' below it
                t_prim = ET.SubElement(svg, 'text', {'x': f"{cx:.2f}", 'y': f"{cy:.2f}", 'style': white_style})
                t_prim.text = "C"
                t_on = ET.SubElement(svg, 'text', {'x': f"{cx:.2f}", 'y': f"{cy + 1.2:.2f}", 'style': "font-family: Arial, sans-serif; font-size: 1.5px; fill: #FFFFFF; font-weight: normal; text-anchor: middle;"})
                t_on.text = "ON"
            elif primary:
                # Normal primary white text
                t_prim = ET.SubElement(svg, 'text', {'x': f"{cx:.2f}", 'y': f"{cy:.2f}", 'style': white_style})
                t_prim.text = primary
            
            # Unique ID for the button path
            path_id = f"btn_{int(cx * 10)}_{int(cy * 10)}"
            r_top = 4.0
            r_bot = 4.2
            
            d_top = f"M {cx - r_top:.2f} {cy:.2f} A {r_top} {r_top} 0 0 0 {cx + r_top:.2f} {cy:.2f}"
            d_bot = f"M {cx - r_bot:.2f} {cy:.2f} A {r_bot} {r_bot} 0 0 1 {cx + r_bot:.2f} {cy:.2f}"
            
            # Button radius is ~4mm, place text outside the button bounds.
            if yellow or blue:
                ET.SubElement(svg, 'path', {'id': f"{path_id}_top", 'd': d_top, 'fill': 'none'}) # Keep path if needed for reference, but we won't use textPath
            if alpha:
                ET.SubElement(svg, 'path', {'id': f"{path_id}_bot", 'd': d_bot, 'fill': 'none'})

            # Yellow Shift (Top left - straight)
            if yellow:
                # Top-left corner
                t_yel = ET.SubElement(svg, 'text', {'x': f"{cx - 2.5:.2f}", 'y': f"{cy - 4.2:.2f}", 'style': yellow_style + " text-anchor: end;"})
                t_yel.text = yellow
                
            # Blue Shift (Top right - straight)
            if blue:
                # Top-right corner
                t_blu = ET.SubElement(svg, 'text', {'x': f"{cx + 2.5:.2f}", 'y': f"{cy - 4.2:.2f}", 'style': blue_style + " text-anchor: start;"})
                t_blu.text = blue
                
            # Alpha Label (Bottom right - straight)
            if alpha:
                # Bottom-right corner
                t_alp = ET.SubElement(svg, 'text', {'x': f"{cx + 2.5:.2f}", 'y': f"{cy + 4.2:.2f}", 'style': alpha_style + " dominant-baseline: hanging; text-anchor: start;"})
                t_alp.text = alpha

    if disp_fp:
        disp_cx = (disp_fp.GetPosition().x / 1e6) - min_x + 2
        disp_cy = (disp_fp.GetPosition().y / 1e6) - min_y + 2

    # Inject the vertical stack logo between the first column and the numpad
    if len(rows) >= 4:
        bottom_rows = rows[-4:]
        try:
            col0_x = sum(r[0]['x'] for r in bottom_rows) / 4.0
            col1_x = sum(r[1]['x'] for r in bottom_rows) / 4.0
            logo_x = col0_x + (col1_x - col0_x) * 0.45 + 2 # +2 for board offset
            
            start_y = bottom_rows[0]['pos_y'] + 2 - 1.0
            line_height = (bottom_rows[-1]['pos_y'] - bottom_rows[0]['pos_y']) / 3.0
            
            logo_style = "font-family: system-ui, -apple-system, BlinkMacSystemFont, 'SF Pro', sans-serif; font-size: 3.8px; fill: #FFFFFF; font-weight: bold; text-anchor: start;"
            
            lines = ["Sta", "ck +", "Calc", "32"]
            for i, line in enumerate(lines):
                t_logo = ET.SubElement(svg, 'text', {'x': f"{logo_x:.2f}", 'y': f"{start_y + i * line_height:.2f}", 'style': logo_style})
                t_logo.text = line
        except Exception as e:
            print(f"Could not add logo: {e}")


    tree = ET.ElementTree(svg)
    ET.indent(tree, space="  ", level=0)
    tree.write(output_svg_path, encoding='utf-8', xml_declaration=True)
    print(f"Saved UV Silkscreen overlay to {output_svg_path}")

if __name__ == "__main__":
    generate_svg(sys.argv[1], sys.argv[2])
