import re

with open("Hardware/generate_pcbway_bom.py", "r") as f:
    content = f.read()

# Fix J1 to be the ZIF connector, and add DISP1 for the actual screen
new_code = """
            elif ref == "J1":
                val = "10-pin 0.5mm FPC Connector"
                sku = "FH12-10S-0.5SH(55)"
                desc = "Bottom-contact ZIF FPC connector for LCD"
"""

content = re.sub(
    r'elif ref == "J1":\s+val = "ERC13265FS-1 \(2\.5\\" LCD\)"\s+sku = "ERC13265FS-1"\s+desc = "ST7565R/ST7567 Controller 132x65 FSTN LCD. Connect through the existing J1 FPC connection and shim 0.07mm to 1.50mm above PCB"',
    new_code.strip(),
    content
)

# Add DISP1 manually
add_disp_code = """
        # Add the LCD Screen as a separate line item (Not placed during SMT, but part of BOM)
        components.append({
            'ref': 'DISP1',
            'val': 'ERC13265FS-1 (2.5" LCD)',
            'fpid': 'Mechanical',
            'sku': 'ERC13265FS-1',
            'desc': 'ST7565R/ST7567 Controller 132x65 FSTN LCD. Connect through J1 FPC connection.'
        })

        # Write to BOM
"""

content = content.replace("# Write to BOM", add_disp_code)

with open("Hardware/generate_pcbway_bom.py", "w") as f:
    f.write(content)
print("Updated generate_pcbway_bom.py to include ZIF connector and remove shim instruction.")
