import sys

def add_silkscreen(filepath):
    # Read the PCB file
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the closing parenthesis of the kicad_pcb file
    # (usually the very last character after trimming whitespace)
    content = content.rstrip()
    if content.endswith(')'):
        content = content[:-1]
    
    # Texts to inject (KiCad 7 syntax)
    # The board is centered around X=50, Y=91 in our setup
    # Note: Ergogen KiCad exporter uses different coordinates, usually positive X/Y.
    # Let's place it at generic absolute coordinates that make sense, or relative.
    # In KiCad PCB files, coordinates are absolute millimeters.
    # We'll just place them near the center.
    
    texts = """
  (gr_text "Calc32" (at 45 -145) (layer "F.SilkS")
    (effects (font (size 4 4) (thickness 0.8)))
  )
  (gr_text "Copyright 2026" (at 45 -135) (layer "F.SilkS")
    (effects (font (size 1.5 1.5) (thickness 0.3)))
  )
  (gr_text "(Pico Module)" (at 45 -152) (layer "F.SilkS")
    (effects (font (size 1.5 1.5) (thickness 0.3)))
  )
)
"""
    
    with open(filepath, 'w') as f:
        f.write(content + texts)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        add_silkscreen(sys.argv[1])
    else:
        add_silkscreen("output/pcbs/calculator.kicad_pcb")
