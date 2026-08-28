import re

with open("Hardware/generate_pcbway_bom.py", "r") as f:
    content = f.read()

# Replace SPLC502 IC LCD with ST7565R controller for ERC13265FS-1
content = re.sub(
    r'SPLC502 IC LCD',
    'ST7565R/ST7567 Controller 132x65 FSTN LCD',
    content
)

with open("Hardware/generate_pcbway_bom.py", "w") as f:
    f.write(content)
print("Updated generate_pcbway_bom.py")
