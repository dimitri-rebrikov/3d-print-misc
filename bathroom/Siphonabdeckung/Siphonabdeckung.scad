// ============================================================
// Siphonabdeckung — Abdeckung für den Siphon (Wandmontage)
// Rekonstruiert aus den beiden Skizzen in diesem Verzeichnis
// (photo_2026-09-13_16-31-57.jpg = oben/vorne, _16-32-01.jpg = hinten):
//
//   Ansicht von oben : Außen 95, innen 70, R47,5 / R35,
//                      gerade Schenkel 65 (Wand -> Mitte der Rundung)
//   Ansicht von vorne: 95 breit x 65 hoch   (Höhe = 65 mm, nicht 6,5 mm)
//   Ansicht von hinten: Wandstärke 12,5, lichter Innenraum 70
//
// Form: oben und unten offener Halbrund-Kanal (Grundriss = U mit
// halbrunder Front), hinten offen -> wird über den Siphon gestülpt.
//
// Orientierung / Kanten (Vorgabe Nutzer):
//   * Die U liegt flach, Z = 65 ist die nach oben schauende Frontseite.
//   * Diese Frontseite bekommt an ALLEN Kanten eine Rundung.
//   * Die Unterseite (Z = 0, liegt auf Boden/Druckbett) bleibt scharf.
//   * Die beiden U-Spitzen (Stirnflächen der Schenkel) bleiben an ihren
//     flachen Seiten scharf, werden also nicht gerundet.
//
// Fillets mit BOSL2: offset_sweep() + os_circle() -> Rundung der
// Oberkante über den gesamten Grundriss (auch am Innenraum).
// ============================================================

include <BOSL2/std.scad>

// ============================================================
// PARAMETER (alle Werte aus den Skizzen)
// ============================================================

aussen_breite = 95;    // Gesamtbreite außen
innen_breite  = 70;    // lichte Weite innen
schenkel      = 65;    // Länge der geraden Seitenwände (Wand -> Rundungsmitte)
hoehe         = 65;    // Höhe (Ansicht von vorne)
radius_front  = 5;     // Rundung der Frontseite (Skizze: "5")

// ============================================================
// ABGELEITETE GRÖSSEN
// ============================================================

rad_aussen = aussen_breite / 2;                 // 47,5 Außenradius der Front
rad_innen  = innen_breite / 2;                  // 35   Innenradius der Front
wand       = (aussen_breite - innen_breite) / 2; // 12,5 Wandstärke
tiefe      = schenkel + rad_aussen;             // 112,5 Gesamttiefe ab Wand

// Randkanten-Rundung darf die Wandstärke nicht auffressen
assert(2 * radius_front <= wand,
       "radius_front ist größer als die halbe Wandstärke");
assert(radius_front <= hoehe,
       "radius_front ist größer als die Höhe");

// Rendering-Auflösung
$fn = 96;
n_bogen = 48;          // Segmente pro Halbrund im Grundriss

// ============================================================
// GRUNDRISS (Ansicht von oben)
// ============================================================

// Punkte eines Kreisbogens in der X/Y-Ebene
function bogen(radius, mitte, w_start, w_ende, n = n_bogen) =
    [for (i = [0:n])
        mitte + radius * [cos(w_start + (w_ende - w_start) * i / n),
                          sin(w_start + (w_ende - w_start) * i / n)]];

// Geschlossener Pfad des Bandes: Außenkontur hin, Innenkontur zurück.
// Der offene Rücken liegt auf y = 0 (dort steht später die Wand),
// die halbrunde Front liegt bei y = schenkel + rad.
// ACHTUNG: Beide Halbrunde müssen nach vorne (von der Öffnung weg) wölben,
// also konzentrisch mit Mittelpunkt (0, schenkel) sein — nur dann ist die
// Wandstärke überall gleich 12,5 mm (47,5 − 35).
function band_weg() =
    concat(
        [[-rad_aussen, 0]],                                 // Rücken links außen
        bogen(rad_aussen, [0, schenkel], 180, 0),           // halbrunde Front außen
        [[rad_aussen, 0]],                                  // Rücken rechts außen
        [[rad_innen, 0]],                                   // Stirnfläche der Wand
        bogen(rad_innen, [0, schenkel], 0, 180),            // halbrunde Front innen
        [[-rad_innen, 0]]                                   // Rücken links innen
    );

// Kontrolle: Fläche des Bandes = Außenform − Innenform (in der Skizze:
// Rechteck + Halbrund, beide konzentrisch). Fängt einen verdrehten
// Innenbogen auf — dann wäre die Wand vorne um ein Vielfaches dicker.
flaeche_soll = (aussen_breite * schenkel + PI * rad_aussen^2 / 2)
             - (innen_breite * schenkel + PI * rad_innen^2 / 2);
flaeche_ist  = polygon_area(band_weg());
assert(abs(flaeche_ist - flaeche_soll) < 5,
       str("Grundriss-Fläche stimmt nicht (Innenbogen verdreht?): ",
           flaeche_ist, " statt ", flaeche_soll));

// ============================================================
// MODELL
// ============================================================

module siphonabdeckung() {
    // Grundriss-Pfad wird NICHT gerundet: die beiden Schenkelspitzen
    // (Stirnflächen am Rücken) bleiben auf ihren flachen Seiten scharf.
    // offset_sweep() mit os_circle() rundet nur die nach oben schauende
    // Frontseite; die Unterseite (Boden bzw. Druckbett) bleibt scharf.
    offset_sweep(band_weg(), height = hoehe,
                 top   = os_circle(r = radius_front),
                 steps = 12, convexity = 10);
}

// ============================================================
// PRÜFANSICHTEN — ohne -D PRUEFUNG wird nur das Modell gezeigt.
//   openscad -o schnitt.png -D 'PRUEFUNG="schnitt_grundriss"' Siphonabdeckung.scad
// ============================================================

PRUEFUNG = is_undef(PRUEFUNG) ? "modell" : PRUEFUNG;

if (PRUEFUNG == "schnitt_grundriss") {
    // waagerechter Schnitt in halber Höhe -> Vergleich "Ansicht von oben"
    difference() {
        siphonabdeckung();
        translate([0, tiefe / 2, hoehe / 2 + 2 * hoehe])
            cube([4 * aussen_breite, 4 * tiefe, 4 * hoehe], center = true);
    }
} else if (PRUEFUNG == "schnitt_laengs") {
    // senkrechter Schnitt auf der Symmetrieachse -> Vergleich "von vorne/hinten"
    difference() {
        siphonabdeckung();
        translate([aussen_breite, tiefe / 2, hoehe / 2])
            cube([2 * aussen_breite, 4 * tiefe, 4 * hoehe], center = true);
    }
} else if (PRUEFUNG == "modell") {
    siphonabdeckung();
} else {
    assert(false, str("Unbekannte PRUEFUNG: ", PRUEFUNG));
}
