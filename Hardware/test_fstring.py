FRONT_LIP = 1.5
ch = 100
offset_x = 10
wall = 2
fp_w = 50

s = f"""
        hull() {{
            // Inner cutout (narrower, at the faceplate surface)
            // Leaves a 1.0mm wide bezel overhang holding the faceplate in
            translate([offset_x + 1.0, {FRONT_LIP} - 0.1, wall + 1.0])
                cube([fp_w - 2.0, 0.4, ch + 0.1]);
            
            // Outer cutout (wider, at the top surface of the chassis)
            // By expanding it by FRONT_LIP on each side, it creates a precise 45-degree chamfer
            translate([offset_x + 1.0 - {FRONT_LIP}, -0.1, wall + 1.0 - {FRONT_LIP}])
                cube([fp_w - 2.0 + 2*{FRONT_LIP}, 0.2, ch + 0.1]);
        }}
"""
print("OK")
