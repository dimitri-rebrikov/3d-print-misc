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
back_thickness  = 4.0;   // backplate thickness (Z direction)
wall_thickness  = 3.0;   // side wall thickness (X/Y direction)
front_thickness = 2.0;   // front bezel thickness (Z direction)

// --- Corner Rounding ---
outer_radius = 5.0;  // outer corner rounding radius (vertical edges)
inner_radius = 2.0;  // screen window inner corner rounding radius

// --- Screw Holes ---
screw_dia      = 3.0;  // shaft diameter (3mm screw)
screw_head_dia = 7.0;  // head recess diameter (7mm head)
screw_head_dep = 3.5;  // head recess depth (3mm head height + 0.5mm below surface)
screw_clearance      = 1.0; // extra clearance for shaft (3D printing tolerance)
screw_head_clearance = 0.5; // extra clearance for screw head

// --- Screw Position ---
// Screws are positioned ~5mm from the screen window edge,
// so they are visible/accessible through the frontplate opening.
screw_margin   = 5.0;  // distance from screen window edge to screw center

// --- Camera Groove ---
// The tablet has a main camera on the back near the bottom edge.
// It protrudes ~1mm above the surface. A groove in the backplate
// (front-facing surface) provides clearance so the tablet can slide in.
// The groove runs from the top of the backplate all the way down
// to the inner surface of the bottom side wall.
camera_dia          = 12.0;  // camera bump diameter
camera_from_left    = 16.0;  // camera center from LEFT edge of tablet
camera_clearance    = 0.5;   // extra clearance around camera bump
camera_depth        = 1.5;   // groove depth (>1mm camera protrusion)

// --- USB-C Cutout ---
usb_width      = 16;
usb_height     = 10;
usb_from_right = 27;  // from RIGHT edge of tablet to USB-C center

// --- Backplate Inner Cutout Margin ---
// The backplate inner cutout must be wider than the screw position
// so the screw holes are within the backplate frame.
// Holes shall be not nearer than 5mm to the edge of the back panel.
backplate_margin = 5.0; // extra margin beyond screw center

// --- Screw Position Margin from Camera Groove ---
// Screws must be more inwards than the camera groove.
// This margin ensures the screw head (radius = screw_head_dia/2)
// does not overlap with the groove.
camera_screw_margin = screw_head_dia / 2 + 5.0; // 5mm gap from screw head edge to groove edge

// ============================================================
// DERIVED DIMENSIONS
// ============================================================

// Cavity dimensions (where the tablet sits)
cavity_w = tablet_width  + 2 * clearance;
cavity_h = tablet_height + clearance;  // open at top (+1mm at top)
cavity_d = tablet_depth  + clearance;  // depth clearance for easy slide-in

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

// Camera groove position (center X in holder coordinates)
camera_cx = cavity_x + clearance + camera_from_left;
camera_groove_w = camera_dia + camera_clearance;  // groove width
camera_groove_x = camera_cx - camera_groove_w / 2;  // groove left edge
camera_groove_right = camera_cx + camera_groove_w / 2;  // groove right edge

// Screw position: derived from BOTH constraints:
// 1) Must be visible through screen window: fp_inner_x + screw_margin
// 2) Must be more inwards than camera groove: camera_groove_right + camera_screw_margin
// The MAX ensures both constraints are satisfied.
screw_from_edge = max(fp_inner_x + screw_margin, camera_groove_right + camera_screw_margin);

// Backplate inner cutout: wider than screw position by margin
backplate_inner = screw_from_edge + backplate_margin;

// USB-C center X (relative to outer left edge)
usb_cx = cavity_x + clearance + tablet_width - usb_from_right;

// ============================================================
// Helper: Rounded rectangle (hull of 4 circles)
// ============================================================
module rounded_rect(w, h, r) {
    hull() {
        translate([r, r]) circle(r = r);
        translate([w - r, r]) circle(r = r);
        translate([r, h - r]) circle(r = r);
        translate([w - r, h - r]) circle(r = r);
    }
}

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
    // Shaft through the backplate only (3mm + clearance)
    cylinder(h = back_thickness, d = screw_dia + screw_clearance, $fn = 36);
    // Countersunk head at the front of the backplate (Z=back_thickness)
    // Conical recess for flathead screw: 3mm at bottom (shaft), 7mm at top (head)
    // 3mm deep, recessed into the backplate so it doesn't scratch the tablet
    // d1 = screw_dia + clearance (bottom, matches shaft), d2 = screw_head_dia + clearance (top)
    translate([0, 0, back_thickness - screw_head_dep])
        cylinder(h = screw_head_dep, d1 = screw_dia + screw_clearance, d2 = screw_head_dia + screw_head_clearance, $fn = 36);
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
                // Backplate solid (rounded outer corners)
                linear_extrude(height = back_thickness)
                    rounded_rect(outer_w, outer_h, outer_radius);

                // Inner cutout (hollow frame)
                translate([0, 0, -0.01])
                    linear_extrude(height = back_thickness + 0.02)
                        polygon(inner_poly(outer_w, outer_h,
                            backplate_inner, backplate_inner,
                            backplate_inner, backplate_inner));

                // Camera groove — on the front-facing surface of the backplate
                // (Z = back_thickness - camera_depth to back_thickness)
                // Runs from the TOP of the backplate all the way down
                // to the inner surface of the bottom side wall (cavity_y).
                // Provides clearance for the camera bump so the tablet can slide in.
                translate([camera_groove_x, cavity_y - 0.01, back_thickness - camera_depth - 0.01])
                    linear_extrude(height = camera_depth + 0.02)
                        polygon([
                            [-0.01, -0.01],
                            [camera_groove_w + 0.02, -0.01],
                            [camera_groove_w + 0.02, outer_h - cavity_y + 0.02],
                            [-0.01, outer_h - cavity_y + 0.02]
                        ]);
            }

            // 2. SIDE FRAME — 3-sided wall (left, right, bottom)
            // Forms the cavity for the tablet. Open at top for slide-in.
            // Cavity bottom/right/left is formed by the side frame.
            // Cavity front/back is formed by the frontplate and backplate.
            // Walls are wall_thickness wide, positioned at the CAVITY EDGE
            // (extending outward from the cavity).
            // Uses intersection with rounded_rect so outer edges are rounded
            // matching the backplate and frontplate.
            translate([0, 0, back_thickness - 0.01]) {
                intersection() {
                    // Outer shape (rounded, matching backplate/frontplate)
                    linear_extrude(height = cavity_d + 0.02)
                        rounded_rect(outer_w, outer_h, outer_radius);
                    // Three wall polygons (sharp, clipped by rounded outer shape)
                    union() {
                        // Left wall: from cavity_x - wall_thickness to cavity_x
                        linear_extrude(height = cavity_d + 0.02)
                            polygon([
                                [cavity_x - wall_thickness - 0.01, -0.01],
                                [cavity_x + 0.01, -0.01],
                                [cavity_x + 0.01, outer_h + 0.01],
                                [cavity_x - wall_thickness - 0.01, outer_h + 0.01]
                            ]);
                        // Right wall: from cavity_x + cavity_w to cavity_x + cavity_w + wall_thickness
                        linear_extrude(height = cavity_d + 0.02)
                            polygon([
                                [cavity_x + cavity_w - 0.01, -0.01],
                                [cavity_x + cavity_w + wall_thickness + 0.01, -0.01],
                                [cavity_x + cavity_w + wall_thickness + 0.01, outer_h + 0.01],
                                [cavity_x + cavity_w - 0.01, outer_h + 0.01]
                            ]);
                        // Bottom wall: from cavity_y - wall_thickness to cavity_y
                        linear_extrude(height = cavity_d + 0.02)
                            polygon([
                                [-0.01, cavity_y - wall_thickness - 0.01],
                                [outer_w + 0.01, cavity_y - wall_thickness - 0.01],
                                [outer_w + 0.01, cavity_y + 0.01],
                                [-0.01, cavity_y + 0.01]
                            ]);
                    }
                }
            }

            // 3. FRONTPLATE — bezel-hiding frame
            // Sits on top of the side walls.
            // Same outer dimensions as backplate (all frames same outer size).
            // Inner cutout is the screen window, covering the tablet's
            // black bezel around the screen.
            // Both outer and inner corners are rounded.
            translate([0, 0, back_thickness + cavity_d]) {
                difference() {
                    linear_extrude(height = front_thickness)
                        rounded_rect(outer_w, outer_h, outer_radius);
                    translate([fp_inner_x, fp_inner_y, -0.01])
                        linear_extrude(height = front_thickness + 0.02)
                            rounded_rect(screen_width, screen_height, inner_radius);
                }
            }
        }

        // USB CUTOUT — at the BOTTOM of the model
        // Positioned at the bottom wall, extending into the cavity
        // for USB-C plug clearance.
        // Shifted 1mm towards the backplate (negative Z) so it digs
        // slightly into the backplate for better cable clearance.
        // Y: from slightly below bottom wall to cavity_y + usb_height
        // Z: from back_thickness - 1 to back_thickness + cavity_d
        translate([usb_cx - usb_width/2, cavity_y - wall_thickness - 0.02, back_thickness - 1.01])
            cube([usb_width, wall_thickness + usb_height + 0.02, cavity_d + 1.02]);

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

// Render is done in render.scad (include this file and call tablet_holder())
