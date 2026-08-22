// Schiebedeckel-Box (Domino-Stil) — Kiste + Deckel, der seitlich in Führungsnuten gleitet
// BOSL2: cuboid (rounding, edges, anchor), difference
//
// ALS BIBLIOTHEK NUTZBAR:
//   use <schiebedeckel-box.scad>
//   schiebedeckel_box();                              // ganze Box (Defaults)
//   schiebedeckel_box(breite=200, tiefe=120, hoehe=30, wand=3);   // parametriert
//   schiebedeckel_box(teil="kiste");                  // nur die Kiste
//   difference() { schiebedeckel_box(teil="kiste");   // Löcher bohren:
//       translate([0,0,-1]) cyl(d=5, h=10);           //   Box minus Bohrung
//   }
//
// Parameter (alle in mm): breite/tiefe/hoehe = Außenmaße, wand = Wandstärke
// (gilt auch für Boden und Deckel), nut_tiefe = Führungsnuttiefe, spiel = Spiel.
// Der Stauraum ergibt sich aus der Höhe.
//
// Konstruktion:
//  - Wände ragen nur wand über den Deckel (kein hoher Steg)
//  - Einschubschlitz geht bis zur Oberkante: KEIN Wandbalken darüber (= keine
//    Druck-Brücke); die Zugkante des Deckels begrenzt den Schlitz von oben
//  - Zugkante so hoch wie der Deckel (wand), schließt bündig mit der Wand ab
//  - Deckel-Vorderkante bündig mit der Vorderwand der Einschubseite
include <BOSL2/std.scad>

/* [Parameter (Defaults — per -D oder Modul-Argument überschreibbar)] */
breite    = 178;    // Außenbreite (mm) — x-Richtung
tiefe     = 158;    // Außentiefe (mm) — y-Richtung
hoehe     = 36.2;   // Außenhöhe (mm) — z-Richtung
wand      = 4;      // Wandstärke (mm) — gilt auch für Boden und Deckel
nut_tiefe = 2.5;    // Führungsnuttiefe in die Längswand (mm) — muss < wand sein
spiel     = 0.4;    // Spiel zwischen Deckel und Nut (mm)

module schiebedeckel_box(
    breite    = breite,
    tiefe     = tiefe,
    hoehe     = hoehe,
    wand      = wand,
    nut_tiefe = nut_tiefe,
    spiel     = spiel,
    teil      = "alles"   // "kiste" | "deckel" | "alles"
) {
    assert(nut_tiefe < wand, "nut_tiefe muss kleiner als wand sein!");

    // ---- Abgeleitete Größen (aus den Parametern) ----
    aussen_laenge = breite;
    aussen_breite = tiefe;
    aussen_hoehe  = hoehe;
    deckel_dicke  = wand;                       // Deckel = Wandstärke
    boden         = wand;                       // Boden = Wandstärke
    kanten_dicke  = wand;                       // Dicke der Zugkante
    verbund       = 0.1;                        // Überlappung für saubere union()
    innen_laenge  = aussen_laenge - 2 * wand;
    innen_breite  = aussen_breite - 2 * wand;

    // Vertikal (von unten nach oben):
    //   boden -> Stauraum -> Deckel (wand) -> Zugkante (wand) -> spiel/2 -> Oberkante
    stauraum      = aussen_hoehe - boden - 2 * deckel_dicke - spiel / 2;
    assert(stauraum > 0, "Höhe zu klein — kein Stauraum!");
    deckel_unten  = boden + stauraum;
    deckel_oben   = deckel_unten + deckel_dicke;
    schlitz_unten = deckel_unten - spiel / 2;
    schlitz_oben  = aussen_hoehe;               // Schlitz bis zur Oberkante (keine Brücke)
    schlitz_hoehe = schlitz_oben - schlitz_unten;
    nut_unten     = schlitz_unten;              // Nut führt nur den Deckel (nicht die Kante)
    nut_hoehe     = deckel_dicke + spiel;
    nut_oben      = nut_unten + nut_hoehe;
    nut_z         = nut_unten + nut_hoehe / 2;
    schlitz_z     = schlitz_unten + schlitz_hoehe / 2;

    // 45°-Fasen an den Nut-Oberseiten: die Taschen laufen oben spitz aus statt
    // waagerecht zu enden -> keine Bridges/Überhänge beim Druck (supportfrei)
    fase_hoehe = nut_tiefe;                     // 45° (2.5 hoch, 2.5 tief)
    fase_start = nut_oben - fase_hoehe;         // Nut voll bis hier, dann Fase auf 0

    deckel_breite = innen_breite + 2 * nut_tiefe - spiel;
    deckel_x0     = -innen_laenge / 2 + spiel / 2;
    deckel_laenge = aussen_laenge / 2 - deckel_x0;   // Vorderkante bündig mit Vorderwand
    radius        = wand;

    // Einschubschlitz: schneidet die Vorderwand komplett (0.5mm über beide Kanten)
    einschub_x = (innen_laenge / 2 - 0.5 + aussen_laenge / 2 + 0.5) / 2;
    einschub_b = aussen_laenge / 2 + 0.5 - (innen_laenge / 2 - 0.5);   // = wand + 1
    // Einschubschlitz durch die Vorderwand:
    //  - mittlerer Kanal (y ±innen_breite/2, volle Schlitzhöhe): Plattenmitte + Zugkante
    //  - seitliche Kanäle (nur auf Nuthöhe, mit 45°-Fase): Plattenrand in den Nuten
    // Die Längswand-Stege über den Nuten bleiben an der Einschubseite stehen und
    // haben dank der Fase eine schräge Unterseite (keine Bridge beim Druck).
    module einschub() {
        union() {
            translate([einschub_x, 0, schlitz_z])
                cuboid([einschub_b, innen_breite, schlitz_hoehe], anchor = CENTER);
            // seitliche Kanäle: gleiches Fasen-Profil wie die Nuten (45°)
            seitlicher_kanal( 1);
            seitlicher_kanal(-1);
        }
    }

    // Nut-/Kanal-Profil (eine Seite): Innenkante fix bei y=0, Außenkante verjüngt
    // von nut_tiefe auf 0.01 (45°-Fase). Als [z, y]-Polygon extrudiert in x-Richtung.
    module nut_profil(sy) {
        profil = [
            [nut_unten, 0],          // Innenkante unten
            [nut_unten, nut_tiefe],  // Außenkante unten (volle Tiefe)
            [fase_start, nut_tiefe], // Außenkante bis zum Fasenbeginn
            [nut_oben, 0.01],        // Fase-Spitze
            [nut_oben, 0]            // Innenkante oben
        ];
        rotate([0, -90, 0])
            linear_extrude(height = 1, center = true)
                polygon([for (p = profil) [p[0], sy * p[1]]]);
    }

    module nut(sy) {
        translate([0, sy * innen_breite / 2, 0])
            scale([innen_laenge + 1, 1, 1])
            nut_profil(sy);
    }

    module seitlicher_kanal(sy) {
        translate([einschub_x, sy * innen_breite / 2, 0])
            scale([einschub_b, 1, 1])
            nut_profil(sy);
    }

    module kiste() {
        difference() {
            cuboid([aussen_laenge, aussen_breite, aussen_hoehe],
                   rounding = radius, edges = "Z", anchor = BOTTOM);
            // Hohlraum bis ÜBER die Oberkante (Kiste oben offen, Deckel ist die Abdeckung)
            translate([0, 0, boden])
                cuboid([innen_laenge, innen_breite, aussen_hoehe - boden + 1], anchor = BOTTOM);
            // Führungsnuten: Taschen in den Längswänden (reichen 0.5mm in die Wände),
            // Oberseite als 45°-Fase: Profil mit fixer Innenkante, die Außenkante läuft
            // auf die Innenkante zu (supportfrei, keine waagerechten Decken)
            nut( 1);
            nut(-1);
            einschub();
        }
    }

    module deckel() {
        // Deckel-Unterkante = Stauraum-Oberkante; Luft spiel/2 zur Rückwand
        translate([deckel_x0, 0, deckel_unten]) {
            union() {
                // Platte mit Fase an den Längskanten: Ausladung läuft nach oben auf
                // spiel/2 aus (passt in die spitz zulaufende Fasen-Nut). Die Deckelbreite
                // bleibt ÜBERALL > innen_breite: die schräge Seitenfläche kreuzt die
                // Öffnungskanten-Ebene nie (keine Schnittlinie im kombinierten Modell).
                // Platte endet spiel/2 vor der Vorderkante (die Zugkante übersteht,
                // bleibt bündig). Kein rounding: Fase + Rundung beißen sich (2-manifold)
                prismoid(size1 = [deckel_laenge - spiel / 2, deckel_breite],
                         size2 = [deckel_laenge - spiel / 2, innen_breite + spiel / 2],
                         h = deckel_dicke, anchor = LEFT + BOTTOM);
                // Zugkante an der Vorderkante, nach oben — so hoch wie der Deckel.
                // Sitzt komplett auf der Platte, füllt den Schlitz, schließt bündig
                // mit der Vorderwand ab. Breite = Öffnungsbreite (keine Kollision
                // mit den Längswänden). um verbund überlappen -> union sauber.
                translate([deckel_laenge - kanten_dicke, 0, deckel_dicke - verbund])
                    cuboid([kanten_dicke, innen_breite - spiel, deckel_dicke + verbund],
                           rounding = 1, edges = "Z", anchor = LEFT + BOTTOM);
            }
        }
    }

    if (teil == "alles" || teil == "kiste") kiste();
    if (teil == "alles" || teil == "deckel") deckel();

    echo(str("Außenmaß: ", breite, " x ", tiefe, " x ", hoehe, " mm"));
    echo(str("Stauraum: ", innen_laenge, " x ", innen_breite, " x ", stauraum, " mm"));
    echo(str("Schlitz:  ", schlitz_unten, "..", schlitz_oben, " mm (Höhe ", schlitz_hoehe, "), offen bis zur Oberkante"));
    echo(str("Deckel:   ", deckel_laenge, " x ", deckel_breite, " x ", deckel_dicke, " mm + Kante ", deckel_dicke, " mm"));
}
