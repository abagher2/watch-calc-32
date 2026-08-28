import json
import generate_scad

buttons = generate_scad.get_buttons()
print(json.dumps(buttons, indent=2))
