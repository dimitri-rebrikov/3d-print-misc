// Render-Helper: Querschnitt (x=0-Ebene) — zeigt die Nut- und Deckel-Fasen im Profil
include <BOSL2/std.scad>
$fn = 48;
include <schiebedeckel-box.scad>
difference() {
    schiebedeckel_box();
    // hintere Hälfte (x > 0) wegschneiden
    translate([breite / 2 + 1, 0, 0])
        cuboid([breite + 2, tiefe + 2, hoehe + 2]);
}
