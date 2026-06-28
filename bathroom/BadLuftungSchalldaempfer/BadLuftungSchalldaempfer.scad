// ============================================================
// BadLuftungSchalldaempfer — Schalldämpfer für Badezimmer-Lüftung
// Siehe README.md für Design-Beschreibung und Montage.
// ============================================================

include <BOSL2/std.scad>

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

// --- Magnete (Befestigung Außenteil) ---
magnet_durchmesser = 6.0;   // Neodym-Magnet Durchmesser (mm)
magnet_dicke       = 2.0;   // Neodym-Magnet Dicke (mm)
magnet_anzahl      = 3;     // Anzahl Magnete (3-Punkt = kein Wackeln)

// Mini-Säulen auf der Vorderwand als Markierung (2mm hoch)
magnet_markierung_hoehe = 2.0;

// --- Abrundungen ---
radius_aussen      = 5.0;   // Äußere Kanten-Abrundung (mm)
radius_zylinder    = 2.0;   // Zylinder-Endkanten Abrundung (mm)

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
zylinder_1_innen  = loch_radius;
zylinder_1_aussen = zylinder_1_innen + wand_dicke;

spalt_12 = A_rohr / (2 * PI * zylinder_1_aussen);
zylinder_2_innen  = zylinder_1_aussen + spalt_12;
zylinder_2_aussen = zylinder_2_innen + wand_dicke;

spalt_23 = A_rohr / (2 * PI * zylinder_2_aussen);
zylinder_3_innen  = zylinder_2_aussen + spalt_23;
zylinder_3_aussen = zylinder_3_innen + wand_dicke;

spalt_34 = A_rohr / (2 * PI * zylinder_3_aussen);
zylinder_4_innen  = zylinder_3_aussen + spalt_34;
zylinder_4_aussen = zylinder_4_innen + wand_dicke;

// --- Axiale Spalte ---
axial_spalt_1 = A_rohr / (2 * PI * zylinder_1_aussen) + daemmung_dicke;
axial_spalt_2 = A_rohr / (2 * PI * zylinder_2_aussen) + daemmung_dicke;
axial_spalt_3 = A_rohr / (2 * PI * zylinder_3_aussen) + daemmung_dicke;
axial_spalt_4 = A_rohr / (2 * PI * zylinder_4_aussen) + daemmung_dicke;

zylinder_tiefe = zylinder_mindest_hoehe + axial_spalt_1;

zylinder_1_hoehe = zylinder_tiefe - axial_spalt_1;  // = zylinder_mindest_hoehe
zylinder_2_hoehe = zylinder_tiefe - axial_spalt_2;
zylinder_3_hoehe = zylinder_tiefe - axial_spalt_3;
zylinder_4_hoehe = zylinder_tiefe - axial_spalt_4;

// Säulenhöhe = radialer Eintrittsspalt zwischen Z3-Oberkante und Vorderwand
eintrittsspalt = A_rohr / (2 * PI * zylinder_3_aussen);
magnet_saeule_hoehe = eintrittsspalt - 2 * magnet_dicke;

// --- Proportionaler Versatz der Zylinder ---
radius_spanne = zylinder_4_aussen - zylinder_1_aussen;
versatz_4 = zylinder_4_aussen - max_radius_ecke;
versatz_2 = versatz_4 * (zylinder_2_aussen - zylinder_1_aussen) / radius_spanne;
versatz_3 = versatz_4 * (zylinder_3_aussen - zylinder_1_aussen) / radius_spanne;

// Außenkante des Wandteils
aussenkante_wandteil = max(zylinder_4_aussen, versatz_4 + rohr_radius) + wand_dicke;

// Außenkante des Außenteils = bündig mit Zylinder 4_aussen
aussenkante_aussenteil = zylinder_4_aussen;

// Magnet-Positionen: auf Zylinder 3 (Mitte der Wandstärke)
magnet_kreis_radius = (zylinder_3_innen + zylinder_3_aussen) / 2;

// Winkel für 3 Magnete (120° Abstand, 3-Punkt = kein Wackeln)
magnet_winkel = [30, 150, 270];

// ============================================================
// MODULE: Grundkörper mit Abrundungen via BOSL2 round_corners()
// ============================================================

// Hohlzylinder mit abgerundeter Oberkante (für Wandteil: Z1, Z3)
// Das freie Ende ist oben (Z = h) — beide Kanten (innen + außen) werden gerundet.
// round_corners: Ecke 0=unten-innen, 1=unten-außen, 2=oben-außen, 3=oben-innen
module hollow_cylinder_oben(inner_r, outer_r, h) {
    breite = outer_r - inner_r;
    // Radius begrenzt: nicht größer als Höhe und maximal halbe Breite (sonst Überschneidung)
    eff_r = min(radius_zylinder, h, breite / 2);
    
    // 2D-Profil: Rechteck [breite, h] mit Abrundung an Ecke 2+3 (oben-außen + oben-innen)
    path = [
        [0, 0],          // Ecke 0: unten-innen (scharf)
        [breite, 0],     // Ecke 1: unten-außen (scharf)
        [breite, h],     // Ecke 2: oben-außen (gerundet)
        [0, h]           // Ecke 3: oben-innen (gerundet)
    ];
    radii = [0, 0, eff_r, eff_r];
    
    rotate_extrude(angle = 360, convexity = 4)
        translate([inner_r, 0, 0])
            polygon(round_corners(path, radius = radii, $fn = 24));
}

// Hohlzylinder mit abgerundeter Unterkante (für Außenteil: Z2, Z4)
// Das freie Ende ist unten (Z = 0) — beide Kanten (innen + außen) werden gerundet.
// round_corners: Ecke 0=unten-innen, 1=unten-außen, 2=oben-außen, 3=oben-innen
module hollow_cylinder_unten(inner_r, outer_r, h) {
    breite = outer_r - inner_r;
    // Radius begrenzt: nicht größer als Höhe und maximal halbe Breite (sonst Überschneidung)
    eff_r = min(radius_zylinder, h, breite / 2);
    
    // 2D-Profil: Rechteck [breite, h] mit Abrundung an Ecke 0+1 (unten-innen + unten-außen)
    path = [
        [0, 0],          // Ecke 0: unten-innen (gerundet)
        [breite, 0],     // Ecke 1: unten-außen (gerundet)
        [breite, h],     // Ecke 2: oben-außen (scharf)
        [0, h]           // Ecke 3: oben-innen (scharf)
    ];
    radii = [eff_r, eff_r, 0, 0];
    
    rotate_extrude(angle = 360, convexity = 4)
        translate([inner_r, 0, 0])
            polygon(round_corners(path, radius = radii, $fn = 24));
}

// Scheibe mit abgerundeter oberer Außenkante
// round_corners: Ecke 0=unten-innen, 1=unten-außen, 2=oben-außen, 3=oben-innen
module scheibe_mit_abrundung(outer_r, h, r_corner) {
    eff_r = min(r_corner, h);
    
    // 2D-Profil: Rechteck [outer_r, h] mit Abrundung an Ecke 2 (oben-außen)
    path = [
        [0, 0],          // Ecke 0: unten-innen (scharf)
        [outer_r, 0],    // Ecke 1: unten-außen (scharf)
        [outer_r, h],    // Ecke 2: oben-außen (gerundet)
        [0, h]           // Ecke 3: oben-innen (scharf)
    ];
    radii = [0, 0, eff_r, 0];
    
    rotate_extrude(angle = 360, convexity = 4)
        polygon(round_corners(path, radius = radii, $fn = 24));
}

// ============================================================
// WANDTEIL (Wall Part)
// ============================================================
module wandteil() {
    // 1. Hintere Wand (Bodenplatte) mit Loch
    module bodenplatte() {
        difference() {
            translate([versatz_4, 0, 0])
                scheibe_mit_abrundung(aussenkante_wandteil, boden_dicke, radius_aussen);
            translate([0, 0, -0.01])
                cylinder(r = zylinder_1_innen, h = boden_dicke + 0.02);
        }
    }

    // 2. Zylinder 1 (innerster Ring um das Rohr) — Abrundung oben
    module zylinder_1() {
        translate([0, 0, boden_dicke])
            hollow_cylinder_oben(
                zylinder_1_innen, zylinder_1_aussen,
                zylinder_1_hoehe
            );
    }
    
    // 3. Zylinder 3 (dritter Ring, äußerer Ring des Wandteils) — Abrundung oben
    module zylinder_3() {
        translate([versatz_3, 0, 0]) {
            union() {
                // Basis-Zylinder 3
                translate([0, 0, boden_dicke])
                    hollow_cylinder_oben(
                        zylinder_3_innen, zylinder_3_aussen,
                        zylinder_3_hoehe
                    );
                
                // Magnetsäulen
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
    // Vordere Wand — Abrundung oben
    module vordere_wand() {
        translate([versatz_4, 0, 0])
            scheibe_mit_abrundung(aussenkante_aussenteil, boden_dicke, radius_aussen);
    }

    // Zylinder 2 — Abrundung unten (zeigt in den Luftspalt)
    module zylinder_2() {
        translate([versatz_2, 0, -zylinder_2_hoehe])
            hollow_cylinder_unten(
                zylinder_2_innen, zylinder_2_aussen,
                zylinder_2_hoehe
            );
    }

    // Zylinder 4 — Abrundung unten (zeigt in den Luftspalt)
    module zylinder_4() {
        translate([versatz_4, 0, -zylinder_4_hoehe])
            hollow_cylinder_unten(
                zylinder_4_innen, zylinder_4_aussen,
                zylinder_4_hoehe
            );
    }

    // Mini-Säulen auf der Rückseite der Vorderwand als Markierung
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
    wandteil();
    translate([0, 0, boden_dicke + zylinder_tiefe])
        aussenteil();
}

// ============================================================
// DÄMMSCHICHTEN (separat druckbar, z.B. aus TPU ohne Wände)
// ============================================================

module daemmung_1() {
    translate([versatz_2, 0, 0])
        cylinder(r = zylinder_2_innen - 0.2, h = daemmung_dicke);
}

module daemmung_2() {
    translate([versatz_3, 0, 0]) {
        difference() {
            cylinder(r = zylinder_3_innen - 0.2, h = daemmung_dicke);
            translate([-versatz_3, 0, -0.01])
                cylinder(r = zylinder_1_aussen + 0.2, h = daemmung_dicke + 0.02);
        }
    }
}

module daemmung_3() {
    translate([versatz_4, 0, 0]) {
        difference() {
            cylinder(r = zylinder_4_innen - 0.2, h = daemmung_dicke);
            translate([versatz_2 - versatz_4, 0, -0.01])
                cylinder(r = zylinder_2_aussen + 0.2, h = daemmung_dicke + 0.02);
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

module nur_wandteil() { wandteil(); }
module nur_aussenteil() { aussenteil(); }
module nur_daemmung_1() { daemmung_1(); }
module nur_daemmung_2() { daemmung_2(); }
module nur_daemmung_3() { daemmung_3(); }

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
