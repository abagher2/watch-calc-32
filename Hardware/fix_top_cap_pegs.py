with open("generate_scad.py", "r") as f:
    text = f.read()

text = text.replace(
"""        // Left Standoff
        difference() {
            union() {
                // Thick Base: From back wall to PCB (Y = pt + PCB_T)
                // Width 6.0, drops down from ch to Z=135
                translate([wall + 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                // Thin Shaft: Passes through PCB to reach the Faceplate (Y = pt)
                translate([wall + 7.0, {FRONT_LIP} + {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }
            // Clearance hole for M2 screw (d=2.2) passes through BOTH
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }
        
        // Right Standoff
        difference() {
            union() {
                translate([cw - wall - 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                translate([cw - wall - 7.0, {FRONT_LIP} + {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }""",
"""        // Left Standoff
        difference() {
            // Thick Base: From back wall to PCB (Y = pt + PCB_T)
            // Width 6.0, drops down from ch to Z=135
            translate([wall + 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
            // Clearance hole for M2 screw (d=2.2) passes through
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }
        
        // Right Standoff
        difference() {
            translate([cw - wall - 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }""")

# Wait, `generate_scad.py` has double braces for OpenSCAD blocks inside f-strings!
text = text.replace(
"""        // Left Standoff
        difference() {{
            union() {{
                // Thick Base: From back wall to PCB (Y = pt + PCB_T)
                // Width 6.0, drops down from ch to Z=135
                translate([wall + 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                // Thin Shaft: Passes through PCB to reach the Faceplate (Y = pt)
                translate([wall + 7.0, {FRONT_LIP} + {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }}
            // Clearance hole for M2 screw (d=2.2) passes through BOTH
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // Right Standoff
        difference() {{
            union() {{
                translate([cw - wall - 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                    cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
                translate([cw - wall - 7.0, {FRONT_LIP} + {pt}, 138.550]) rotate([-90, 0, 0]) 
                    cylinder(d=3.0, h={PCB_T} + 0.1);
            }}
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}""",
"""        // Left Standoff
        difference() {{
            // Thick Base: From back wall to PCB (Y = pt + PCB_T)
            // Width 6.0, drops down from ch to Z=135
            translate([wall + 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
            // Clearance hole for M2 screw (d=2.2) passes through
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // Right Standoff
        difference() {{
            translate([cw - wall - 7.0 - 3.0, {FRONT_LIP} + {pt} + {PCB_T}, 135]) 
                cube([6.0, D - wall - {FRONT_LIP} - {pt} - {PCB_T} + 0.1, ch - 135 + 0.1]);
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}""")

with open("generate_scad.py", "w") as f:
    f.write(text)

