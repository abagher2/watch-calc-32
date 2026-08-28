import re

with open("Hardware/generate_scad.py", "r") as f:
    content = f.read()

# Replace J1_Y_OFFSET = 10.0 with J1_Y_OFFSET = 17.4
content = re.sub(
    r'J1_Y_OFFSET = 10\.0',
    'J1_Y_OFFSET = 17.4',
    content
)

with open("Hardware/generate_scad.py", "w") as f:
    f.write(content)
print("Updated J1_Y_OFFSET to 17.4 in generate_scad.py")
