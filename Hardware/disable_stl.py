import re

with open("generate_scad.py", "r") as f:
    code = f.read()

code = code.replace("for label, src, dst in tasks:", "if False:")

with open("generate_scad.py", "w") as f:
    f.write(code)

