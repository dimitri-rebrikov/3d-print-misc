// Schiebedeckel-Box (Domino-Stil): Kiste + Deckel, der seitlich in Führungsnuten gleitet
// BOSL2: cuboid (rounding, edges, anchor), difference
//
// Parameter: Außenmaße (breite x tiefe x hoehe) + Wandstärke — die Wandstärke
// gilt auch für Boden und Deckel. Der Stauraum ergibt sich aus der Höhe.
//
// Konstruktion:
//  - Wände ragen nur wand über den Deckel (kein hoher Steg)
//  - Einschubschlitz geht bis zur Oberkante: KEIN Wandbalken darüber (= keine
//    Druck-Brücke); die Zugkante des Deckels begrenzt den Schlitz von oben
//  - Zugkante so hoch wie der Deckel (wand), schließt bündig mit der Wand ab
//  - Deckel-Vorderkante bündig mit der Vorderwand der Einschubseite
include <BOSL2/std.scad>
$fn = 48;

/* [Parameter] */
breite    = 178;    // Außenbreite (mm) — x-Richtung
tiefe     = 158;    // Außentiefe (mm) — y-Richtung
hoehe     = 36.2;   // Außenhöhe (mm) — z-Richtung
wand      = 4;      // Wandstärke (mm) — gilt auch für Boden und Deckel
nut_tiefe = 2.5;    // Führungsnuttiefe in die Längswand (mm) — muss < wand sein
spiel     = 0.4;    // Spiel zwischen Deckel und Nut (mm)

/* [Abgeleitet] */
assert(nut_tiefe < wand, "nut_tiefe muss kleiner als wand sein!");
aussen_laenge = breite;
aussen_breite = tiefe;
aussen_hoehe  = hoehe;
deckel_dicke  = wand;                       // Deckel = Wandstärke
boden         = wand;                       // Boden = Wandstärke
kanten_dicke  = wand;                       // Dicke der Zugkante
verbund       = 0.1;                        // Überlappung für saubere union() (Coincident-Faces)
innen_laenge  = aussen_laenge - 2 * wand;
innen_breite  = aussen_breite - 2 * wand;

// Vertikale Positionen (von unten nach oben):
//   boden -> Stauraum -> Deckel (wand) -> Zugkante (wand) -> spiel/2 -> Oberkante
stauraum      = aussen_hoehe - boden - 2 * deckel_dicke - spiel / 2;
assert(stauraum > 0, "Höhe zu klein — kein Stauraum!");
deckel_unten  = boden + stauraum;           // Deckel-Unterkante = Stauraum-Oberkante
deckel_oben   = deckel_unten + deckel_dicke;
kante_oben    = deckel_oben + deckel_dicke; // Zugkante so hoch wie der Deckel
schlitz_unten = deckel_unten - spiel / 2;   // Schlitz lässt Deckel + Kante durch
schlitz_oben  = aussen_hoehe;               // bis zur Oberkante: KEIN Steg,
                                            // keine Druck-Brücke über dem Einschub
schlitz_hoehe = schlitz_oben - schlitz_unten;
nut_unten     = schlitz_unten;              // Nut führt nur den Deckel (nicht die Kante)
nut_hoehe     = deckel_dicke + spiel;
nut_z         = nut_unten + nut_hoehe / 2;
schlitz_z     = schlitz_unten + schlitz_hoehe / 2;

deckel_breite = innen_breite + 2 * nut_tiefe - spiel;
deckel_x0     = -innen_laenge / 2 + spiel / 2;  // Luft zur Rückwand
// Vorderkante bündig mit der Vorderwand der Einschubseite (aussen_laenge/2)
deckel_laenge = aussen_laenge / 2 - deckel_x0;
radius        = wand;                           // Eckenradius außen = Wandstärke

// Einschubschlitz: schneidet die Vorderwand komplett (0.5mm über beide Kanten)
einschub_x = (innen_laenge / 2 - 0.5 + aussen_laenge / 2 + 0.5) / 2;
einschub_b = aussen_laenge / 2 + 0.5 - (innen_laenge / 2 - 0.5);   // = wand + 1

// Diese Datei definiert nur Parameter + Module.
// Das Rendering übernehmen die Render-Helper (render.scad, kiste-render.scad, deckel-render.scad).

// Einschubschlitz durch die Vorderwand:
//  - mittlerer Kanal (y ±innen_breite/2, volle Schlitzhöhe): für Plattenmitte + Zugkante
//  - seitliche Kanäle (nur auf Nuthöhe): für den Plattenrand in den Nuten
// Die Längswand-Stege über den Nuten bleiben an der Einschubseite stehen
// (kein tiefer Ausschnitt bis zur Oberkante).
module einschub() {
    union() {
        translate([einschub_x, 0, schlitz_z])
            cuboid([einschub_b, innen_breite, schlitz_hoehe], anchor = CENTER);
        for (sy = [1, -1])
            translate([einschub_x, sy * (innen_breite / 2 + nut_tiefe / 2), nut_z])
                cuboid([einschub_b, nut_tiefe, nut_hoehe], anchor = CENTER);
    }
}

module kiste() {
    difference() {
        // Außenkorpus mit abgerundeten vertikalen Kanten
        cuboid([aussen_laenge, aussen_breite, aussen_hoehe],
               rounding = radius, edges = "Z", anchor = BOTTOM);
        // Hohlraum: von boden bis ÜBER die Kisten-Oberkante — die Kiste ist oben
        // offen (der Deckel ist die Abdeckung), keine "Decke" über dem Innenraum
        translate([0, 0, boden])
            cuboid([innen_laenge, innen_breite, aussen_hoehe - boden + 1], anchor = BOTTOM);
        // Führungsnuten: Taschen in den Längswänden (reichen 0.5mm in die Wände)
        translate([0,  innen_breite / 2 + nut_tiefe / 2, nut_z])
            cuboid([innen_laenge + 1, nut_tiefe, nut_hoehe], anchor = CENTER);
        translate([0, -innen_breite / 2 - nut_tiefe / 2, nut_z])
            cuboid([innen_laenge + 1, nut_tiefe, nut_hoehe], anchor = CENTER);
        // Einschubschlitz: mittlerer Kanal + seitliche Nut-Kanäle (Stege bleiben)
        einschub();
    }
}

module deckel() {
    // Deckel-Unterkante = Stauraum-Oberkante; Luft spiel/2 zur Rückwand
    translate([deckel_x0, 0, deckel_unten]) {
        union() {
            // Platte: Vorderkante bündig mit der Vorderwand der Einschubseite
            cuboid([deckel_laenge, deckel_breite, deckel_dicke],
                   rounding = 2.5, edges = "Z", anchor = LEFT + BOTTOM);
            // Zugkante an der Vorderkante, nach oben — so hoch wie der Deckel.
            // Sitzt komplett auf der Platte, füllt den Schlitz und schließt
            // bündig mit der Vorderwand ab. Breite = Öffnungsbreite (keine
            // Kollision mit den Längswänden). um verbund überlappen -> union sauber.
            translate([deckel_laenge - kanten_dicke, 0, deckel_dicke - verbund])
                cuboid([kanten_dicke, innen_breite - spiel, deckel_dicke + verbund],
                       rounding = 1, edges = "Z", anchor = LEFT + BOTTOM);
        }
    }
}

echo(str("Außenmaß: ", breite, " x ", tiefe, " x ", hoehe, " mm"));
echo(str("Stauraum: ", innen_laenge, " x ", innen_breite, " x ", stauraum, " mm"));
echo(str("Schlitz:  ", schlitz_unten, "..", schlitz_oben, " mm (Höhe ", schlitz_hoehe, "), offen bis zur Oberkante"));
echo(str("Deckel:   ", deckel_laenge, " x ", deckel_breite, " x ", deckel_dicke, " mm + Kante ", deckel_dicke, " mm"));
