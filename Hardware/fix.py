import re
with open("designs/chassis_tapered.scad", "r") as f:
    orig = f.read()

bad = """module screw_bosses() {
    for (sx = [7.0, cw - 2*wall - 7.0]) {
        for (sy = [5.0]) { // Bottom screw position (was at ch-wall-5.0)
            // Peg that passes through the PCB 1.6mm thickness
            translate([wall + sx, pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h=1.6 + 0.1);
        }
    }
}
    }
}"""
good = """module screw_bosses() {
    for (sx = [7.0, cw - 2*wall - 7.0]) {
        for (sy = [5.0]) { // Bottom screw position (was at ch-wall-5.0)
            // Peg that passes through the PCB 1.6mm thickness
            translate([wall + sx, pt, sy]) rotate([-90, 0, 0])
                cylinder(d=3.0, h=1.6 + 0.1);
        }
    }
}"""
orig = orig.replace(bad, good)
with open("designs/chassis_tapered.scad", "w") as f:
    f.write(orig)
