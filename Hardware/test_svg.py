import sys
import xml.etree.ElementTree as ET

svg = ET.Element('svg', xmlns="http://www.w3.org/2000/svg", viewBox="0 0 800 1000")

# Draw a test rectangle
rect = ET.SubElement(svg, 'rect', x="10", y="10", width="100", height="50", fill="black")

with open("test.svg", "w") as f:
    f.write(ET.tostring(svg, encoding="unicode"))
