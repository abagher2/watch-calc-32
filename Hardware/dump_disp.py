with open("Hardware/generate_scad.py", "r") as f:
    for line in f:
        if "DISP" in line and "=" in line:
            print(line.strip())
