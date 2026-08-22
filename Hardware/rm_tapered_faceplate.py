import re

with open("generate_scad.py", "r") as f:
    orig = f.read()

# Remove faceplate_tapered block
target_block = """    # ═══════════════════════════════════════════════════════
    # TAPERED FACEPLATE (Matched bezel height)
    # ═══════════════════════════════════════════════════════
    faceplate_tapered = faceplate
"""
orig = re.sub(r'    # ═══════════════════════════════════════════════════════\n    # TAPERED FACEPLATE \(Matched bezel height\)\n    # ═══════════════════════════════════════════════════════\n    faceplate_tapered = faceplate\n.*?\n    with open\("designs/faceplate_tapered\.scad", "w"\) as f:\n        f\.write\(faceplate_tapered\)\n', '', orig, flags=re.DOTALL)

with open("generate_scad.py", "w") as f:
    f.write(orig)
