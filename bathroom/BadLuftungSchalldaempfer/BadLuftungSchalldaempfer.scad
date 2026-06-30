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

// --- Maximaler Außendurchmesser ---
max_durchmesser    = 200;   // Druckbett 200mm Durchmesser
max_radius         = max_durchmesser / 2;

// --- Wandstärken ---
wand_dicke         = 3.0;   // Zylinder-Wandstärke (mm)
boden_dicke        = 3.0;   // Vordere/hintere Wandstärke (mm)

// --- Labyrinth ---
labyrinth_ueberlappung = 20.0;  // Überlappung der Zylinder im Labyrinth (mm)

// --- Dämmmaterial ---
daemmung_dicke     = 6.0;   // TPU-Dämmring (mm)

// --- Magnete (Befestigung Außenteil) ---
magnet_durchmesser = 6.0;   // Neodym-Magnet Durchmesser (mm)
magnet_dicke       = 2.0;   // Neodym-Magnet Dicke (mm)
magnet_anzahl      = 3;     // Anzahl Magnete (3-Punkt = kein Wackeln)

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

// --- Axiale Spalte (Strömungsfläche = A_rohr) ---
axial_spalt_1 = A_rohr / (2 * PI * zylinder_1_aussen) + daemmung_dicke;
axial_spalt_2 = A_rohr / (2 * PI * zylinder_2_aussen) + daemmung_dicke;
axial_spalt_3 = A_rohr / (2 * PI * zylinder_3_aussen) + daemmung_dicke;

// --- Zylinder-Höhen (basierend auf Labyrinth-Überlappung) ---
// Z1 ragt von der Bodenplatte nach oben, Z2 ragt von der Vorderwand nach unten
// Überlappung = zylinder_1_hoehe + zylinder_2_hoehe - zylinder_tiefe
// Mit zylinder_2_hoehe = zylinder_tiefe - axial_spalt_2:
// Überlappung = zylinder_1_hoehe - axial_spalt_2
// => zylinder_1_hoehe = labyrinth_ueberlappung + axial_spalt_2
zylinder_1_hoehe = labyrinth_ueberlappung + axial_spalt_2;

// zylinder_tiefe = Abstand Bodenplatte → Vorderwand
zylinder_tiefe = zylinder_1_hoehe + axial_spalt_1;

// Z2 ragt von der Vorderwand zurück zur Bodenplatte
zylinder_2_hoehe = zylinder_tiefe - axial_spalt_2;

// Z3 reicht bis zur Vorderwand-Oberseite des Außenteils
// = boden_dicke (Bodenplatte) + zylinder_tiefe (bis Vorderwand) + boden_dicke (Vorderwand-Dicke)
// Abzüglich boden_dicke (Start auf Bodenplatte) = zylinder_tiefe + boden_dicke
zylinder_3_hoehe = zylinder_tiefe + boden_dicke;

// Außenkanten
aussenkante_wandteil   = zylinder_3_aussen;  // Bodenplatte: bündig mit Z3
aussenkante_aussenteil = zylinder_2_aussen;  // Vorderwand: bündig mit Z2

// Magnet-Positionen: auf der Unterseite der Vorderwand (innerhalb von Z2_aussen)
// Die Säulen ragen von der Vorderwand nach unten zur Bodenplatte
magnet_kreis_radius = zylinder_2_aussen - magnet_durchmesser / 2;

// Winkel für 3 Magnete (120° Abstand, 3-Punkt = kein Wackeln)
magnet_winkel = [30, 150, 270];

// Säulenhöhe = Z2_Höhe + axialer Spalt 2 - boden_dicke + daemmung_dicke
// Die Säulen wachsen von der Vorderwand-Innenseite (z=0) und ragen durch die Dämmung 1
// (die auf der Vorderwand-Innenseite liegt, z=0 bis z=-daemmung_dicke)
// bis zu den Podesten auf der Bodenplatte (Podest-Oberseite bei z=boden_dicke+magnet_dicke)
// Die +daemmung_dicke sorgt dafür, dass die Säulen 1mm über die Podeste ragen
// (für Magnet-Kontakt: Podest-Oberseite bei z=boden_dicke+magnet_dicke)
saeule_z2_hoehe = zylinder_2_hoehe + axial_spalt_2 - boden_dicke + daemmung_dicke;

// ============================================================
// MODULE: Grundkörper mit Abrundungen via BOSL2 round_corners()
// ============================================================

// Hohlzylinder mit abgerundeter Oberkante (für Wandteil: Z1, Z3)
module hollow_cylinder_oben(inner_r, outer_r, h) {
    breite = outer_r - inner_r;
    eff_r = min(radius_zylinder, h, breite / 2);
    
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

// Hohlzylinder mit abgerundeter Unterkante (für Außenteil: Z2)
module hollow_cylinder_unten(inner_r, outer_r, h) {
    breite = outer_r - inner_r;
    eff_r = min(radius_zylinder, h, breite / 2);
    
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

// Scheibe mit abgerundeter Außenkante (oben oder unten)
// oben=true: Abrundung oben-außen (für Vorderwand Außenteil)
// oben=false: Abrundung unten-außen (für Bodenplatte Wandteil)
module scheibe_mit_abrundung(outer_r, h, r_corner, oben = true) {
    eff_r = min(r_corner, h);
    
    path = oben
        ? [
            [0, 0],          // Ecke 0: unten-innen (scharf)
            [outer_r, 0],    // Ecke 1: unten-außen (scharf)
            [outer_r, h],    // Ecke 2: oben-außen (gerundet)
            [0, h]           // Ecke 3: oben-innen (scharf)
          ]
        : [
            [0, 0],          // Ecke 0: unten-innen (scharf)
            [outer_r, 0],    // Ecke 1: unten-außen (gerundet)
            [outer_r, h],    // Ecke 2: oben-außen (scharf)
            [0, h]           // Ecke 3: oben-innen (scharf)
          ];
    radii = oben ? [0, 0, eff_r, 0] : [0, eff_r, 0, 0];
    
    rotate_extrude(angle = 360, convexity = 4)
        polygon(round_corners(path, radius = radii, $fn = 24));
}

// ============================================================
// WANDTEIL (Wall Part)
// ============================================================
module wandteil() {
    // 1. Hintere Wand (Bodenplatte) mit Loch
    // Abrundung unten-außen (zur Wand hin)
    module bodenplatte() {
        difference() {
            scheibe_mit_abrundung(aussenkante_wandteil, boden_dicke, radius_aussen, oben = false);
            // Rohrloch
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
    
    // 3. Zylinder 3 (äußerer Ring des Wandteils) — Abrundung oben
    module zylinder_3() {
        translate([0, 0, boden_dicke])
            hollow_cylinder_oben(
                zylinder_3_innen, zylinder_3_aussen,
                zylinder_3_hoehe
            );
    }

    // 4. Kleine Podeste auf der Bodenplatte (gegenüber von den Säulen in Z2)
    //    Für die Gegenmagnete — nur magnet_dicke hoch
    module gegen_podeste() {
        for (w = magnet_winkel) {
            mx = magnet_kreis_radius * cos(w);
            my = magnet_kreis_radius * sin(w);
            translate([mx, my, boden_dicke])
                cylinder(
                    d = magnet_durchmesser,
                    h = magnet_dicke,
                    $fn = 36
                );
        }
    }

    // Alles zusammensetzen
    union() {
        bodenplatte();
        zylinder_1();
        zylinder_3();
        gegen_podeste();
    }
}

// ============================================================
// AUSSENTEIL (Outer Part)
// ============================================================
module aussenteil() {
    // Vordere Wand — Abrundung oben, mit Magnetsäulen auf der Unterseite
    // Die Säulen ragen von der Vorderwand (z=0) nach unten zur Bodenplatte
    // und definieren den axialen Spalt 2
    // Die Dämmung 1 liegt auf der Unterseite (z=0 bis z=-daemmung_dicke)
    // und hat Aussparungen für die Säulen
    module vordere_wand() {
        union() {
            // Basis-Scheibe
            scheibe_mit_abrundung(aussenkante_aussenteil, boden_dicke, radius_aussen);
            
            // Magnetsäulen auf der Unterseite der Vorderwand (bei z = 0)
            // Ragen nach unten zur Bodenplatte
            for (w = magnet_winkel) {
                mx = magnet_kreis_radius * cos(w);
                my = magnet_kreis_radius * sin(w);
                translate([mx, my, -saeule_z2_hoehe])
                    cylinder(
                        d = magnet_durchmesser,
                        h = saeule_z2_hoehe,
                        $fn = 36
                    );
            }
        }
    }

    // Zylinder 2 — Abrundung unten (zeigt in den Luftspalt)
    module zylinder_2() {
        translate([0, 0, -zylinder_2_hoehe])
            hollow_cylinder_unten(
                zylinder_2_innen, zylinder_2_aussen,
                zylinder_2_hoehe
            );
    }

    union() {
        vordere_wand();
        zylinder_2();
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

// Dämmung 1: auf der Unterseite der Vorderwand (Außenteil), innerhalb von Z2
// Mit Aussparungen für die Magnetsäulen (die Säulen ragen durch die Dämmung)
module daemmung_1() {
    difference() {
        cylinder(r = zylinder_2_innen - 0.2, h = daemmung_dicke);
        // Aussparungen für die Magnetsäulen
        for (w = magnet_winkel) {
            mx = magnet_kreis_radius * cos(w);
            my = magnet_kreis_radius * sin(w);
            translate([mx, my, -0.01])
                cylinder(d = magnet_durchmesser + 0.5, h = daemmung_dicke + 0.02, $fn = 36);
        }
    }
}

// Dämmung 2: auf der Bodenplatte (Wandteil), zwischen Z1 und Z3
// Mit Aussparungen für die Gegen-Podeste (für Magnete auf der Bodenplatte)
module daemmung_2() {
    difference() {
        cylinder(r = zylinder_3_innen - 0.2, h = daemmung_dicke);
        cylinder(r = zylinder_1_aussen + 0.2, h = daemmung_dicke + 0.02);
        // Aussparungen für Gegen-Podeste auf der Bodenplatte
        for (w = magnet_winkel) {
            mx = magnet_kreis_radius * cos(w);
            my = magnet_kreis_radius * sin(w);
            translate([mx, my, -0.01])
                cylinder(d = magnet_durchmesser + 0.5, h = daemmung_dicke + 0.02, $fn = 36);
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

// ============================================================
// EXPORT-AUSWAHL (via -D export_part="..." von OpenSCAD CLI)
// ============================================================

// Standard: nichts (für render.scad)
// export_part = "wandteil" | "aussenteil" | "daemmung_1" | "daemmung_2"
export_part = "none";

if (export_part == "wandteil") {
    nur_wandteil();
} else if (export_part == "aussenteil") {
    nur_aussenteil();
} else if (export_part == "daemmung_1") {
    nur_daemmung_1();
} else if (export_part == "daemmung_2") {
    nur_daemmung_2();
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
