// ============================================================

// BadLuftungSchalldaempfer — Schalldämpfer für Badezimmer-Lüftung
// Siehe README.md für Design-Beschreibung und Montage.
// ============================================================

// ============================================================
// PARAMETER
// ============================================================

// --- Rohr & Loch ---
rohr_durchmesser   = 100;   // Lüftungsrohr-Innendurchmesser (mm)
loch_durchmesser   = 130;   // Wandloch-Durchmesser (mm)

// --- Position zur Ecke ---
loch_mitte_x       = 105;   // Lochmittelpunkt → Ecke (mm)
wand_abstand_ecke  = 10;    // Min. Abstand zur Eckwand (mm)

// --- Wandstärken ---
wand_dicke         = 3.0;   // Zylinder-Wandstärke (mm)
boden_dicke        = 3.0;   // Vordere/hintere Wandstärke (mm)
zylinder_mindest_hoehe = 30.0;  // Mindesthöhe der niedrigsten Zylinderwand (mm)


// --- Dämmmaterial ---
daemmung_dicke     = 6.0;   // TPU-Dämmring (mm)



// 
// Die Dämmringe (6mm TPU) liegen auf den Flächen (Bodenplatte/Vorderwand)
// und füllen die Zwischenräume zwischen den Zylindern. Der Luftspalt
// zwischen den Zylindern bleibt frei für die Strömung.


// --- Magnete (Befestigung Außenteil) ---

magnet_durchmesser = 6.0;   // Neodym-Magnet Durchmesser (mm)
magnet_dicke       = 2.0;   // Neodym-Magnet Dicke (mm)
magnet_anzahl      = 3;     // Anzahl Magnete (3-Punkt = kein Wackeln)

// Mini-Säulen auf der Vorderwand als Markierung (2mm hoch)
magnet_markierung_hoehe = 2.0;

// --- Abrundungen ---
radius_aussen      = 5.0;   // Äußere Kanten-Abrundung (mm)
radius_zylinder    = 2.0;   // Zylinder-Endkanten Abrundung (mm)

// --- Proportionaler Versatz der Zylinder ---
// Jeder Zylinder (außer Z1) bekommt einen eigenen Versatz in X-Richtung
// (von der Ecke weg), proportional zu seinem Außenradius.
// Z1 bleibt fix (Versatz = 0), da es direkt über das Wandloch hängt.
// Z4 bekommt den maximalen Versatz, Z2 und Z3 proportionale Anteile.
// Dadurch entsteht ein konisches Labyrinth mit variablen Spaltbreiten,
// das stehende Wellen verhindert und die Dämpfung verbessert.







// --- Rendering-Qualität ---
$fn = 64;

// ============================================================
// ABGELEITETE GRÖSSEN (alle berechnet, keine festen Werte)
// ============================================================


rohr_radius   = rohr_durchmesser / 2;
loch_radius   = loch_durchmesser / 2;

// Maximaler Außenradius zur Ecke hin
max_radius_ecke = loch_mitte_x - wand_abstand_ecke;

// Rohr-Querschnittsfläche (für Strömungsberechnung)
A_rohr = PI * rohr_radius * rohr_radius;

// --- Zylinder-Radien (von innen nach außen nummeriert) ---
// Zylinder 1 = innerster Ring (Wandteil, direkt um das Rohrloch)
// Zylinder 2 = zweiter Ring (Außenteil)
// Zylinder 3 = dritter Ring (Wandteil)
// Zylinder 4 = äußerster Ring (Außenteil)
//
// Die radialen Spaltbreiten werden nach dem Strömungsprinzip berechnet:
//   spalt_i = A_rohr / (2π × r_i)
// Damit die seitliche Durchtrittsfläche (Umfang × Spalt) = A_rohr ist.
// Die Spalte werden NICHT skaliert — sie bleiben optimal.
// Stattdessen wird das gesamte Außenteil (Z2, Z4, Vorderwand) von der Ecke
// weg verschoben (Versatz), sodass Z4_außen auf der Eckseite ≤ max_radius_ecke ist.

// Zylinder 1 beginnt bündig mit dem Wandloch-Rand (130mm)
// Das 100mm-Rohr wird nur für die Strömungsberechnung (A_rohr) verwendet.
zylinder_1_innen  = loch_radius;

zylinder_1_aussen = zylinder_1_innen + wand_dicke;

// Optimale Luftspalt-Breite an jedem Zylinder (A_rohr / Umfang)
// Diese Werte sind endgültig — es wird nicht skaliert.
spalt_12 = A_rohr / (2 * PI * zylinder_1_aussen);
zylinder_2_innen  = zylinder_1_aussen + spalt_12;
zylinder_2_aussen = zylinder_2_innen + wand_dicke;

spalt_23 = A_rohr / (2 * PI * zylinder_2_aussen);
zylinder_3_innen  = zylinder_2_aussen + spalt_23;
zylinder_3_aussen = zylinder_3_innen + wand_dicke;

spalt_34 = A_rohr / (2 * PI * zylinder_3_aussen);
zylinder_4_innen  = zylinder_3_aussen + spalt_34;
zylinder_4_aussen = zylinder_4_innen + wand_dicke;


// --- Axiale Spalte (zwischen Zylinder-Ende und gegenüberliegender Wand) ---
// Jeder Zylinder hat seinen eigenen axialen Spalt, berechnet aus dem
// Strömungsprinzip: Durchtrittsfläche = Umfang × Spalt ≥ A_rohr.
// Die Dämmringe (daemmung_dicke) liegen auf der gegenüberliegenden Wand
// und reduzieren den effektiven Spalt, daher wird die Dämmdicke addiert.
// 
// Wandteil-Zylinder (Z1, Z3): axialer Spalt zur Vorderwand (Außenteil)
// Außenteil-Zylinder (Z2, Z4): axialer Spalt zur Bodenplatte (Wandteil)
axial_spalt_1 = A_rohr / (2 * PI * zylinder_1_aussen) + daemmung_dicke;
axial_spalt_2 = A_rohr / (2 * PI * zylinder_2_aussen) + daemmung_dicke;
axial_spalt_3 = A_rohr / (2 * PI * zylinder_3_aussen) + daemmung_dicke;
axial_spalt_4 = A_rohr / (2 * PI * zylinder_4_aussen) + daemmung_dicke;

// Zylinder-Tiefe (Bautiefe) wird aus der Mindesthöhe der niedrigsten Wand
// abgeleitet. Die niedrigste Wand ist Z1 (kleinster Umfang → größter axialer Spalt).
// zylinder_tiefe = zylinder_mindest_hoehe + axial_spalt_1
// Dadurch hat Z1 genau die Mindesthöhe, alle anderen Zylinder sind höher.
zylinder_tiefe = zylinder_mindest_hoehe + axial_spalt_1;

// Zylinder-Höhen (axialer Spalt wird von zylinder_tiefe abgezogen)
zylinder_1_hoehe = zylinder_tiefe - axial_spalt_1;  // = zylinder_mindest_hoehe
zylinder_2_hoehe = zylinder_tiefe - axial_spalt_2;
zylinder_3_hoehe = zylinder_tiefe - axial_spalt_3;
zylinder_4_hoehe = zylinder_tiefe - axial_spalt_4;


// Säulenhöhe = radialer Eintrittsspalt zwischen Z3-Oberkante und Vorderwand
// Eintrittsfläche = Umfang Z3 × Spalt = A_rohr
// Spalt = A_rohr / (2π × zylinder_3_aussen)
// Säulenhöhe = Spalt - 2 × magnet_dicke
eintrittsspalt = A_rohr / (2 * PI * zylinder_3_aussen);
magnet_saeule_hoehe = eintrittsspalt - 2 * magnet_dicke;

// --- Proportionaler Versatz der Zylinder ---
// Jeder Zylinder (außer Z1) bekommt einen eigenen Versatz in X-Richtung
// (von der Ecke weg), proportional zu seinem Außenradius.
// Z1 bleibt fix (Versatz = 0), da es direkt über das Wandloch hängt.
// Z4 bekommt den maximalen Versatz, Z2 und Z3 proportionale Anteile.
// Dadurch entsteht ein konisches Labyrinth mit variablen Spaltbreiten,
// das stehende Wellen verhindert und die Dämpfung verbessert.
//
// Berechnung:
//   versatz_4 = zylinder_4_aussen - max_radius_ecke  (maximaler Versatz)
//   versatz_i = versatz_4 × (r_i_aussen - r_1_aussen) / (r_4_aussen - r_1_aussen)
//
// Der Nenner ist die gesamte Radialerstreckung der Zylinder (ohne Z1).
radius_spanne = zylinder_4_aussen - zylinder_1_aussen;
versatz_4 = zylinder_4_aussen - max_radius_ecke;
versatz_2 = versatz_4 * (zylinder_2_aussen - zylinder_1_aussen) / radius_spanne;
versatz_3 = versatz_4 * (zylinder_3_aussen - zylinder_1_aussen) / radius_spanne;

// Außenkante des Wandteils: Die Bodenplatte muss deckungsgleich mit der
// Vorderwand des Außenteils sein (gleicher Mittelpunkt = versatz_4, gleicher
// Radius). Der Radius muss groß genug sein, um sowohl Z4_außen (rechts) als
// auch das Rohrloch bei (0,0) (links) abzudecken.
// 
// Von versatz_4 aus gesehen:
//   - Nach rechts: zylinder_4_aussen (Z4_außen)
//   - Nach links:  versatz_4 + rohr_radius (Rohrloch bei 0,0)
// 
// Der größere Wert bestimmt den Radius, plus Wandstärke für den Rand.
aussenkante_wandteil = max(zylinder_4_aussen, versatz_4 + rohr_radius) + wand_dicke;







// Außenkante des Außenteils = bündig mit Zylinder 4_aussen
aussenkante_aussenteil = zylinder_4_aussen;

// Magnet-Positionen: auf Zylinder 3 (Mitte der Wandstärke)
magnet_kreis_radius = (zylinder_3_innen + zylinder_3_aussen) / 2;

// Winkel für 3 Magnete (120° Abstand, 3-Punkt = kein Wackeln)
magnet_winkel = [30, 150, 270];


// ============================================================
// MODULE: Hohlzylinder (einfach, robust)
// ============================================================
module hollow_cylinder(inner_r, outer_r, h) {
    difference() {
        cylinder(r = outer_r, h = h);
        translate([0, 0, -0.01])
            cylinder(r = inner_r, h = h + 0.02);
    }
}

// ============================================================
// MODULE: Abgerundeter Hohlzylinder (obere Kante)
// ============================================================
module rounded_hollow_cylinder(inner_r, outer_r, h, r_corner) {
    // Baut einen Hohlzylinder mit abgerundeten Oberkanten
    
    if (r_corner <= 0) {
        hollow_cylinder(inner_r, outer_r, h);
    } else {
        difference() {
            // Basis-Hohlzylinder
            hollow_cylinder(inner_r, outer_r, h);
            
            // Obere Kante innen abrunden
            translate([0, 0, h - r_corner])
                rotate_extrude(angle = 360, convexity = 4)
                    translate([inner_r, 0, 0])
                        difference() {
                            square([r_corner + 0.1, r_corner + 0.1]);
                            translate([r_corner, r_corner])
                                circle(r = r_corner, $fn = 24);
                        }
            
            // Obere Kante außen abrunden
            translate([0, 0, h - r_corner])
                rotate_extrude(angle = 360, convexity = 4)
                    translate([outer_r, 0, 0])
                        difference() {
                            square([-r_corner - 0.1, r_corner + 0.1]);
                            translate([-r_corner, r_corner])
                                circle(r = r_corner, $fn = 24);
                        }
        }
    }
}

// ============================================================
// MODULE: Abgerundete Scheibe (für Boden/Vorderwand)
// ============================================================
module rounded_disc(outer_r, inner_r, h, r_corner) {
    // Runde Scheibe mit optionalem Loch und abgerundeten Außenkanten
    // Wenn inner_r <= 0, wird kein Loch gemacht
    
    if (r_corner <= 0) {
        // Einfache Scheibe ohne Abrundung
        if (inner_r > 0) {
            difference() {
                cylinder(r = outer_r, h = h);
                translate([0, 0, -0.01])
                    cylinder(r = inner_r, h = h + 0.02);
            }
        } else {
            cylinder(r = outer_r, h = h);
        }
    } else {
        // Scheibe mit abgerundeter Außenkante oben
        difference() {
            if (inner_r > 0) {
                difference() {
                    cylinder(r = outer_r, h = h);
                    translate([0, 0, -0.01])
                        cylinder(r = inner_r, h = h + 0.02);
                }
            } else {
                cylinder(r = outer_r, h = h);
            }
            
            // Obere Außenkante abrunden
            translate([0, 0, h - r_corner])
                rotate_extrude(angle = 360, convexity = 4)
                    translate([outer_r, 0, 0])
                        difference() {
                            square([-r_corner - 0.1, r_corner + 0.1]);
                            translate([-r_corner, r_corner])
                                circle(r = r_corner, $fn = 24);
                        }
        }
    }
}

// ============================================================
// WANDTEIL (Wall Part)
// ============================================================
module wandteil() {
    // 1. Hintere Wand (Bodenplatte) mit Loch
    // Die Bodenplatte ist deckungsgleich mit der Vorderwand des Außenteils:
    // gleicher Mittelpunkt (versatz_4), gleicher Außenradius.
    // Das Rohrloch (rohr_radius) bleibt bei (0,0) — die Bodenplatte ist
    // groß genug, dass das Loch innerhalb der Scheibe liegt.
    module bodenplatte() {
        // Scheibe bei versatz_4 mit Loch bei (0,0)
        // Das Loch ist bündig mit Z1_innen (loch_radius = 65mm = Wandloch).
        // Zylinder 1 sitzt direkt auf dem Lochrand.
        difference() {
            translate([versatz_4, 0, 0])
                rounded_disc(
                    outer_r = aussenkante_wandteil,
                    inner_r = 0,
                    h = boden_dicke,
                    r_corner = radius_aussen
                );
            translate([0, 0, -0.01])
                cylinder(r = zylinder_1_innen, h = boden_dicke + 0.02);
        }
    }




    
    // 2. Zylinder 1 (innerster Ring um das Rohr)
    // Höhe = zylinder_1_hoehe (axialer Spalt zur Vorderwand)
    module zylinder_1() {
        translate([0, 0, boden_dicke])
            rounded_hollow_cylinder(
                zylinder_1_innen, zylinder_1_aussen,
                zylinder_1_hoehe, radius_zylinder
            );
    }
    
    // 3. Zylinder 3 (dritter Ring, äußerer Ring des Wandteils)
    // Höhe = zylinder_3_hoehe (axialer Spalt zur Vorderwand)
    // Mit integrierten Magnetsäulen, die von der Bodenplatte (Innenseite)
    // durch Zylinder 3 hindurchgehen und über die Oberkante hinausragen.
    // Die Säulen sind in die Wand von Zylinder 3 integriert (gleicher Radius),
    // sodass sie keinen separaten Luftwiderstand erzeugen.
    // Sie starten bei Z=0 (Bodenplatte) und ragen um magnet_saeule_hoehe
    // über die Oberkante von Zylinder 3 hinaus.
    // Die korrespondierenden Magnete werden auf die Mini-Säulen der Vorderwand
    // (Außenteil) geklebt.
    // Zylinder 3 hat einen eigenen proportionalen Versatz (versatz_3).
    module zylinder_3() {
        translate([versatz_3, 0, 0]) {
            union() {
                // Basis-Zylinder 3 (ohne Abrundung für CGAL-Kompatibilität mit Säulen)
                translate([0, 0, boden_dicke])
                    hollow_cylinder(
                        zylinder_3_innen, zylinder_3_aussen,
                        zylinder_3_hoehe
                    );
                
                // Magnetsäulen: starten bei der Bodenplatte (Z=0), gehen durch
                // Zylinder 3 hindurch und ragen über die Oberkante hinaus.
                // Gesamthöhe = boden_dicke + zylinder_3_hoehe + magnet_saeule_hoehe
                for (w = magnet_winkel) {
                    mx = magnet_kreis_radius * cos(w);
                    my = magnet_kreis_radius * sin(w);
                    translate([mx, my, 0])
                        cylinder(
                            d = magnet_durchmesser,
                            h = boden_dicke + zylinder_3_hoehe + magnet_saeule_hoehe,
                            $fn = 36
                        );
                }
            }
        }
    }




    
    // Alles zusammensetzen
    union() {
        bodenplatte();
        zylinder_1();
        zylinder_3();
    }


}

// ============================================================
// AUSSENTEIL (Outer Part)
// ============================================================
module aussenteil() {
    // Jeder Zylinder hat seinen eigenen proportionalen Versatz.
    // Die Vorderwand wird um versatz_4 verschoben (bündig mit Z4).
    
    module vordere_wand() {
        // Geschlossene runde Scheibe (Luft tritt radial ein)
        // Außenkante bündig mit Zylinder 4_aussen
        translate([versatz_4, 0, 0])
            rounded_disc(
                outer_r = aussenkante_aussenteil,
                inner_r = 0,
                h = boden_dicke,
                r_corner = radius_aussen
            );
    }
    
    module zylinder_2() {
        // Zweiter Ring (passt zwischen Zylinder 1 und 3)
        // Höhe = zylinder_2_hoehe (axialer Spalt zur Bodenplatte)
        // Einfacher Hohlzylinder ohne Magnete (Magnete sind auf Zylinder 3)
        // Eigener proportionaler Versatz: versatz_2
        translate([versatz_2, 0, -zylinder_2_hoehe])
            hollow_cylinder(
                zylinder_2_innen, zylinder_2_aussen,
                zylinder_2_hoehe
            );
    }

    
    module zylinder_4() {
        // Äußerster Ring (umschließt Zylinder 3)
        // Höhe = zylinder_4_hoehe (axialer Spalt zur Bodenplatte)
        // Eigener proportionaler Versatz: versatz_4
        translate([versatz_4, 0, -zylinder_4_hoehe])
            rounded_hollow_cylinder(
                zylinder_4_innen, zylinder_4_aussen,
                zylinder_4_hoehe, radius_zylinder
            );
    }

    
    // Mini-Säulen auf der Rückseite der Vorderwand als Markierung
    // für die Magnet-Positionen (2mm hoch, damit man weiß wo die
    // Magnete hingeklebt werden)
    // Die Markierungen müssen bei versatz_3 sein (Position von Zylinder 3),
    // da die Magnetsäulen von Zylinder 3 bei versatz_3 sind.
    // Relativ zur Vorderwand (bei versatz_4) sind sie bei (versatz_3 - versatz_4, 0).
    module magnet_markierungen() {
        translate([versatz_4, 0, 0]) {
            for (w = magnet_winkel) {
                mx = (versatz_3 - versatz_4) + magnet_kreis_radius * cos(w);
                my = magnet_kreis_radius * sin(w);
                translate([mx, my, -magnet_markierung_hoehe])
                    cylinder(d = magnet_durchmesser, h = magnet_markierung_hoehe, $fn = 36);
            }
        }
    }

    
    // Alles zusammensetzen
    union() {
        vordere_wand();
        zylinder_2();
        zylinder_4();
        magnet_markierungen();
    }

}




// ============================================================
// GESAMTMODELL (für Render/Export)
// ============================================================
module schalldaempfer() {
    // Wandteil: Boden bei Z=0, Zylinder nach oben
    wandteil();
    
    // Außenteil: Vordere Wand bei Z = boden_dicke + zylinder_tiefe
    // Zylinder ragen nach unten (negative Z) in die Zylinder des Wandteils
    translate([0, 0, boden_dicke + zylinder_tiefe])
        aussenteil();
}

// ============================================================
// DÄMMSCHICHTEN (separat druckbar, z.B. aus TPU ohne Wände)
// 
// Die Dämmungen liegen immer auf der Seite, wo die jeweilige
// Wand angeschlossen ist:
//   - Dämmung 1 + 3: auf der Vorderwand (Außenteil)
//   - Dämmung 2:      auf der Bodenplatte (Wandteil)
// ============================================================

// Dämmring 1: Im Innenhof von Zylinder 2 (von Z1_außen bis Z2_innen)
// Liegt auf der Vorderwand des Außenteils (wo Z2 angeschlossen ist).
// Volle Scheibe ohne Loch — Z1 gehört zum Wandteil und ist nicht hier.
// Position = Position von Z2 (versatz_2), da Z2 der innere Zylinder des Außenteils ist.
module daemmung_1() {
    translate([versatz_2, 0, 0])
        cylinder(r = zylinder_2_innen - 0.2, h = daemmung_dicke);
}

// Dämmring 2: Zwischen Zylinder 1 (bei 0,0) und Zylinder 3 (bei versatz_3)
// Überbrückt den gesamten Bereich zwischen Wand 1 und Wand 3.
// Liegt auf der Bodenplatte des Wandteils (wo Z1 und Z3 angeschlossen sind).
// Position = Position von Z3 (versatz_3), da Z3 der äußere Zylinder des Wandteils ist.
// Das innere Loch ist für Z1_außen bei (0,0) — relativ zu versatz_3 bei (-versatz_3, 0).
module daemmung_2() {
    translate([versatz_3, 0, 0]) {
        difference() {
            cylinder(r = zylinder_3_innen - 0.2, h = daemmung_dicke);
            translate([-versatz_3, 0, -0.01])
                cylinder(r = zylinder_1_aussen + 0.2, h = daemmung_dicke + 0.02);
        }
    }
}


// Dämmring 3: Zwischen Zylinder 2 (bei versatz_2) und Zylinder 4 (bei versatz_4)
// Überbrückt den gesamten Bereich zwischen Wand 2 und Wand 4.
// Liegt auf der Vorderwand des Außenteils (wo Z2 und Z4 angeschlossen sind).
// Hat Aussparungen für die Magnetsäulen von Zylinder 3 (bei versatz_3).
// Position = Position von Z4 (versatz_4), da Z4 der äußere Zylinder des Außenteils ist.
// Das innere Loch ist für Z2_außen bei versatz_2 — relativ zu versatz_4 bei (versatz_2 - versatz_4, 0).
// Die Magnetsäulen-Löcher sind für Z3 bei versatz_3 — relativ zu versatz_4 bei (versatz_3 - versatz_4, 0).
module daemmung_3() {
    translate([versatz_4, 0, 0]) {
        difference() {
            cylinder(r = zylinder_4_innen - 0.2, h = daemmung_dicke);
            
            // Inneres Loch (Wand 2 außen bei versatz_2)
            translate([versatz_2 - versatz_4, 0, -0.01])
                cylinder(r = zylinder_2_aussen + 0.2, h = daemmung_dicke + 0.02);
            
            // Aussparungen für die Magnetsäulen von Zylinder 3 (bei versatz_3)
            // Die Säulen sind bei magnet_kreis_radius relativ zu versatz_3.
            // Relativ zu versatz_4: (versatz_3 - versatz_4, 0) + Winkel-Offset.
            for (w = magnet_winkel) {
                mx = (versatz_3 - versatz_4) + magnet_kreis_radius * cos(w);
                my = magnet_kreis_radius * sin(w);
                translate([mx, my, -0.01])
                    cylinder(d = magnet_durchmesser + 0.5, h = daemmung_dicke + 0.02, $fn = 36);
            }
        }
    }
}








// ============================================================
// EINZELTEILE (für separaten STL-Export)
// ============================================================

module nur_wandteil() {
    wandteil();
}

module nur_aussenteil() {
    // Außenteil so verschieben, dass die Vorderwand bei Z=0 liegt
    // (flach auf dem Druckbett). Die Zylinder ragen nach unten (negative Z).
    aussenteil();
}


module nur_daemmung_1() {
    daemmung_1();
}

module nur_daemmung_2() {
    daemmung_2();
}

module nur_daemmung_3() {
    daemmung_3();
}

// ============================================================
// HILFSANSICHT: Querschnitt
// ============================================================
module querschnitt() {
    difference() {
        schalldaempfer();
        translate([-100, -100, -10])
            cube([100, 200, 200]);
    }
}


