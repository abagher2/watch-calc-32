with open("generate_uv_svg.py", "r") as f:
    text = f.read()
    
text = text.replace('board_path = "Hardware/calculator.kicad_pcb"', 'board_path = "output/pcbs/calculator.kicad_pcb"')

with open("generate_uv_svg.py", "w") as f:
    f.write(text)
