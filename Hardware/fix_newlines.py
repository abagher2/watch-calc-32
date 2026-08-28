with open("Hardware/generate_pcbway_bom.py", "r") as f:
    content = f.read()

content = content.replace("})# Write to BOM", "})\n\n        # Write to BOM")

with open("Hardware/generate_pcbway_bom.py", "w") as f:
    f.write(content)
