import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Replace J1_Y_OFFSET = 0 with J1_Y_OFFSET = 10.0
content = re.sub(
    r'J1_Y_OFFSET = 0',
    'J1_Y_OFFSET = 10.0',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated J1_Y_OFFSET in generate_scad.py")
