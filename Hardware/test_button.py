def generate_button(pw, ph, w, h, gap):
    # pw, ph = 6.0, 4.0
    # w, h = 7.5, 5.5
    
    # Base
    # Shaft
    # Chamfer
    print(f"Shaft size: {pw-2}x{ph-2}")
    print(f"Top size: {w}x{h}")
    # Overhang is (w - (pw-2))/2 = (7.5 - 4.0)/2 = 1.75
    # To chamfer 1.75mm horizontally at 45 degrees, we need 1.75mm vertically!
    # Top starts at Z=2.2.
    # So chamfer goes from Z = (2.2 - 1.75) = Z=0.45 to Z=2.2!
    print(f"Chamfer start: Z={2.2-1.75}")
    # But Shaft is Z=0.8 to Z=2.2. If chamfer starts at 0.45, it eats into the base!
    
generate_button(6.0, 4.0, 7.5, 5.5, 0.6)
