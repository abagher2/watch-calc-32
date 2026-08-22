def print_shapes():
    print("""
module chamfered_button() {
    // Z=0 to Z=0.4: Straight Base Plunger
    translate([0, 0, 0.2]) cube([6.0, 4.0, 0.4], center=true);
    // Z=0.4 to Z=1.4: Chamfer to Shaft
    hull() {
        translate([0, 0, 0.4]) cube([6.0, 4.0, 0.01], center=true);
        translate([0, 0, 1.4]) cube([4.0, 2.0, 0.01], center=true);
    }
    // Z=1.4 to Z=2.2: Shaft
    translate([0, 0, 1.8]) cube([4.0, 2.0, 0.8], center=true);
}
module chamfered_pocket() {
    // Z=0 to Z=0.5: Straight Bottom Cavity
    translate([0, 0, 0.25]) cube([6.0+1.2, 4.0+1.2, 0.5], center=true);
    // Z=0.5 to Z=1.5: Chamfered Roof (NO HORIZONTAL OVERHANG!)
    hull() {
        translate([0, 0, 0.5]) cube([6.0+1.2, 4.0+1.2, 0.01], center=true);
        translate([0, 0, 1.5]) cube([4.0+1.2, 2.0+1.2, 0.01], center=true);
    }
    // Z=1.5 to Z=2.0: Straight Shelf Hole
    translate([0, 0, 1.75]) cube([4.0+1.2, 2.0+1.2, 0.5], center=true);
}
""")
print_shapes()
