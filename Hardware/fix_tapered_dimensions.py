import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# In chassis_tapered, set cw = 81.0 and ch = 152.0
tapered_repl = """    chassis_tapered = chassis.replace("cw   = {cw:.3f};", "cw   = 81.0;").replace("ch   = {fp_h + WALL:.3f};", "ch   = 152.0;")"""
orig = orig.replace("    chassis_tapered = chassis", tapered_repl)

with open("generate_scad.py", "w") as f:
    f.write(orig)
