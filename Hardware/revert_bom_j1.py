import re

with open("Hardware/generate_pcbway_bom.py", "r") as f:
    content = f.read()

# Remove the DISP1 block entirely
content = re.sub(
    r'\s+# Add the LCD Screen as a separate line item.*?components\.append\(\{.*?\'ref\': \'DISP1\'.*?\}\)\s+',
    '',
    content,
    flags=re.DOTALL
)

# Revert J1 back to being the LCD, but without the shim instruction
new_j1_code = """
            elif ref == "J1":
                val = "ERC13265FS-1 (2.5\\" LCD)"
                sku = "ERC13265FS-1"
                desc = "ST7565R/ST7567 Controller 132x65 FSTN LCD. Connect through the existing J1 FPC connection."
"""

content = re.sub(
    r'elif ref == "J1":\s+val = "10-pin 0\.5mm FPC Connector"\s+sku = "FH12-10S-0\.5SH\(55\)"\s+desc = "Bottom-contact ZIF FPC connector for LCD"',
    new_j1_code.strip(),
    content
)

with open("Hardware/generate_pcbway_bom.py", "w") as f:
    f.write(content)
print("Reverted generate_pcbway_bom.py so J1 is the screen again.")
