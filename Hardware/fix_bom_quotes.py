import re

with open("Hardware/generate_pcbway_bom.py", "r") as f:
    content = f.read()

# Replace the 2.5" with 2.5-inch so we don't have CSV quoting issues
content = content.replace('ERC13265FS-1 (2.5\\" LCD)', 'ERC13265FS-1 (2.5-inch LCD)')

with open("Hardware/generate_pcbway_bom.py", "w") as f:
    f.write(content)
print("Removed inch quotes to fix CSV rendering.")
