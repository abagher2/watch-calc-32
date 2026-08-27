import sys
sys.path.append('/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python3.9/site-packages')
import pcbnew
import re

with open("generate_scad.py") as f:
    code = f.read()

# We can just extract the local variables from generate_scad() by making it return them!
code = code.replace("def generate_scad():", "def generate_scad():")
code = code.replace("    os.makedirs(\"../scratch/stl\", exist_ok=True)", "    os.makedirs(\"../scratch/stl\", exist_ok=True)")

# Let's just execute the relevant part!
exec_code = code.split("if __name__ ==")[0]
exec_code += """
if __name__ == '__main__':
    # monkeypatch to not generate STLs
    def write_file(*args): pass
    global open
    import builtins
    class DummyFile:
        def __enter__(self): return self
        def __exit__(self, *args): pass
        def write(self, *args): pass
    builtins.open = lambda *args, **kwargs: DummyFile()
    import os
    os.system = lambda *args: 0
    generate_scad()
"""
with open("test_gen.py", "w") as f:
    f.write(exec_code)
