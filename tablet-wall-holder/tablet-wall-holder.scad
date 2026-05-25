// ============================================================
// Tablet Wall Holder — Huawei MediaPad M5 Lite (BAH2-W19)
// See README.md for design description.
// ============================================================

// --- Tablet Dimensions (Huawei MediaPad M5 Lite BAH2-W19) ---
tablet_width   = 162.2;
tablet_height  = 243.4;
tablet_depth   = 7.7;

// --- Screen Area ---
screen_width   = 136;
screen_height  = 218;

// --- Clearance ---
clearance      = 1.0;

// --- Wall Thicknesses ---
back_thickness  = 5.0;   // backplate thickness (Z direction)
wall_thickness  = 3.0;   // side wall thickness (X/Y direction)
front_thickness = 2.0;   // front bezel thickness (Z direction)

// --- Screw Holes ---
screw_dia      = 3.0;  // shaft diameter (3mm screw)
screw_head_dia = 7.0;  // head recess diameter (7mm head)
screw_head_dep = 3.0;  // head recess depth (3mm head height)

// --- Screw Position ---
// Screws are positioned ~5mm from the screen window edge,
// so they are visible/accessible through the frontplate opening.
screw_margin   = 5.0;  // distance from screen window edge to screw center

// --- USB-C Cutout ---
usb_width      = 16;
usb_height     = 10;
usb_from_right = 27;  // from RIGHT edge of tablet to USB-C center

// --- Backplate Inner Cutout Margin ---
// The backplate inner cutout must be wider than the screw position
// so the screw holes are within the backplate frame.
// Holes shall be not nearer than 5mm to the edge of the back panel.
backplate_margin = 5.0; // extra margin beyond screw center

// ============================================================
// DERIVED DIMENSIONS
// ============================================================

// Cavity dimensions (where the tablet sits)
cavity_w = tablet_width  + 2 * clearance;
cavity_h = tablet_height + clearance;  // open at top (+1mm at top)

// Outer dimensions of the holder (same for all frames)
// backplate_rim = wall_thickness so side walls are at the outer edge
outer_w = cavity_w + 2 * wall_thickness;
outer_h = cavity_h + 2 * wall_thickness;

// Cavity position (from outer edge, inward by wall_thickness)
cavity_x = wall_thickness;
cavity_y = wall_thickness;

// Frontplate inner cutout = screen window (centered on tablet)
fp_inner_x = cavity_x + clearance + (tablet_width  - screen_width)  / 2;
fp_inner_y = cavity_y + clearance + (tablet_height - screen_height) / 2;

// Screw position: ~5mm from screen window edge
screw_from_edge = fp_inner_x + screw_margin;

// Backplate inner cutout: wider than screw position by margin
backplate_inner = screw_from_edge + backplate_margin;

// USB-C center X (relative to outer left edge)
usb_cx = cavity_x + clearance + tablet_width - usb_from_right;

// ============================================================
// Helper: Outer polygon (counter-clockwise)
// ============================================================
function outer_poly(w, h) = [
    [0, 0], [w, 0], [w, h], [0, h]
];

// ============================================================
// Helper: Inner cutout polygon (counter-clockwise)
// ============================================================
function inner_poly(w, h, left, right, bottom, top) = [
    [left, bottom],
    [w - right, bottom],
    [w - right, h - top],
    [left, h - top]
];

// ============================================================
// Screw Hole Module
// Countersunk from the FRONT so screw heads are recessed
// into the backplate and accessible from the front.
// Shaft goes through the backplate only.
// ============================================================

module screw_hole() {
    // Shaft through the backplate only (3mm diameter)
    cylinder(h = back_thickness, d = screw_dia, $fn = 36);
    // Countersunk head at the front of the backplate (Z=back_thickness)
    // Conical recess for flathead screw: 3mm at bottom (shaft), 7mm at top (head)
    // 3mm deep, recessed into the backplate so it doesn't scratch the tablet
    // d1 = screw_dia (bottom, matches shaft), d2 = screw_head_dia (top, flathead)
    translate([0, 0, back_thickness - screw_head_dep])
        cylinder(h = screw_head_dep, d1 = screw_dia, d2 = screw_head_dia, $fn = 36);
}

// ============================================================
// Main Holder
// ============================================================
module tablet_holder() {
    difference() {
        union() {
            // 1. BACKPLATE — frame (not solid) against the wall
            // Outer rectangle minus inner cutout.
            // The backplate frame is broader inwards than the frontplate,
            // meaning the backplate extends further toward the center
            // than the frontplate's inner cutout (screen window).
            // This allows screw holes to be positioned in the backplate
            // area that is visible through the screen window.
            difference() {
                linear_extrude(height = back_thickness)
                    polygon(outer_poly(outer_w, outer_h));
                translate([0, 0, -0.01])
                    linear_extrude(height = back_thickness + 0.02)
                        polygon(inner_poly(outer_w, outer_h,
                            backplate_inner, backplate_inner,
                            backplate_inner, backplate_inner));
            }

            // 2. SIDE FRAME — 3-sided wall (left, right, bottom)
            // Forms the cavity for the tablet. Open at top for slide-in.
            // Cavity bottom/right/left is formed by the side frame.
            // Cavity front/back is formed by the frontplate and backplate.
            // Walls are wall_thickness wide, positioned at the CAVITY EDGE
            // (extending outward from the cavity).
            translate([0, 0, back_thickness - 0.01]) {
                // Left wall: from cavity_x - wall_thickness to cavity_x
                linear_extrude(height = tablet_depth + 0.02)
                    polygon([
                        [cavity_x - wall_thickness - 0.01, -0.01],
                        [cavity_x + 0.01, -0.01],
                        [cavity_x + 0.01, outer_h + 0.01],
                        [cavity_x - wall_thickness - 0.01, outer_h + 0.01]
                    ]);
                // Right wall: from cavity_x + cavity_w to cavity_x + cavity_w + wall_thickness
                linear_extrude(height = tablet_depth + 0.02)
                    polygon([
                        [cavity_x + cavity_w - 0.01, -0.01],
                        [cavity_x + cavity_w + wall_thickness + 0.01, -0.01],
                        [cavity_x + cavity_w + wall_thickness + 0.01, outer_h + 0.01],
                        [cavity_x + cavity_w - 0.01, outer_h + 0.01]
                    ]);
                // Bottom wall: from cavity_y - wall_thickness to cavity_y
                linear_extrude(height = tablet_depth + 0.02)
                    polygon([
                        [-0.01, cavity_y - wall_thickness - 0.01],
                        [outer_w + 0.01, cavity_y - wall_thickness - 0.01],
                        [outer_w + 0.01, cavity_y + 0.01],
                        [-0.01, cavity_y + 0.01]
                    ]);
            }

            // 3. FRONTPLATE — bezel-hiding frame
            // Sits on top of the side walls.
            // Same outer dimensions as backplate (all frames same outer size).
            // Inner cutout is the screen window, covering the tablet's
            // black bezel around the screen.
            translate([0, 0, back_thickness + tablet_depth]) {
                difference() {
                    linear_extrude(height = front_thickness)
                        polygon(outer_poly(outer_w, outer_h));
                    translate([0, 0, -0.01])
                        linear_extrude(height = front_thickness + 0.02)
                            polygon(inner_poly(outer_w, outer_h,
                                fp_inner_x, outer_w - fp_inner_x - screen_width,
                                fp_inner_y, outer_h - fp_inner_y - screen_height));
                }
            }
        }

        // USB CUTOUT — at the BOTTOM of the model
        // On the side frame ONLY (not through backplate or frontplate)
        // Positioned at the bottom wall, extending into the cavity
        // for USB-C plug clearance.
        // Y: from slightly below bottom wall to cavity_y + usb_height
        // Z: from back_thickness (side frame start) to back_thickness + tablet_depth
        translate([usb_cx - usb_width/2, cavity_y - wall_thickness - 0.02, back_thickness - 0.01])
            cube([usb_width, wall_thickness + usb_height + 0.02, tablet_depth + 0.02]);

        // 4 SCREW HOLES — at the 4 corners of the backplate frame
        // Positioned more inwards than the frontplate's inner cutout,
        // so they are visible/accessible from the front through the
        // screen window opening of the frontplate.
        translate([screw_from_edge, screw_from_edge, 0]) screw_hole();
        translate([outer_w - screw_from_edge, screw_from_edge, 0]) screw_hole();
        translate([screw_from_edge, outer_h - screw_from_edge, 0]) screw_hole();
        translate([outer_w - screw_from_edge, outer_h - screw_from_edge, 0]) screw_hole();
    }
}

// Render
tablet_holder();
