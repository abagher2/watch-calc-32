import re

with open("generate_scad.py", "r") as f:
    text = f.read()

# Find the top_cap definition
start = text.find('    top_cap = f"""')
end = text.find('// ── BATTERY BUCKET', start)

if start != -1 and end != -1:
    new_top_cap = """    top_cap = f\"\"\"
// WatchCalc 32 End Cap — v8 (FLUSH PLUG inside chassis)
// Cap extends from Z=ch-cap_t to Z=ch. 
// Secured by lateral M3 screws at Z=138.550.
$fn = 24;
cw    = {cw:.3f};
D     = {CHASSIS_D:.3f}; // 14.9
wall  = {WALL:.3f};
cap_t = {cap_t_val};
ch    = {fp_h + WALL:.3f}; // 145.350

module top_cap() {{
    union() {{
        // ── MAIN PLATE (Flush Plug, Z=ch-cap_t to Z=ch) ─────────
        // Fits perfectly inside Tier 1/2/3 cavity
        translate([wall, {FRONT_LIP}, ch - cap_t])
            cube([cw - 2*wall, D - wall - {FRONT_LIP}, cap_t]);

        // ── FRONT LIP (Drops down into bezel window to secure Faceplate) ──────
        // Completes the chassis O-frame since the chassis cannot have a bridged top lip.
        // Drops down to Z=139 to trap the Faceplate (which ends at Z=140).
        translate([wall + 2.0, 0, 139.0])
            cube([cw - 2*wall - 4.0, {FRONT_LIP}, ch - 139.0]);

        // ── SCREW BOSSES (Drop down into chassis Tier 3 to Z=135) ─────────────────
        // The top two chassis screws (at Z=138.550) pass through the rear wall, 
        // through these blocks, then into the PCB and Faceplate.
        // NOTE: The horizontal pegs have been removed so the cap can drop in straight from above!
        
        // Left Standoff
        difference() {{
            // Thick Base: From back wall to PCB (Y = pt + PCB_T)
            translate([wall + 7.0 - 3.0, {pt} + {PCB_T}, 135.0]) 
                cube([6.0, D - wall - {pt} - {PCB_T} + 0.1, ch - cap_t - 135.0 + 0.1]);
            // Clearance hole for M2 screw (d=2.2)
            translate([wall + 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        // Right Standoff
        difference() {{
            translate([cw - wall - 7.0 - 3.0, {pt} + {PCB_T}, 135.0]) 
                cube([6.0, D - wall - {pt} - {PCB_T} + 0.1, ch - cap_t - 135.0 + 0.1]);
            translate([cw - wall - 7.0, D + 0.1, 138.550]) rotate([90, 0, 0]) cylinder(d=2.2, h=D + 2.0);
        }}
        
        """
    text = text[:start] + new_top_cap + text[end:]

with open("generate_scad.py", "w") as f:
    f.write(text)
