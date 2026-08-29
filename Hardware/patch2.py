import re

with open("generate_scad.py", "r") as f:
    code = f.read()

pattern = re.compile(r'(module button_cavity\(w, h\) \{.*?cube\(\[6\.0, 6\.0, 1\.5 \+ 0\.2\], center=true\);\n    \})', re.DOTALL)

def fix_braces(match):
    text = match.group(1)
    text = text.replace('{', '{{').replace('}', '}}')
    return text

if pattern.search(code):
    print("Found! Applying fix...")
    code = pattern.sub(fix_braces, code)
else:
    print("Could not find block.")

with open("generate_scad.py", "w") as f:
    f.write(code)
