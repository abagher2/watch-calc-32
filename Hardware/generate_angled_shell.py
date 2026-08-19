#!/usr/bin/env python3
import os

def generate_shell_scad():
    scad = """
// Angled Bottom Shell for WatchCalc 32
$fn = 60;

// PCB Dimensions
pcb_width = 95;
pcb_length = 180;
pcb_thickness = 1.6;

// Case Dimensions
wall_thickness = 3;
bottom_thickness = 3;
clearance = 0.5; // Gap around PCB

case_width = pcb_width + 2*clearance + 2*wall_thickness;
case_length = pcb_length + 2*clearance + 2*wall_thickness;

// Angled Profile (Wedge)
wedge_angle = 3; // Degrees
front_height = bottom_thickness + 3; // Minimum height at the front

// Components Depth
mcu_depth = 12; // Deep cavity for MCU, battery, display pins
mcu_y_start = 135; // Rough start of MCU area from bottom

// TPU Feet
feet_diameter = 10;
feet_depth = 1.5;
feet_inset = 10;

module wedge_profile() {
    // A 2D profile of the angled case
    polygon(points=[
        [0, 0],
        [case_length, 0],
        [case_length, front_height + case_length * tan(wedge_angle)],
        [0, front_height]
    ]);
}

module shell() {
    difference() {
        // Main Body (Extruded Wedge)
        translate([-case_width/2, -case_length/2, 0])
            rotate([90, 0, 90])
            linear_extrude(height=case_width)
            wedge_profile();
            
        // PCB Cavity
        // Center the PCB at Z = angled top - pcb_thickness
        // To cut into the angled face, we translate and rotate
        translate([0, 0, front_height])
        rotate([-wedge_angle, 0, 0])
        union() {
            // Main PCB cutout
            translate([0, 0, 10]) // Go high enough to cut through the top
                cube([pcb_width + 2*clearance, pcb_length + 2*clearance, 20], center=true);
                
            // Component cavity (under PCB)
            translate([0, 0, -2.5]) // Deep enough for switches and generic bottom parts
                cube([pcb_width - 4, pcb_length - 4, 5], center=true);
                
            // Deep cavity for MCU, Battery, and Display
            translate([0, case_length/2 - 30, -mcu_depth/2])
                cube([pcb_width - 4, 60, mcu_depth], center=true);
        }
        
        // TPU Feet Cutouts (on the flat bottom)
        translate([-case_width/2 + feet_inset, -case_length/2 + feet_inset, -0.1])
            cylinder(d=feet_diameter, h=feet_depth + 0.1);
        translate([case_width/2 - feet_inset, -case_length/2 + feet_inset, -0.1])
            cylinder(d=feet_diameter, h=feet_depth + 0.1);
        translate([-case_width/2 + feet_inset, case_length/2 - feet_inset, -0.1])
            cylinder(d=feet_diameter, h=feet_depth + 0.1);
        translate([case_width/2 - feet_inset, case_length/2 - feet_inset, -0.1])
            cylinder(d=feet_diameter, h=feet_depth + 0.1);
            
        // Screw holes for Faceplate in the corners of the walls
        // 4 corners, 2mm diameter for M2/M3 self-tapping or inserts
        translate([-case_width/2 + wall_thickness/2, -case_length/2 + wall_thickness/2, 0])
            rotate([-wedge_angle, 0, 0]) translate([0,0,-10]) cylinder(d=2.4, h=30);
        translate([case_width/2 - wall_thickness/2, -case_length/2 + wall_thickness/2, 0])
            rotate([-wedge_angle, 0, 0]) translate([0,0,-10]) cylinder(d=2.4, h=30);
        translate([-case_width/2 + wall_thickness/2, case_length/2 - wall_thickness/2, 0])
            rotate([-wedge_angle, 0, 0]) translate([0,0,-10]) cylinder(d=2.4, h=50);
        translate([case_width/2 - wall_thickness/2, case_length/2 - wall_thickness/2, 0])
            rotate([-wedge_angle, 0, 0]) translate([0,0,-10]) cylinder(d=2.4, h=50);
    }
}

shell();

"""
    return scad

def generate_tpu_feet():
    scad = """
// TPU Feet for WatchCalc 32
$fn = 60;

feet_diameter = 10;
feet_thickness = 2; // 1.5mm goes into the case, 0.5mm sticks out
tolerance = -0.2; // Make slightly smaller to fit into the socket snugly

module tpu_foot() {
    cylinder(d=feet_diameter + tolerance, h=feet_thickness);
}

// Print 4 feet
translate([-10, 10, 0]) tpu_foot();
translate([10, 10, 0]) tpu_foot();
translate([-10, -10, 0]) tpu_foot();
translate([10, -10, 0]) tpu_foot();
"""
    return scad

if __name__ == "__main__":
    os.makedirs("output/cases", exist_ok=True)
    with open("output/cases/angled_shell.scad", "w") as f:
        f.write(generate_shell_scad())
    with open("output/cases/tpu_feet.scad", "w") as f:
        f.write(generate_tpu_feet())
    print("✅ Generated angled_shell.scad and tpu_feet.scad!")
