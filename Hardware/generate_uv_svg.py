import pcbnew
import base64

board_path = "output/pcbs/calculator.kicad_pcb"
board = pcbnew.LoadBoard(board_path)

bbox = board.GetBoardEdgesBoundingBox()
x_min = bbox.GetX() / 1e6
y_min = bbox.GetY() / 1e6
x_max = bbox.GetRight() / 1e6
y_max = bbox.GetBottom() / 1e6

pcb_width = x_max - x_min
pcb_height = y_max - y_min

buttons = []
for fp in board.GetFootprints():
    ref = fp.GetReference()
    pos = fp.GetPosition()
    x = pos.x / 1e6 - x_min
    y = y_max - pos.y / 1e6 
    if "B" in ref and len(ref) <= 3:
        buttons.append({'ref': ref, 'x': x, 'y': y})

buttons.sort(key=lambda b: b['y'], reverse=True)
rows = []
current_row = []
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

labels = [
    ["√𝑥", "𝑒ˣ", "LN", "𝑦ˣ", "1/𝑥", "Σ+"],
    ["STO", "RCL", "R↓", "SIN", "COS", "TAN"],
    ["ENTER", "𝑥≷𝑦", "+/-", "E", "<-"],
    ["XEQ", "7", "8", "9", "÷"],
    ["yellow", "4", "5", "6", "×"],
    ["blue", "1", "2", "3", "-"],
    ["C", "0", ".", "PLOT", "+"]
]

label_map = {
    "√𝑥": ("𝑥²", "PARTS"),
    "𝑒ˣ": ("10ˣ", "PROB"),
    "LN": ("LOG", "L.R."),
    "𝑦ˣ": ("ˣ√𝑦", "𝑥̄,𝑦̄"),
    "1/𝑥": ("𝑥!", "s,σ"),
    "Σ+": ("Σ-", "SUMS"),
    "STO": ("CMPLX", "EQN"),
    "RCL": ("RND", "SCRL"),
    "R↓": ("HYP", "R↑"),
    "SIN": ("ASIN", "π"),
    "COS": ("ACOS", "%"),
    "TAN": ("ATAN", "%CHG"),
    "ENTER": ("LAST𝑥", "SHOW"),
    "𝑥≷𝑦": ("MEM", "𝑥≷?"),
    "+/-": ("MODES", ""),
    "E": ("DISP", ""),
    "<-": ("CLEAR", ""),
    "XEQ": ("FN=", ""),
    "7": ("↓", "SOLVE"),
    "8": ("↑", "∫"),
    "9": ("▸km", "▸mi"),
    "/": ("𝑥?𝑦", "𝑥?0"),
    "4": ("▸θ,𝑟", "▸𝑦,𝑥"),
    "5": ("▸HR", "▸HMS"),
    "6": ("▸DEG", "▸RAD"),
    "*": ("BASE", "FLAGS"),
    "1": ("▸kg", "▸lb"),
    "2": ("▸°C", "▸°F"),
    "3": ("▸cm", "▸in"),
    "-": ("▸l", "▸gal"),
    "C": ("", ""),
    "0": ("REGS", "VIEW"),
    ".": ("FDISP", "/c"),
    "PLOT": ("CONST", ""),
    "+": ("LBL", "RTN"),
    "yellow": ("", ""),
    "blue": ("", "")
}

svg_content = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {pcb_width} {pcb_height}" width="{pcb_width}mm" height="{pcb_height}mm">
    <rect width="{pcb_width}" height="{pcb_height}" fill="black" stroke="red"/>
    <!-- App Nameplate (iOS App Style) -->
    <text x="10" y="16" fill="white" font-size="4" font-family="Helvetica" font-weight="900" font-style="italic">WatchCalc</text>
    <text x="10" y="24" fill="cyan" font-size="7" font-family="Helvetica" font-weight="900" font-style="italic">32</text>
    <text x="{pcb_width - 10}" y="20" fill="gray" font-size="2.5" font-family="Helvetica" font-weight="bold" text-anchor="end">RPN SCIENTIFIC CALCULATOR</text>
'''

font_size = 2.5
for r_idx, row in enumerate(rows):
    for c_idx, b in enumerate(row):
        svg_y = pcb_height - b['y']
        svg_x = b['x']
        
        lbl = labels[r_idx][c_idx] if r_idx < len(labels) and c_idx < len(labels[r_idx]) else ""
        y_lbl, b_lbl = label_map.get(lbl, ("", ""))
        
        lbl = lbl.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        y_lbl = y_lbl.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        b_lbl = b_lbl.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        
        # Center label (straight)
        if lbl and lbl not in ("yellow", "blue"):
            svg_content += f'    <text x="{svg_x}" y="{svg_y + 1}" fill="white" font-size="2.5" font-family="Helvetica" font-weight="bold" text-anchor="middle">{lbl}</text>\n'

        # Generate unique IDs for the paths based on coordinates
        path_id = f"btn_{int(svg_x)}_{int(svg_y)}"
        r_top = 4.0
        r_bot = 4.2

        if y_lbl or b_lbl:
            # Top Arc (sweep 0 goes UP)
            svg_content += f'    <path id="{path_id}_top" d="M {svg_x - r_top} {svg_y} A {r_top} {r_top} 0 0 0 {svg_x + r_top} {svg_y}" fill="none"/>\n'
            # Bottom Arc (sweep 1 goes DOWN)
            svg_content += f'    <path id="{path_id}_bot" d="M {svg_x - r_bot} {svg_y} A {r_bot} {r_bot} 0 0 1 {svg_x + r_bot} {svg_y}" fill="none"/>\n'

        if y_lbl:
            svg_content += f'    <text fill="orange" font-size="{font_size - 0.5}" font-family="Helvetica" font-weight="bold"><textPath href="#{path_id}_top" startOffset="50%" text-anchor="middle">{y_lbl}</textPath></text>\n'
        
        if b_lbl:
            svg_content += f'    <text fill="cyan" font-size="{font_size - 0.5}" font-family="Helvetica" font-weight="bold" dominant-baseline="hanging"><textPath href="#{path_id}_bot" startOffset="50%" text-anchor="middle">{b_lbl}</textPath></text>\n'

svg_content += '</svg>'

with open('uv_silkscreen.svg', 'w', encoding='utf-8') as f:
    f.write(svg_content)

print("Saved uv_silkscreen.svg")