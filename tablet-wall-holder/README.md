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

A wall-mounted holder for a tablet used as a home automation panel. The tablet slides in from the top. So the holder builds a kind of envelope around the tablet with the open windows for the screen on the front. It has almost the same size as the tablet.

## Design

### 1. Backplate

A frame (not solid) against the wall. Contains 4 screw holes at the corners. Screw heads are recessed into the backplate (countersunk from the front) so they don't scratch the tablet. Screw holes are positioned more inwards than the inner outcut of the frontplate, so they are visible/accessible by the screwdriver from the front through the outcut of the front plate (i.e. ca 5mm away from any edge of the front panel). Also the holes shall be not nearer as 5 mm to the edged of the back panel. The backplate frame is broader inwards than the frontplate. Screw specs: Flathead, Conical shaft. Screw: 3m diameter, Head: 7mm diameter, 3mm heigth.

### 2. Side Frame

3-sided wall (left, right, bottom) forming the cavity. Open at top for tablet slide-in. The dimension are just so, that the tablet can be slided-in and holded in place without wiggling front/back or left/right.

### 3. Frontplate

Bezel-hiding frame covering the tablet's black bezel around the screen. Sits on top of the side walls.

### 4. USB Cutout

At the bottom of the model, on the side frame only (not through backplate or frontplate), aligned with the tablet's USB-C charging port.

### 5. Tablet

The tablet slided between Backplate and the Frontplate into the holder and it secured sidewards and from the bottom by the side frame. The cavity for the tablet bottom/right/left is formed by the side frame. The cavity front/back if formed by the back and front panel.
The Frontplate secures the tablet from the front and also hides the black bezel of the tablet but keeps the screen of the tablet completely accessible. If tablet is not in the holder the holes for the srews are visible/accessible so the holder can be mounted on the wall.

## Implementation is SCAD

Use polygons, extrude, differnece for the elements.

All frames/plates have the same outer size and only differs inwards.

The wall shall be 3 mm thick.
The front panel shall be 2 mm thick.
The back panel shall be thick enougth to keep the screew head head inside.

Calculate all dimensions in dependency to each other so the model is stable on parameter changes.

## Printing

Print with Z=0 (back) on the bed. Use brim. Enable bridge settings.
