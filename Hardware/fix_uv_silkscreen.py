import re

with open("generate_uv_silkscreen.py", "r") as f:
    text = f.read()

target = """            # Yellow Shift (Above left)
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
                t_alp.text = alpha"""

replacement = """            # Unique ID for the button path
            path_id = f"btn_{int(cx * 10)}_{int(cy * 10)}"
            r_top = 4.0
            r_bot = 4.2
            
            d_top = f"M {cx - r_top:.2f} {cy:.2f} A {r_top} {r_top} 0 0 0 {cx + r_top:.2f} {cy:.2f}"
            d_bot = f"M {cx - r_bot:.2f} {cy:.2f} A {r_bot} {r_bot} 0 0 1 {cx + r_bot:.2f} {cy:.2f}"
            
            if yellow or blue:
                ET.SubElement(svg, 'path', {'id': f"{path_id}_top", 'd': d_top, 'fill': 'none'})
            if alpha:
                ET.SubElement(svg, 'path', {'id': f"{path_id}_bot", 'd': d_bot, 'fill': 'none'})

            # Yellow Shift (Top left - curve)
            if yellow:
                t_yel = ET.SubElement(svg, 'text', {'style': yellow_style})
                tp = ET.SubElement(t_yel, 'textPath', {'href': f"#{path_id}_top", 'startOffset': '25%', 'text-anchor': 'middle'})
                tp.text = yellow
                
            # Blue Shift (Top right - curve)
            if blue:
                t_blu = ET.SubElement(svg, 'text', {'style': blue_style})
                tp = ET.SubElement(t_blu, 'textPath', {'href': f"#{path_id}_top", 'startOffset': '75%', 'text-anchor': 'middle'})
                tp.text = blue
                
            # Alpha Label (Bottom right - curve)
            if alpha:
                t_alp = ET.SubElement(svg, 'text', {'style': alpha_style + " dominant-baseline: hanging;"})
                tp = ET.SubElement(t_alp, 'textPath', {'href': f"#{path_id}_bot", 'startOffset': '75%', 'text-anchor': 'middle'})
                tp.text = alpha"""

text = text.replace(target, replacement)

with open("generate_uv_silkscreen.py", "w") as f:
    f.write(text)
