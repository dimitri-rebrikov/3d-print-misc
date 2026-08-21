// Schiebedeckel-Box (Domino-Stil): Kiste + Deckel, der seitlich in Führungsnuten gleitet
// BOSL2: cuboid (rounding, edges, anchor), cyl, difference
//
// Konstruktion wie bei klassischen Domino-Kästen:
//  - Führungsnuten (Taschen) in den beiden Längswänden, auf Höhe der Oberkante
//  - Einschuböffnung in der Vorderwand auf Nuthöhe (Deckel fährt durch)
//  - Deckel: Platte, die in den Nuten gleitet, mit Griffmulde in der vorstehenden Lasche
include <BOSL2/std.scad>
$fn = 48;

/* [Parameter] */
innen_laenge = 170;      // Innenlänge (mm) — Domino Double-Six: 4 Steine à 40mm + Rand
innen_breite = 150;      // Innenbreite (mm) — 7 Steine à 20mm + Rand
innen_hoehe  = 25;       // Innenhöhe (mm) — 2 Lagen Steine à 7mm + Reserve
wand         = 4;        // Wandstärke (mm)
deckel_dicke = 4;        // Deckeldicke (mm)
nut_tiefe    = 2.5;      // Nuttiefe in die Längswand (mm) — muss < wand sein
spiel        = 0.4;      // Spiel zwischen Deckel und Nut (mm)
griff_ueberstand = 20;   // Lasche übersteht die Vorderwand (mm)
mulde_d      = 16;       // Griffmulde Durchmesser (mm)
mulde_tiefe  = 2.2;      // Griffmuldentiefe (mm) — muss < deckel_dicke sein

/* [Abgeleitet] */
assert(nut_tiefe < wand, "nut_tiefe muss kleiner als wand sein!");
assert(mulde_tiefe < deckel_dicke, "mulde_tiefe muss kleiner als deckel_dicke sein!");
aussen_laenge = innen_laenge + 2 * wand;
aussen_breite = innen_breite + 2 * wand;
boden         = 2 * wand;                       // Boden 2x Wand (tragend)
aussen_hoehe  = innen_hoehe + boden;
nut_hoehe     = deckel_dicke + spiel;           // Nuthöhe = Deckel + Spiel
nut_z         = aussen_hoehe - nut_hoehe / 2;   // Nut bündig an der Oberkante
deckel_breite = innen_breite + 2 * nut_tiefe - spiel;
lasche        = wand + griff_ueberstand;        // Lasche: durch die Wand + Überstand
// Deckel um spiel/2 von der Rückwand abgerückt und um spiel gekürzt:
// kein flächiger Kontakt mit der Rückwand (verhindert coincidente Flächen im Mesh)
deckel_x0     = -innen_laenge / 2 + spiel / 2;
deckel_laenge = innen_laenge + lasche - spiel;
lasche_mitte  = innen_laenge - spiel / 2 + (lasche - spiel / 2) / 2;   // Mulde mittig in der Lasche
radius        = wand;                           // Eckenradius außen = Wandstärke

// Diese Datei definiert nur Parameter + Module.
// Das Rendering übernehmen die Render-Helper (render.scad, kiste-render.scad, deckel-render.scad).

module kiste() {
    difference() {
        // Außenkorpus mit abgerundeten vertikalen Kanten
        cuboid([aussen_laenge, aussen_breite, aussen_hoehe],
               rounding = radius, edges = "Z", anchor = BOTTOM);
        // Hohlraum (1mm Überstand oben für sauberen Schnitt)
        translate([0, 0, boden])
            cuboid([innen_laenge, innen_breite, innen_hoehe + 1], anchor = BOTTOM);
        // Führungsnuten: Taschen in den Längswänden (reichen 0.5mm in die Wände)
        translate([0,  innen_breite / 2 + nut_tiefe / 2, nut_z])
            cuboid([innen_laenge + 1, nut_tiefe, nut_hoehe], anchor = CENTER);
        translate([0, -innen_breite / 2 - nut_tiefe / 2, nut_z])
            cuboid([innen_laenge + 1, nut_tiefe, nut_hoehe], anchor = CENTER);
        // Einschuböffnung: schneidet die Vorderwand KOMPLETT (von 0.5mm vor der
        // Innenkante bis 0.5mm über die Außenkante) und öffnet die vorderen
        // Enden der Nut-Taschen — sonst blockiert ein Wandrest die Lasche.
        einschub_x = (innen_laenge / 2 - 0.5 + aussen_laenge / 2 + 0.5) / 2;
        einschub_b = aussen_laenge / 2 + 0.5 - (innen_laenge / 2 - 0.5);   // = wand + 1
        translate([einschub_x, 0, nut_z])
            cuboid([einschub_b, innen_breite + 2 * nut_tiefe + 0.6, nut_hoehe], anchor = CENTER);
    }
}

module deckel() {
    // Position: Hinterkante mit spiel/2 Luft zur Rückwand; Deckel um spiel/2
    // angehoben -> symmetrisches Spiel (je spiel/2 unten/oben/seitlich),
    // keine coincidenten Flächen mit Kisten-Oberflächen.
    translate([deckel_x0, 0, aussen_hoehe - deckel_dicke - spiel / 2]) {
        difference() {
            // Platte + Lasche in einem Stück (LEFT = Rückwandseite)
            cuboid([deckel_laenge, deckel_breite, deckel_dicke],
                   rounding = 2.5, edges = "Z", anchor = LEFT + BOTTOM);
            // Griffmulde mittig in der Lasche (von oben)
            translate([lasche_mitte, 0, deckel_dicke - mulde_tiefe])
                cyl(d = mulde_d, l = mulde_tiefe + 0.2, anchor = BOTTOM);
        }
    }
}

echo(str("Außenmaß: ", aussen_laenge, " x ", aussen_breite, " x ", aussen_hoehe, " mm"));
echo(str("Deckel: ", deckel_laenge, " x ", deckel_breite, " x ", deckel_dicke, " mm"));
