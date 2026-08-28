import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# Fix board path
content = content.replace('board_path = "output/pcbs/calculator.kicad_pcb"', 'board_path = "calculator.kicad_pcb"')

# Fix caps duplicate issue
content = content.replace('if \'caps\' not in globals():\n            caps = []', '')
content = re.sub(r'caps\.append', r'if "caps" not in locals(): caps = []\n        caps.append', content)
# actually safer to just add caps=[] right before the board loading loop.
content = re.sub(r'for fp in board\.GetFootprints\(\):', r'caps = []\nfor fp in board.GetFootprints():', content)

# Remove the locals check just in case
content = content.replace('if "caps" not in locals(): caps = []\n        ', '')
content = content.replace("if 'caps' not in globals():\n            caps = []\n        ", "")

# Fix battery holder size
content = content.replace('cylinder(d=20, h=3.2, $fn=32)', 'cylinder(d=21, h=3.2, $fn=32)')

with open("generate_scad.py", "w") as f:
    f.write(content)

print("Fixed generate_scad.py issues!")
