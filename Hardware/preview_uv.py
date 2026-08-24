import xml.etree.ElementTree as ET

tree = ET.parse("Hardware/uv_silkscreen.svg")
root = tree.getroot()

# Add a black background rect
rect = ET.Element("rect", {"width": "100%", "height": "100%", "fill": "#111111"})
root.insert(0, rect)

# Draw dark grey rounded rectangles for buttons
# Button size: ~6x5mm
for text_elem in root.findall("{http://www.w3.org/2000/svg}text"):
    if text_elem.get("style", "").startswith("font-family: Arial, sans-serif; font-size: 3.2px; fill: #FFFFFF"):
        cx = float(text_elem.get("x"))
        cy = float(text_elem.get("y"))
        btn_rect = ET.Element("rect", {
            "x": f"{cx - 3.5}", "y": f"{cy - 2.5}", 
            "width": "7", "height": "5", 
            "rx": "1.5", "ry": "1.5", 
            "fill": "#333333"
        })
        root.insert(1, btn_rect)

tree.write("Hardware/uv_silkscreen_preview.svg", encoding='utf-8', xml_declaration=True)
print("Saved preview to Hardware/uv_silkscreen_preview.svg")
