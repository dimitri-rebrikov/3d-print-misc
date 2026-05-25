# Tablet Wall Holder

**For:** Huawei MediaPad M5 Lite (BAH2-W19)  
**Orientation:** Portrait

## Tablet Specs (BAH2-W19)

| Spec | Value |
|------|-------|
| Dimensions | 243.4 × 162.2 × 7.7 mm |
| Display (screen) | 10.1″ IPS, 1920×1200 px — 136 × 218 mm (estimated) |
| Bezel (side) | ~13.1 mm (black border around screen) |
| Bezel (top/bottom) | ~12.7 mm (black border around screen) |
| USB-C | Bottom edge, right side (27 mm from right edge) |
| Headphone jack | Bottom edge, next to USB-C |

## Description

A wall-mounted holder for a tablet used as a home automation panel. The tablet slides in from the top. The holder builds an envelope around the tablet with an open window for the screen on the front. It has almost the same size as the tablet.

## Design

### 1. Backplate

A frame (not solid) against the wall. Contains 4 screw holes at the corners. Screw heads are recessed into the backplate (countersunk from the front) so they don't scratch the tablet. Screw holes are positioned more inwards than the inner cutout of the frontplate, so they are visible and accessible by a screwdriver from the front through the cutout of the front plate (approx. 5 mm away from any edge of the front panel). The holes shall be no nearer than 5 mm to the edge of the back panel. The backplate frame is broader inwards than the frontplate.

**Screw specs:** Flathead, conical shaft.  
- Screw diameter: 3 mm  
- Head diameter: 7 mm  
- Head height: 3 mm

### 2. Side Frame

3-sided wall (left, right, bottom) forming the cavity. Open at top for tablet slide-in. The dimensions are such that the tablet can be slid in and held in place without wiggling front/back or left/right.

### 3. Frontplate

Bezel-hiding frame covering the tablet's black bezel around the screen. Sits on top of the side walls.

### 4. USB Cutout

At the bottom of the model, on the side frame only (not through backplate or frontplate), aligned with the tablet's USB-C charging port.

### 5. Tablet

The tablet slides between the backplate and the frontplate into the holder and is secured sideways and from the bottom by the side frame. The cavity for the tablet (bottom, right, left) is formed by the side frame. The cavity (front, back) is formed by the back and front panel. The frontplate secures the tablet from the front and also hides the black bezel of the tablet but keeps the screen of the tablet completely accessible. If the tablet is not in the holder, the holes for the screws are visible and accessible so the holder can be mounted on the wall.

## Implementation in SCAD

- Use polygons, extrude, and difference for the elements.
- All frames/plates have the same outer size and only differ inwards.
- The wall shall be 3 mm thick.
- The front panel shall be 2 mm thick.
- The back panel shall be thick enough to keep the screw head inside.
- Calculate all dimensions in dependency to each other so the model is stable on parameter changes.

## Printing

Print with Z=0 (back) on the bed. Use brim. Enable bridge settings.
