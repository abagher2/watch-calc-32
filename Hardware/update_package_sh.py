import re

with open("Hardware/package_manufacturing.sh", "r") as f:
    content = f.read()

content = re.sub(
    r'- \*\*J1 \(LCD FPC\):\*\* The LCD must be shimmed exactly 0\.07mm to achieve a 1\.5mm coplanarity with the tactile switches\.\n',
    '- **J1 (LCD FPC):** ZIF Connector for the ERC13265FS-1 LCD display.\n',
    content
)

with open("Hardware/package_manufacturing.sh", "w") as f:
    f.write(content)
print("Updated package_manufacturing.sh to remove shim instruction.")
