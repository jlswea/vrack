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

// --- Module: Mounting Plate ---
// Creates the flat plate that attaches to the bike rack.
module mounting_plate() {
    plate_height = rack_screw_head_diameter + wall_thickness;
    
    difference() {
        // 1. Create the solid base plate
        cube([rack_plate_width, plate_height, wall_thickness]);
        
        // 2. Create the two screw holes
        for (x_pos = 
                [
                    (rack_plate_width - rack_hole_spacing) / 2, 
                    (rack_plate_width + rack_hole_spacing) / 2
                ]
            ) {
            // Main screw hole
            translate([x_pos, plate_height / 2, -wall_thickness])
                cylinder(h = wall_thickness * 3, d = rack_screw_diameter + fit_tolerance);
            
            // Countersink for the screw head
            translate([x_pos, plate_height / 2, -0.01]) // -0.01 to prevent z-fighting
                cylinder(h = rack_screw_head_depth, d = rack_screw_head_diameter + fit_tolerance);
        }
    }
}

// --- Module: Light Holder ---
// Creates the cradle for the circular light with zip-tie slots.
module light_holder() {
    holder_outer_d = light_diameter + 2 * wall_thickness;
    
    difference() {
        // 1. Create the main C-shaped cradle
        difference() {
            // Outer cylinder
            cylinder(h = light_holder_depth + wall_thickness, d = holder_outer_d);
            
            // Inner cylinder (for the light)
            translate([0, 0, -wall_thickness]) // Push down slightly to ensure a clean cut
                cylinder(h = light_holder_depth + wall_thickness, d = light_diameter + fit_tolerance);
        }
    }
}

// --- Module: The Final Assembly ---
// Combines the plate, holder, and connects them smoothly.
module van_rack() {
    
    // Y position for the center of the light holder
    holder_y_pos = (rack_screw_head_diameter + wall_thickness) / 2 + holder_offset + (light_diameter/2 + wall_thickness);
    
    union() {
        // 1. The Mounting Plate
        // Placed at the front (lower Y values)
        translate([0, 0, 0])
            mounting_plate();
        
        // 2. The Light Holder
        // Rotated and positioned behind and above the plate
        translate([rack_plate_width / 2, light_diameter / 2 + 2 * wall_thickness, - light_holder_depth])
            rotate([0, 0, 0])
                light_holder();
        
        // 3. The Connector
        // Use hull() to create a strong, smooth bridge between the two parts.
        //hull() {
            // Shape at the back of the mounting plate
            //translate([0, (rack_screw_head_diameter + wall_thickness), 0])
                //cube([rack_hole_spacing, 1, wall_thickness], center = true);

            // Shape at the bottom of the light holder
            //translate([0, holder_y_pos, light_diameter / 2])
                //cylinder(h = 1, d = light_diameter + 2 * wall_thickness, center = true);
        //}
    }
}


// --- Execute the final assembly module to create the model ---
van_rack();

// --- Echo dimensions for verification ---
echo(str("Model Overall Width: ", rack_hole_spacing + wall_thickness * 2, " mm"));
echo(str("Model Overall Height: ", light_diameter + wall_thickness, " mm"));