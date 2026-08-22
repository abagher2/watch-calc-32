with open("generate_scad.py", "r") as f:
    orig = f.read()
    
target = """    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)"""
        
replacement = """    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)
        
    with open("designs/chassis_tpu.scad", "w") as f:
        f.write(chassis_tpu)
        
    with open("designs/chassis_tapered.scad", "w") as f:
        f.write(chassis_tapered)"""
        
if target in orig:
    orig = orig.replace(target, replacement)
else:
    # If it was already replaced but modified somehow
    target2 = """    with open("designs/chassis.scad", "w") as f:"""
    replacement2 = """    with open("designs/chassis.scad", "w") as f:
        f.write(chassis)
        
    with open("designs/chassis_tpu.scad", "w") as f:
        f.write(chassis_tpu)
        
    with open("designs/chassis_tapered.scad", "w") as f:
        f.write(chassis_tapered)
        
    # dummy"""
    orig = orig.replace(target2, replacement2)
    
with open("generate_scad.py", "w") as f:
    f.write(orig)
