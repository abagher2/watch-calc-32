import json

def generate_wokwi():
    # Pin definitions
    COL_PINS = [0, 1, 4, 21, 20, 19]
    ROW_PINS = [8, 7, 6, 5, 16, 14, 15, 18]
    
    parts = [
        {
            "type": "board-pi-pico",
            "id": "pico",
            "top": 0,
            "left": 0,
            "attrs": {}
        },
        {
            "type": "board-ssd1306",
            "id": "oled",
            "top": -120,
            "left": 100,
            "attrs": {
                "i2cAddress": "0x3c"
            }
        }
    ]
    
    connections = [
        # Power OLED
        ["pico:3V3", "oled:VCC", "red", ["v-20"]],
        ["pico:GND.1", "oled:GND", "black", ["v-10"]],
        # I2C OLED (SDA=2, SCL=3)
        ["pico:GP2", "oled:SDA", "green", ["v-30"]],
        ["pico:GP3", "oled:SCL", "blue", ["v-40"]]
    ]
    
    # Generate 48 buttons (8 rows x 6 cols)
    for r_idx, row_pin in enumerate(ROW_PINS):
        for c_idx, col_pin in enumerate(COL_PINS):
            btn_id = f"btn_{r_idx}_{c_idx}"
            btn_top = 150 + r_idx * 50
            btn_left = -100 + c_idx * 50
            
            parts.append({
                "type": "wokwi-pushbutton",
                "id": btn_id,
                "top": btn_top,
                "left": btn_left,
                "attrs": {
                    "color": "black",
                    "key": str(r_idx) if c_idx == 0 else "" # Optional keyboard mapping
                }
            })
            
            # Button has pins 1.l, 1.r, 2.l, 2.r
            # Connect side 1 to row pin, side 2 to col pin
            connections.append([f"{btn_id}:1.l", f"pico:GP{row_pin}", "green", []])
            connections.append([f"{btn_id}:2.l", f"pico:GP{col_pin}", "orange", []])
            
    # Also add the wokwi.toml for MicroPython
    # We will assume they use the micropython runner for now until Swift is compiled
    
    diagram = {
        "version": 1,
        "author": "Antigravity",
        "editor": "wokwi",
        "parts": parts,
        "connections": connections
    }
    
    import os
    os.makedirs("Firmware/wokwi", exist_ok=True)
    with open("Firmware/wokwi/diagram.json", "w") as f:
        json.dump(diagram, f, indent=2)
        
    with open("Firmware/wokwi/wokwi.toml", "w") as f:
        f.write('[wokwi]\n')
        f.write('version = 1\n')
        f.write('firmware = "../main.py"\n')
        f.write('elf = ""\n')
        
if __name__ == "__main__":
    generate_wokwi()
    print("Wokwi files generated in Firmware/wokwi/")