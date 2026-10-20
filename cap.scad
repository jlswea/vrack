// =============================================================================
// Closing cap for the sawn-off light tube on the bike frame.
//
// One continuous hulled body: the domed end and the clamp boss blend into a
// single teardrop, the same way the light holder blends its plate into the
// barrel. The clamp slit doubles as the cable canal and the drain, so the face
// stays closed. An internal stop ring holds the tube rim short of the face;
// the cable turns in that plenum and leaves sideways through the slit.
//
// FIT IT WITH THE SLIT AND BOLT POINTING DOWN.
// =============================================================================

// --- Tube (measured) ---
// Slightly oval: 51.0 x 50.5. The bore is cut to the LARGER diameter so the cap
// slides on, and the clamp pulls it down onto the smaller one.
tube_od        = 51;
tube_id        = 47;    // Inner diameter (used only for the centring lip).
fit_clearance  = 0.4;   // Slip fit; the clamp takes up the rest.

// --- Cap ---
skirt_length   = 14;    // Depth of the skirt / underside of the face.
cap_wall       = 2.5;
dome_height    = 5;     // Rise of the domed end above the barrel.

// --- Rim stop / cable plenum ---
plenum_height  = 4;     // Space between the tube rim and the face.
stop_id        = 49;    // Shoulder the tube rim butts against.

// --- Centring lip (reaches INSIDE the tube, past the rim) ---
// Measured clearance to the inner plastic cover is 3.6 mm, so 2.5 mm leaves
// roughly 1 mm of air in front of it. Set to 0 to drop the lip entirely.
lip_insert     = 0;     // Dropped: the clamp locates the cap, and the lip ends
                        // feathered to a knife edge where the slit crossed them.
lip_clearance  = 0.6;
lip_wall       = 2;
lip_setback    = 3;     // Lip ends stop short of the slit, so the slit does not
                        // shave them to a feather edge.

// --- Clamp slit = cable canal = drain ---
// The oval tube means tightening takes up ~2.0 mm of circumference, so the gap
// is sized to still leave ~3.5 mm of open canal once clamped.
clamp_gap      = 5.5;
clamp_angle    = 0;     // 0 = slit and bolt point down when fitted.
ear_thickness  = 4;
ear_height     = 9;     // How far the boss stands off the barrel.
boss_d         = 10;
boss_z         = 6.5;   // Centre of the boss, from the open end.
bolt_d         = 3.4;   // M3 clearance. M3 halves the thin-rim area vs M4.
nut_af         = 5.8;   // M3 nut across flats + clearance.
nut_depth      = 2.6;
nut_lead       = 0.6;   // 45 deg chamfer at the mouth of the nut pocket.
// The clamp lug is a PRISM: smooth in side profile, but with flat ends square
// to the bolt. Hulling it into the dome instead left knife edges wherever the
// blend ran tangent to the boss, and overhung the nut pocket.
lug_style      = "hull";   // "hull" = carved tail (this). "prism" = flat-ended
                           // lug, less pretty but passes 0.6 mm everywhere.  // "hull" = carved look, "prism" = flat-ended lug.
access_d       = 8;
lug_root_w     = 8;     // How far the lug profile reaches into the barrel wall.
                        // not tangentially, which would feather to an edge.

$fn = 120;

// --- Derived ---
cap_bore   = tube_od + fit_clearance;
cap_od     = cap_bore + 2 * cap_wall;
barrel_top = skirt_length + 1;          // Where the dome takes over.
total_len  = barrel_top + dome_height;
stop_z     = skirt_length - plenum_height;
lip_od     = tube_id - lip_clearance;
lip_bottom = stop_z - lip_insert;
bolt_y     = cap_od / 2 + ear_height * 0.55;
ear_span   = clamp_gap + 2 * ear_thickness;

// Domed barrel: cylinder blended into a flattened ellipsoid.
module shell() {
    hull() {
        cylinder(h = barrel_top, d = cap_od);
        translate([0, 0, barrel_top])
            resize([cap_od, cap_od, 2 * dome_height]) sphere(d = cap_od);
    }
}

module boss(span) {
    rotate([0, 0, clamp_angle])
        translate([-span / 2, bolt_y, boss_z])
            rotate([0, 90, 0]) cylinder(h = span, d = boss_d);
}

// Clamp lug: a 2D profile (round boss blended into the barrel wall) extruded
// straight across the slit, so both end faces are flat and square to the bolt.
module ear_prism() {
    rotate([0, 0, clamp_angle])
        rotate([0, -90, 0])
            linear_extrude(height = ear_span, center = true)
                hull() {
                    translate([boss_z, bolt_y]) circle(d = boss_d);
                    translate([0, cap_od / 2 - lug_root_w])
                        square([barrel_top, lug_root_w]);
                }
}

module outer_body() {
    if (lug_style == "hull") hull() { shell(); boss(ear_span); }
    else                     union() { shell(); ear_prism(); }
}

// Skirt bore up to the stop, then the wider plenum under the face.
module tube_bore() {
    translate([0, 0, -1]) cylinder(h = stop_z + 1, d = cap_bore);
    translate([0, 0, stop_z]) cylinder(h = plenum_height, d = stop_id);
}

module centring_lip() {
    if (lip_insert > 0)
        difference() {
            translate([0, 0, lip_bottom])
                difference() {
                    cylinder(h = skirt_length - lip_bottom + 1, d = lip_od);
                    translate([0, 0, -1])
                        cylinder(h = skirt_length - lip_bottom + 3, d = lip_od - 2 * lip_wall);
                }
            rotate([0, 0, clamp_angle])
                translate([-(clamp_gap / 2 + lip_setback), 0, lip_bottom - 1])
                    cube([clamp_gap + 2 * lip_setback, lip_od,
                          skirt_length - lip_bottom + 3]);
        }
}

// Splits the skirt for clamping, crosses the lip and stop ring so the cable can
// leave the plenum, and drains the cap at its lowest point.
// Inside the barrel it stops under the face, so the face stays closed; outboard
// of the barrel it runs the full height, or the hulled tail would bridge the two
// halves above the slit and the clamp could not close.
module slit() {
    rotate([0, 0, clamp_angle]) {
        translate([-clamp_gap / 2, 0, -1])
            cube([clamp_gap, cap_od / 2, skirt_length + 1]);
        translate([-clamp_gap / 2, cap_od / 2 - 0.5, -1])
            cube([clamp_gap, bolt_y + boss_d, total_len + 2]);
    }
}

module bolt_hole() {
    rotate([0, 0, clamp_angle])
        translate([0, bolt_y, boss_z])
            rotate([0, 90, 0]) {
                translate([0, 0, -ear_span]) cylinder(h = 2 * ear_span, d = bolt_d);
                translate([0, 0, ear_span / 2 - nut_depth])
                    cylinder(h = nut_depth + 1, d = nut_af / cos(30), $fn = 6);
                // Lead-in so the nut drops in without fighting the mouth.
                translate([0, 0, ear_span / 2 - nut_lead])
                    cylinder(h = nut_lead + 1, $fn = 6,
                             d1 = nut_af / cos(30),
                             d2 = (nut_af + 2 * nut_lead) / cos(30));
                if (lug_style == "hull") {
                    translate([0, 0, ear_span / 2]) cylinder(h = 40, d = access_d);
                    translate([0, 0, -ear_span / 2 - 40]) cylinder(h = 40, d = access_d);
                }
            }
}

module tube_cap() {
    difference() {
        union() {
            // Bore first, then add the lip, or the bore would cut it away.
            difference() { outer_body(); tube_bore(); }
            centring_lip();
        }
        slit();
        bolt_hole();
    }
}

tube_cap();

echo(str("Cap OD ", cap_od, " / bore ", cap_bore, " / height ", total_len,
         " / tube engages ", stop_z, " mm / plenum ", plenum_height, " mm"));
echo(str("Canal ", clamp_gap, " mm open, approx ", clamp_gap - 2.04,
         " mm once clamped onto the oval tube"));
