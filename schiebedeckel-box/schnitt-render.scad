// Render-Helper: Längsschnitt durch die Box (y=0-Ebene), zeigt das Profil:
// Deckel, Zugkante, Schlitz und Nuten in einem Schnittbild
include <BOSL2/std.scad>
$fn = 48;
include <schiebedeckel-box.scad>
difference() {
    schiebedeckel_box();
    // hintere Hälfte (y > 0) wegschneiden
    translate([0, tiefe / 2 + 1, 0])
        cuboid([breite + 2, tiefe + 2, hoehe + 2]);
}
