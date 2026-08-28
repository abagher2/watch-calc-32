import sys
# Read generate_scad.py and extract the part where `rows` are formed
with open("generate_scad.py", "r") as f:
    code = f.read()

# We can just run the file up to the row generation and print the rows
# Let's just grep the actual SCAD output from a previous run to find the translate Y coords!
