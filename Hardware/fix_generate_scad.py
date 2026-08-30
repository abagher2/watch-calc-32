with open("generate_scad.py", "r") as f:
    code = f.read()
code = code.replace("2.5);\n\"", "2.5);\\n\"")
with open("generate_scad.py", "w") as f:
    f.write(code)
