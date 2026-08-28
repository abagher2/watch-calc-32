import json
import re

with open("generate_scad.py", "r") as f:
    content = f.read()

# I will just grep the coordinates from the previous output.
# Actually, running generate_scad.py with a patch to print the coords is easiest.
