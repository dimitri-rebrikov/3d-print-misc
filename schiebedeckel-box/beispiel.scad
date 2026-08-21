// Test: schiebedeckel-box als Bibliothek nutzen
// - use statt include (nur Module importieren, keine Variablen-Kollision)
// - Parametrierung über Modul-Argumente
// - Löcher bohren via difference()
include <BOSL2/std.scad>
$fn = 32;   // eigenes $fn — die Bibliothek überschreibt es NICHT

use <schiebedeckel-box.scad>

difference() {
    // Nur die Kiste, andere Maße:
    schiebedeckel_box(breite = 200, tiefe = 120, hoehe = 30, wand = 3, teil = "kiste");
    // 4 Montagelöcher durch den Boden
    for (x = [-75, 75], y = [-40, 40])
        translate([x, y, -1]) cyl(d = 5, h = 10);
}
