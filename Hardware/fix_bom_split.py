import re

with open("Hardware/generate_pcbway_bom.py", "r") as f:
    content = f.read()

# Replace J1 to be the ZIF connector
new_j1_code = """
            elif ref == "J1":
                val = "10-pin 0.5mm FPC Connector"
                sku = "FH12-10S-0.5SH(55)"
                desc = "Bottom-contact ZIF FPC connector for LCD. (Placed at J1)"
"""

content = re.sub(
    r'elif ref == "J1":\s+val = "ERC13265FS-1 \(2\.5-inch LCD\)"\s+sku = "ERC13265FS-1"\s+desc = "ST7565R/ST7567 Controller 132x65 FSTN LCD\. Connect through the existing J1 FPC connection\."',
    new_j1_code.strip(),
    content
)

# Add DISP1 manually
add_disp_code = """
        # Add the LCD Screen as a separate line item
        components.append({
            'ref': 'DISP1',
            'val': 'ERC13265FS-1 (2.5-inch LCD)',
            'fpid': 'Mechanical',
            'sku': 'ERC13265FS-1',
            'desc': 'ST7565R/ST7567 Controller 132x65 FSTN LCD.'
        })

        # Write to BOM
"""

content = content.replace("# Write to BOM", add_disp_code)

with open("Hardware/generate_pcbway_bom.py", "w") as f:
    f.write(content)
print("Split J1 into J1 (Connector) and DISP1 (LCD Screen)")
