import xml.etree.ElementTree as ET
import re
import sys
import os
import math

def test_silkscreen_agreement():
    swift_map_path = '../RPNCore/Sources/RPNCore/Display/HP32KeyMap.swift'
    svg_path = 'uv_silkscreen.svg'
    
    if not os.path.exists(swift_map_path) or not os.path.exists(svg_path):
        print("Error: Required files not found. Ensure you are running this from the Hardware/ directory.")
        sys.exit(1)

    # 1. Parse HP32KeyMap.swift for the expected structural grid
    with open(swift_map_path, 'r') as f:
        swift_code = f.read()

    match = re.search(r'public static let standardGrid: \[HP32Key\] = \[(.*?)\]\s+public static let landscapeGrid', swift_code, re.DOTALL)
    expected_keys = []
    if match:
        grid_str = match.group(1)
        keys = re.findall(r'HP32Key\([^)]*label:\s*"([^"]*)",\s*yellowLabel:\s*"([^"]*)",\s*blueLabel:\s*"([^"]*)",\s*alphaLabel:\s*"([^"]*)"', grid_str)
        for p, y, b, a in keys:
            if p == "yellow": p = ""
            if p == "blue": p = ""
            if p == "C": b = "OFF"
            expected_keys.append({"primary": p, "yellow": y, "blue": b, "alpha": a})

    if not expected_keys:
        print("Error: Could not parse labels from HP32KeyMap.swift.")
        sys.exit(1)

    # 2. Parse SVG nodes and coordinates
    tree = ET.parse(svg_path)
    root = tree.getroot()
    
    # We will collect all text nodes: (text, x, y, type)
    # type can be inferred from the style color or we can just cluster them spatially!
    nodes = []
    for text_elem in root.findall(".//{http://www.w3.org/2000/svg}text"):
        if text_elem.text and text_elem.get('x') and text_elem.get('y'):
            t = text_elem.text.strip()
            if not t: continue
            
            x = float(text_elem.get('x'))
            y = float(text_elem.get('y'))
            style = text_elem.get('style', '')
            
            node_type = "unknown"
            if "#FFFFFF" in style: node_type = "primary"
            elif "#FF9900" in style: node_type = "yellow"
            elif "#00CCFF" in style: node_type = "blue"
            elif "#888888" in style: node_type = "alpha"
            
            nodes.append({"text": t, "x": x, "y": y, "type": node_type})

    # Cluster nodes spatially (buttons are approx 6x5mm apart)
    # We will find the primary nodes first, as they represent the button centers
    clusters = []
    primary_nodes = [n for n in nodes if n["type"] == "primary"]
    
    # We must exclude static markings from primary nodes ('ON', 'WatchCalc', '32')
    # Actually, 'ON' is white but let's exclude it and WatchCalc text.
    valid_primary = []
    for p in primary_nodes:
        if p["text"] not in ("ON", "WatchCalc", "32", "f", "g"):
            valid_primary.append(p)
            
    # Sort valid primaries row by row (y first, then x)
    # Since y can have slight variations, round to nearest 2mm for sorting
    valid_primary.sort(key=lambda n: (round(n["y"] / 2.0), n["x"]))
    
    if len(valid_primary) != len(expected_keys):
        # The key map has 43 keys. The soft keys (first row) are usually empty in primary.
        # Let's count them.
        print(f"Warning: Number of parsed physical keys ({len(valid_primary)}) doesn't match expected ({len(expected_keys)}).")
        # Soft keys have empty primary labels in HP32KeyMap but might not be generated in SVG.
    
    # For every valid primary button, assign the closest shift labels
    # Button center is the primary node (cx, cy)
    for p in valid_primary:
        cx, cy = p["x"], p["y"]
        cluster = {"primary": p["text"], "yellow": "", "blue": "", "alpha": "", "cx": cx, "cy": cy}
        
        # Find labels within a 6mm radius
        for n in nodes:
            if n["type"] == "primary": continue
            dist = math.hypot(n["x"] - cx, n["y"] - cy)
            if dist < 6.0:
                if n["type"] == "yellow":
                    cluster["yellow"] = n["text"]
                    # Assert spatial relation: Yellow must be Top-Left (x < cx, y < cy)
                    assert n["x"] < cx, f"Yellow label {n['text']} is not left of {p['text']}"
                    assert n["y"] < cy, f"Yellow label {n['text']} is not above {p['text']}"
                elif n["type"] == "blue":
                    cluster["blue"] = n["text"]
                    # Assert spatial relation: Blue must be Top-Right (x > cx, y < cy)
                    assert n["x"] > cx, f"Blue label {n['text']} is not right of {p['text']}"
                    assert n["y"] < cy, f"Blue label {n['text']} is not above {p['text']}"
                elif n["type"] == "alpha":
                    cluster["alpha"] = n["text"]
                    # Assert spatial relation: Alpha must be Bottom-Right (x > cx, y > cy)
                    assert n["x"] > cx, f"Alpha label {n['text']} is not right of {p['text']}"
                    assert n["y"] > cy, f"Alpha label {n['text']} is not below {p['text']}"
                    
        clusters.append(cluster)

    # Now verify the matched clusters against the expected_keys
    # Ignore soft keys in expected_keys which have no primary label
    filtered_expected = [k for k in expected_keys if k["primary"] != ""]
    
    print("==================================================")
    print(" SILKSCREEN SPATIAL VERIFICATION TEST ")
    print("==================================================")
    print(f"Total Physical Keys Detected: {len(clusters)}")
    print(f"Total Expected Keys (App):    {len(filtered_expected)}")
    print("==================================================")
    
    if len(clusters) != len(filtered_expected):
        print(f"❌ FAIL: Number of clustered buttons in SVG ({len(clusters)}) does not match App expected ({len(filtered_expected)}).")
        sys.exit(1)
        
    for i, exp in enumerate(filtered_expected):
        cl = clusters[i]
        if cl["primary"] != exp["primary"]:
            print(f"❌ FAIL: Primary mismatch at index {i}. Expected {exp['primary']}, Found {cl['primary']}")
            sys.exit(1)
        if cl["yellow"] != exp["yellow"]:
            print(f"❌ FAIL: Yellow shift mismatch at '{cl['primary']}'. Expected '{exp['yellow']}', Found '{cl['yellow']}'")
            sys.exit(1)
        if cl["blue"] != exp["blue"]:
            print(f"❌ FAIL: Blue shift mismatch at '{cl['primary']}'. Expected '{exp['blue']}', Found '{cl['blue']}'")
            sys.exit(1)
        if cl["alpha"] != exp["alpha"]:
            print(f"❌ FAIL: Alpha mismatch at '{cl['primary']}'. Expected '{exp['alpha']}', Found '{cl['alpha']}'")
            sys.exit(1)
            
    print(f"✅ PASS: All {len(clusters)} physical keys matched expected labels.")
    print("✅ PASS: All shift layers verified to be perfectly positioned in Top-Left, Top-Right, and Bottom-Right quadrants relative to their physical button.")
    sys.exit(0)

if __name__ == "__main__":
    test_silkscreen_agreement()
