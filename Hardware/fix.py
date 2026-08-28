with open("generate_scad.py", "r") as f:
    lines = f.readlines()

new_lines = []
in_modules = False
for line in lines:
    if "module spiral_arm(r1, r2, w, a)" in line:
        in_modules = True
    
    if in_modules:
        if "FP_CLR = 0.1;" in line:
            in_modules = False
        else:
            # Escape the braces that aren't already escaped
            line = line.replace("{", "{{").replace("}", "}}")
            # If we accidentally double-escaped something, fix it
            line = line.replace("{{{{", "{{").replace("}}}}", "}}")
            
    new_lines.append(line)

with open("generate_scad.py", "w") as f:
    f.writelines(new_lines)
