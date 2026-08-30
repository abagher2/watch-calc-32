with open("generate_scad.py", "r") as f:
    code = f.read()

bad_str = """        translate([0, 0, 1.6/2 - 0.1])
            cube([5.2, 5.2, 1.6], center=true);
    }}
}
FP_CLR = 0.1;
module button_faceplate() {{"""

good_str = """        translate([0, 0, 1.6/2 - 0.1])
            cube([5.2, 5.2, 1.6], center=true);
    }}
}}
FP_CLR = 0.1;
module button_faceplate() {{"""

if bad_str in code:
    code = code.replace(bad_str, good_str)
    with open("generate_scad.py", "w") as f:
        f.write(code)
    print("Fixed!")
else:
    print("Not found")

