// Render-Helper: Längsschnitt durch die Box (y=0-Ebene), zeigt das Profil:
// Deckel, Zugkante, Schlitz, Steg und Nuten in einem Schnittbild
include <BOSL2/std.scad>
include <schiebedeckel-box.scad>
difference() {
    union() { kiste(); deckel(); }
    // hintere Hälfte (y > 0) wegschneiden
    translate([0, aussen_breite / 2 + 1, 0])
        cuboid([aussen_laenge + 2, aussen_breite + 2, aussen_hoehe + 2]);
}
