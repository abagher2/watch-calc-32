import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# Fix X mirroring
content = re.sub(r'ox = fp_w - \(pad_left \+ b\[\'x\'\]\)', r'ox = pad_left + b[\'x\']', content)

with open("generate_scad.py", "w") as f:
    f.write(content)

