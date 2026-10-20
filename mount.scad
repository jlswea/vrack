// =============================================================================
// --- Parameters ---
// =============================================================================

// --- VanMoof Light Dimensions (in mm) ---
light_body_diameter   = 46.5;  // Measured OD of the light body (the part that goes in).
light_insertion_depth = 33.6;  // Body depth from behind the front lip to the rear face.
light_fit_tolerance   = 1.0;   // Clearance on diameter -> bore = 47.5 (original tube ID).
cavity_depth_total    = 37;    // Total bore depth (33.6 body + 3.4 behind for cable).

// --- Tube ---
tube_wall     = 2.25;   // Body wall (2.25 -> 52 mm OD).
rim_od        = 50;     // OD at the front rim, flush with the light's 50 mm lip.
rim_taper     = 6;      // Length over which the rim OD grows to the body OD.
back_wall     = 3;      // Closed end of the tube (faces the rack).
light_offset_y = 3;     // Gap between the plate edge and the top of the tube.
light_offset_z = 5;     // How far the closed end sits below the plate plane.

// --- Side retention screw (same as the original tube) ---
side_screw_hole_d      = 9.5;  // Clearance hole for the light's side screw.
side_screw_from_rim    = 13.25; // Hole CENTRE from the front rim (8.5 edge + 9.5/2).
side_screw_angle       = 90;   // 0 = down, 90 = right side. SET THIS to match your light.
side_screw_tolerance   = 0.4;

// --- Drain / cable pass-through (through the closed back, facing the rack) ---
drain_d      = 5;    // 2 mm cable + drainage cross-section.

// --- Racktime Mount Dimensions (in mm) ---
rack_plate_width = 75;
rack_hole_spacing = 50;
rack_screw_diameter = 5;        // M5, measured 5.2.
rack_screw_head_diameter = 10;
rack_screw_head_depth = 3;
rack_screw_cutout_downward_slope = 5;

// --- General ---
wall_thickness = 3;
plate_corner_r = 6;     // Rounding of the plate corners in plan view.
plate_edge_r   = 1.4;
// Rounding of the plate's top/bottom edges (max wall_thickness/2) is above.
blend_half     = 26;    // Half-width of the plate-to-barrel blend. Wide enough to
                        // contain the screw countersinks, narrow enough that the
                        // plate corners are not swept down into thin blades.
fit_tolerance  = 0.4;

$fn = 100;

// =============================================================================
// --- Derived ---
// =============================================================================

bore_d       = light_body_diameter + light_fit_tolerance;      // 47.5
tube_od      = bore_d + 2 * tube_wall;                          // 52
cavity_depth = cavity_depth_total;                              // 37
tube_length  = cavity_depth + back_wall;
plate_height = rack_screw_head_diameter + wall_thickness;

tube_x       = rack_plate_width / 2;
tube_y       = tube_od / 2 + wall_thickness + light_offset_y;
cavity_top_z = -light_offset_z;                 // closed end of the cavity
rim_z        = cavity_top_z - cavity_depth;     // front rim (open end)
tube_top_z   = cavity_top_z + back_wall;

// =============================================================================
// --- Model ---
// =============================================================================

module tube() {
    translate([tube_x, tube_y, rim_z]) {
        // Tapered front section: flush with the light's lip at the rim.
        cylinder(h = rim_taper, d1 = rim_od, d2 = tube_od);
        translate([0, 0, rim_taper])
            cylinder(h = tube_length - rim_taper, d = tube_od);
    }
}

// Mounting plate with rounded corners and softened top/bottom edges.
module plate() {
    minkowski() {
        translate([0, 0, plate_edge_r])
            linear_extrude(height = max(0.01, wall_thickness - 2 * plate_edge_r))
                offset(r = plate_corner_r - plate_edge_r)
                    translate([plate_corner_r, plate_corner_r])
                        square([rack_plate_width  - 2 * plate_corner_r,
                                plate_height      - 2 * plate_corner_r]);
        sphere(r = plate_edge_r, $fn = 24);
    }
}

// One smooth solid: the plate and the light barrel blended by a single hull.
module base() {
    hull() { plate(); tube(); }
}

module light_cavity() {
    translate([tube_x, tube_y, rim_z - 1])
        cylinder(h = cavity_depth + 1, d = bore_d);
}

// Through-hole: the light is retained by a screw on EACH side, so this has to
// pierce both barrel walls, not just the one.
module side_screw_hole() {
    translate([tube_x, tube_y, rim_z + side_screw_from_rim])
        rotate([0, 0, side_screw_angle])
            rotate([-90, 0, 0])
                translate([0, 0, -tube_od])
                    cylinder(h = 2 * tube_od, d = side_screw_hole_d + side_screw_tolerance);
}

// Drain + cable pass-through: through the closed back, at the lowest point of the
// cavity floor, so standing water runs out towards the rack.
module drain() {
    translate([tube_x, tube_y + bore_d / 2 - drain_d / 2, cavity_top_z - 1])
        cylinder(h = back_wall + 6, d = drain_d);
}

// Recesses the screw head on the UNDERSIDE, between the plate and the rack,
// with an angled lead-in for the driver.
module countersink_hole() {
    cut_depth = 30;
    cutout = rack_screw_head_diameter + fit_tolerance;
    scaled_cutout = cutout * 1.5;
    hull(){
        cylinder(h = cut_depth, d = cutout);
        translate([-cutout / 2, 0, rack_screw_head_depth])
            hull() {
                cube([cutout, 1, cut_depth]);
                translate([-(scaled_cutout - cutout) / 2, -10, 0])
                    cube([scaled_cutout, 1, cut_depth]);
            }
        translate([0, 0, rack_screw_head_depth * 2])
            rotate([-rack_screw_cutout_downward_slope, 0, 0])
                cylinder(h = cut_depth, d = rack_screw_head_diameter + fit_tolerance);
    }
}

module van_rack() {
    difference() {
        base();

        for (x_pos = [ (rack_plate_width - rack_hole_spacing) / 2,
                       (rack_plate_width + rack_hole_spacing) / 2 ]) {
            translate([x_pos, plate_height / 2, wall_thickness * 2])
                rotate([0,180,0]) cylinder(h = 30, d = rack_screw_diameter + fit_tolerance);
            translate([x_pos, plate_height / 2, -rack_screw_head_depth])
                rotate([0,180,0]) countersink_hole();
        }

        light_cavity();
        side_screw_hole();
        drain();
    }
}

van_rack();

echo(str("Bore: ", bore_d, " mm / Tube OD: ", tube_od, " mm / Wall: ", tube_wall, " mm"));
echo(str("Overall: ", rack_plate_width, " x ", tube_y + tube_od/2, " x ", wall_thickness - rim_z, " mm"));
