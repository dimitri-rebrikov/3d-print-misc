// ============================================================
// Test: Bottom portion of the tablet wall holder
// Shows the slide-in area, USB port cutout, and screw holes.
// Uses the main holder model via include.
// ============================================================

include <BOSL2/std.scad>;
include <tablet-wall-holder.scad>;

// Slice height from the bottom — enough to show:
// - Bottom wall with USB cutout
// - Bottom screw holes
// - Cavity entrance for slide-in
slice_height = 40;  // mm from bottom

// Intersect the full holder with a cube at the bottom
intersection() {
    tablet_holder();
    translate([-1, -1, -1])
        cube([outer_w + 2, slice_height + 1, back_thickness + tablet_depth + front_thickness + 2]);
}
