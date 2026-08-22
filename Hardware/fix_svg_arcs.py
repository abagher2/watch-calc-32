import re

with open("generate_uv_svg.py", "r") as f:
    text = f.read()

# Replace the text rendering part
target = """        if lbl and lbl not in ("yellow", "blue"):
            svg_content += f'    <text x="{svg_x}" y="{svg_y + 1}" fill="white" font-size="2.5" font-family="Helvetica" font-weight="bold" text-anchor="middle">{lbl}</text>\\n'

        if y_lbl:
            svg_content += f'    <text x="{svg_x - 3}" y="{svg_y - 3.5}" fill="orange" font-size="{font_size - 0.5}" font-family="Helvetica" font-weight="bold" text-anchor="middle">{y_lbl}</text>\\n'
        
        if b_lbl:
            svg_content += f'    <text x="{svg_x + 3}" y="{svg_y + 4.5}" fill="cyan" font-size="{font_size - 0.5}" font-family="Helvetica" font-weight="bold" text-anchor="middle">{b_lbl}</text>\\n'"""

replacement = """        # Center label (straight)
        if lbl and lbl not in ("yellow", "blue"):
            svg_content += f'    <text x="{svg_x}" y="{svg_y + 1}" fill="white" font-size="2.5" font-family="Helvetica" font-weight="bold" text-anchor="middle">{lbl}</text>\\n'

        # Generate unique IDs for the paths based on coordinates
        path_id = f"btn_{int(svg_x)}_{int(svg_y)}"
        r_top = 4.0
        r_bot = 4.2

        if y_lbl or b_lbl:
            # Top Arc (sweep 0 goes UP)
            svg_content += f'    <path id="{path_id}_top" d="M {svg_x - r_top} {svg_y} A {r_top} {r_top} 0 0 0 {svg_x + r_top} {svg_y}" fill="none"/>\\n'
            # Bottom Arc (sweep 1 goes DOWN)
            svg_content += f'    <path id="{path_id}_bot" d="M {svg_x - r_bot} {svg_y} A {r_bot} {r_bot} 0 0 1 {svg_x + r_bot} {svg_y}" fill="none"/>\\n'

        if y_lbl:
            svg_content += f'    <text fill="orange" font-size="{font_size - 0.5}" font-family="Helvetica" font-weight="bold"><textPath href="#{path_id}_top" startOffset="50%" text-anchor="middle">{y_lbl}</textPath></text>\\n'
        
        if b_lbl:
            svg_content += f'    <text fill="cyan" font-size="{font_size - 0.5}" font-family="Helvetica" font-weight="bold" dominant-baseline="hanging"><textPath href="#{path_id}_bot" startOffset="50%" text-anchor="middle">{b_lbl}</textPath></text>\\n'"""

text = text.replace(target, replacement)

with open("generate_uv_svg.py", "w") as f:
    f.write(text)
