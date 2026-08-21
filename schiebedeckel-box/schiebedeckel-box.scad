// Schiebedeckel-Box (Domino-Stil): Kiste + Deckel, der seitlich in Führungsnuten gleitet
// BOSL2: cuboid (rounding, edges, anchor), difference
//
// Konstruktion (klassischer Domino-Kasten):
//  - Vorderwand voll hoch, Einschubschlitz MIT begrenzender Kante von oben (Steg)
//  - Deckel genauso groß wie die Öffnung (keine Lasche), liegt versenkt in den Nuten
//  - Zugkante auf dem Deckel (statt Griffmulde): nach oben, gleich hoch wie der Steg
//  - Schlitz lässt Deckel + Zugkante durchfahren -> Deckel komplett abnehmbar
include <BOSL2/std.scad>
$fn = 48;

/* [Parameter] */
innen_laenge = 170;      // Innenlänge (mm) — Domino Double-Six: 4 Steine à 40mm + Rand
innen_breite = 150;      // Innenbreite (mm) — 7 Steine à 20mm + Rand
innen_hoehe  = 20;       // Stauraumhöhe UNTER dem Deckel (mm) — 2 Lagen à 7mm + Reserve
wand         = 4;        // Wandstärke (mm)
deckel_dicke = 4;        // Deckeldicke (mm)
nut_tiefe    = 2.5;      // Nuttiefe in die Längswand (mm) — muss < wand sein
spiel        = 0.4;      // Spiel Deckel/Nut (mm)
kantenhoehe  = 4;        // Zugkante auf dem Deckel = Steg-Höhe über dem Schlitz (mm)

/* [Abgeleitet] */
assert(nut_tiefe < wand, "nut_tiefe muss kleiner als wand sein!");
aussen_laenge = innen_laenge + 2 * wand;
aussen_breite = innen_breite + 2 * wand;
boden         = 2 * wand;                       // Boden 2x Wand (tragend)
kanten_dicke  = wand;                           // Dicke der Zugkante
verbund       = 0.1;                            // Überlappung für saubere union() (Coincident-Faces)
kanten_ueberstand = 2.4;                        // Kante ragt im geschlossenen Zustand so weit
                                                // in den Schlitz: sichtbar + von vorn greifbar

// Vertikale Positionen (von unten nach oben):
//   boden -> Stauraum (innen_hoehe) -> Deckel (deckel_dicke) -> Zugkante (kantenhoehe)
//   -> Steg über dem Schlitz (kantenhoehe) -> Oberkante
deckel_unten  = boden + innen_hoehe;            // Deckel-Unterkante = Stauraum-Oberkante
deckel_oben   = deckel_unten + deckel_dicke;    // Deckel-Oberseite
kante_oben    = deckel_oben + kantenhoehe;      // Zugkante-Oberkante (bündig mit Steg-Unterkante)
schlitz_unten = deckel_unten - spiel / 2;       // Schlitz lässt Deckel + Kante durch
schlitz_oben  = kante_oben + spiel / 2;
schlitz_hoehe = schlitz_oben - schlitz_unten;   // = deckel_dicke + kantenhoehe + spiel
aussen_hoehe  = schlitz_oben + kantenhoehe;     // Steg = kantenhoehe über dem Schlitz
nut_unten     = schlitz_unten;                  // Nut führt nur den Deckel (nicht die Kante)
nut_hoehe     = deckel_dicke + spiel;
nut_z         = nut_unten + nut_hoehe / 2;
schlitz_z     = schlitz_unten + schlitz_hoehe / 2;

deckel_breite = innen_breite + 2 * nut_tiefe - spiel;
deckel_x0     = -innen_laenge / 2 + spiel / 2;  // Deckel mit Luft zur Rückwand
deckel_laenge = innen_laenge - spiel;           // genauso groß wie die Öffnung, keine Lasche
radius        = wand;                           // Eckenradius außen = Wandstärke

// Einschubschlitz: schneidet die Vorderwand KOMPLETT (0.5mm über beide Kanten)
// und öffnet die vorderen Enden der Nut-Taschen
einschub_x = (innen_laenge / 2 - 0.5 + aussen_laenge / 2 + 0.5) / 2;
einschub_b = aussen_laenge / 2 + 0.5 - (innen_laenge / 2 - 0.5);   // = wand + 1

// Diese Datei definiert nur Parameter + Module.
// Das Rendering übernehmen die Render-Helper (render.scad, kiste-render.scad, deckel-render.scad).

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
        // Einschubschlitz: durch die Vorderwand, MIT Steg von oben (begrenzende Kante)
        translate([einschub_x, 0, schlitz_z])
            cuboid([einschub_b, innen_breite + 2 * nut_tiefe + 0.6, schlitz_hoehe], anchor = CENTER);
    }
}

module deckel() {
    // Deckel-Unterkante = Stauraum-Oberkante; Luft spiel/2 zur Rückwand
    translate([deckel_x0, 0, deckel_unten]) {
        union() {
            // Platte: genauso groß wie die Öffnung, keine Lasche
            cuboid([deckel_laenge, deckel_breite, deckel_dicke],
                   rounding = 2.5, edges = "Z", anchor = LEFT + BOTTOM);
            // Zugkante an der Vorderkante, nach oben — gleich hoch wie der Steg.
            // Ragt kanten_ueberstand über die Plattenkante hinaus -> sitzt im
            // geschlossenen Zustand sichtbar im Schlitz (von vorn greifbar).
            // Breite = Öffnungsbreite: bleibt zwischen den Längswänden (keine Kollision).
            // um verbund in die Platte überlappen lassen -> union() verschmilzt sauber.
            translate([deckel_laenge - kanten_dicke, 0, deckel_dicke - verbund])
                cuboid([kanten_dicke + kanten_ueberstand, innen_breite - spiel, kantenhoehe + verbund],
                       rounding = 1, edges = "Z", anchor = LEFT + BOTTOM);
        }
    }
}

echo(str("Außenmaß: ", aussen_laenge, " x ", aussen_breite, " x ", aussen_hoehe, " mm"));
echo(str("Stauraum: ", innen_laenge, " x ", innen_breite, " x ", innen_hoehe, " mm"));
echo(str("Schlitz:  ", schlitz_unten, "..", schlitz_oben, " mm (Höhe ", schlitz_hoehe, "), Steg: ", kantenhoehe, " mm"));
echo(str("Deckel:   ", deckel_laenge, " x ", deckel_breite, " x ", deckel_dicke, " mm + Kante ", kantenhoehe, " mm"));
