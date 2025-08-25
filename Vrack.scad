// =============================================================================
// --- Parameters ---
// =============================================================================

// --- VanMoof Light Dimensions (in mm) ---
light_diameter = 50;      // The exact diameter of your circular light.
light_holder_depth = 30;  // How deep the cradle holding the light should be.

// --- Racktime Mount Dimensions (in mm) ---
rack_plate_width = 75;
rack_hole_spacing = 50;   // The distance between the center of the two screw holes on your rack.
rack_screw_diameter = 6;  // The diameter of the screw threads (e.g., 5 for an M5 screw).
rack_screw_head_diameter = 10; // The diameter of the flat top of the screw head.
rack_screw_head_depth = 3;  // The height of the screw head (for countersinking).

// --- General Design Parameters (in mm) ---
wall_thickness = 3;       // General thickness for walls. 3-5mm is good for strength.
holder_offset = 5;       // How far back the light sits from the mounting plate.

// --- Tolerances & Quality ---
fit_tolerance = 0.4;      // Extra space to add to holes and fittings for a better fit.
$fn = 100;                // The resolution of the curves. Higher is smoother.

// =============================================================================
// --- Model Generation --- (No need to edit below this line)
// =============================================================================


plate_height = rack_screw_head_diameter + wall_thickness;
holder_outer_d = light_diameter + 2 * wall_thickness;
light_holder_translate = [
            rack_plate_width / 2, 
            light_diameter / 2 + 2 * wall_thickness,
            - light_holder_depth
        ];

module base() {
    hull() {
        // 1. Create the solid base plate
        cube([rack_plate_width, plate_height, wall_thickness]);
    
        // 2. Solid cylinder for holding the light
        translate(light_holder_translate)
            cylinder(h = light_holder_depth + wall_thickness, d = holder_outer_d);
    }
}

// --- Module: Mounting Plate ---
// Creates the flat plate that attaches to the bike rack.
module van_rack() {

    
    difference() {
        base();
        
        // 3. Create the two screw holes
        for (x_pos = 
                [
                    (rack_plate_width - rack_hole_spacing) / 2, 
                    (rack_plate_width + rack_hole_spacing) / 2
                ]
            ) {
            // Main screw hole
            translate([x_pos, plate_height / 2, wall_thickness * 2])
                rotate([0,180,0])
                    cylinder(h = light_holder_depth, d = rack_screw_diameter + fit_tolerance);
            
            // Countersink for the screw head
            translate([x_pos, plate_height / 2, -rack_screw_head_depth])
                rotate([0,180,0])
                    cylinder(h = light_holder_depth, d = rack_screw_head_diameter + fit_tolerance);
        }
        
        // Inner cylinder (for the light)
        translate(light_holder_translate + [0, 0, -wall_thickness]) // Push down slightly to ensure a clean cut
            cylinder(h = light_holder_depth + wall_thickness, d = light_diameter + fit_tolerance);
    }
}


// --- Execute the final assembly module to create the model ---
van_rack();

// --- Echo dimensions for verification ---
echo(str("Model Overall Width: ", rack_hole_spacing + wall_thickness * 2, " mm"));
echo(str("Model Overall Height: ", light_diameter + wall_thickness, " mm"));