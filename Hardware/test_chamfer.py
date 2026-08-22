def print_shapes():
    # Button Top Keycap: starts at Z=2.2, ends at Z=3.5
    # The shaft is at Z=0.8 to Z=2.2. Width: pw-2 = 4.0.
    # We can chamfer from Z=2.2 to Z=3.0.
    print("""
module chamfered_button() {
    // Base Plunger
    translate([0, 0, 0.4]) cube([6.0, 4.0, 0.8], center=true);
    // Shaft
    translate([0, 0, 1.5]) cube([4.0, 2.0, 1.4], center=true);
    // Top Keycap with chamfered underside!
    hull() {
        // Bottom of keycap (matches shaft size)
        translate([0, 0, 2.2]) cube([4.0, 2.0, 0.01], center=true);
        // Middle of keycap (full size)
        translate([0, 0, 2.8]) cube([7.5, 5.5, 0.01], center=true);
        // Top of keycap
        translate([0, 0, 3.5]) cube([7.5, 5.5, 0.01], center=true);
    }
}
module chamfered_pocket() {
    // Bottom Cavity
    translate([0, 0, 0.45]) cube([6.0+1.2, 4.0+1.2, 1.1], center=true);
    // Shelf Hole
    translate([0, 0, 1.5]) cube([4.0+1.2, 2.0+1.2, 1.0], center=true);
    // Top Indentation with chamfered bottom!
    hull() {
        translate([0, 0, 2.0]) cube([4.0+1.2, 2.0+1.2, 0.01], center=true);
        translate([0, 0, 2.6]) cube([7.5+1.2, 5.5+1.2, 0.01], center=true);
        translate([0, 0, 3.1]) cube([7.5+1.2, 5.5+1.2, 0.01], center=true);
    }
}
""")
print_shapes()
