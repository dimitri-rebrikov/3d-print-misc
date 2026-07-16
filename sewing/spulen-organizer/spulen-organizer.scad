// Spulen-Organizer — Parametrischer Nähspulen-Ständer
// =====================================================
//
// Ein Tablett mit aufrechten Stiften für Nähmaschinenspulen (Class 15).
// Alle Maße sind parametrisch anpassbar.
//
// Abhängigkeiten: BOSL2 (https://github.com/BelfrySCAD/BOSL2)
//   Installation: ~/.local/share/OpenSCAD/libraries/BOSL2/
//   oder: OpenSCAD → Hilfe → Bibliotheks-Info → User Library Path
//
// Lizenz: MIT (siehe Hauptverzeichnis LICENSE)

include <BOSL2/std.scad>

// ─── Parameter ────────────────────────────────────────────────────────────────

/* [Spulen-Maße] */
spulen_loch_durchmesser = 6.5;  // [4:0.5:12]
  // Innendurchmesser des Spulenkerns (Class 15 ≈ 6.5 mm)
spulen_aussendurchmesser = 21;  // [15:0.5:30]
  // Außendurchmesser der Spule (Class 15 ≈ 21 mm)
spulen_hoehe = 11;              // [8:1:20]
  // Höhe der Spule (Class 15 ≈ 11 mm)

/* [Organizer-Maße] */
stift_durchmesser = spulen_loch_durchmesser - 1.0;
  // Stiftdurchmesser (1 mm Spiel für leichtes Auf-/Abstecken)
stift_hoehe = 50;
  // Stifthöhe (50 mm)
stift_abstand = 25;
  // Mittenabstand Stifte (25 mm)

reihen = 10;   // [1:1:15]
spalten = 5;   // [1:1:10]

platten_dicke = 4;   // [2:1:8]
  // Dicke der Bodenplatte
rand = 12.5;         // [1:1:20]
  // Abstand von äußeren Stiften zum Plattenrand
eckradius = 5;       // [1:1:10]
  // Radius der Kantenverrundung

/* [Stifte] */
stift_rundung_unten = 1;  // [0:0.5:3]
  // Radius der Verrundung am Stiftfuß (Übergang zur Platte)
stift_rundung_oben = 2;   // [0:0.5:3]
  // Radius der Verrundung an der Stiftspitze
sockel_durchmesser = stift_durchmesser + 5;
  // Durchmesser des kleinen Sockels am Stiftfuß
sockel_hoehe = 1.0;
  // Höhe des Sockels (hebt Spule von Platte ab)

/* [Erweitert] */
$fn = 32;
profil_aussparung = true;
  // Profil-Aussparung an der Stirnseite (zum Anheben des Organizers)
aussparung_breite = 12;
  // Breite der Profil-Aussparung
aussparung_tiefe = 6;
  // Tiefe der Profil-Aussparung

// ─── Berechnungen ─────────────────────────────────────────────────────────────

breite  = (spalten - 1) * stift_abstand + 2 * rand;
tiefe   = (reihen - 1) * stift_abstand + 2 * rand;
hoehe_gesamt = platten_dicke + stift_hoehe;
stift_raster = [stift_abstand, stift_abstand];
stift_anzahl = [spalten, reihen];

// ─── Module ────────────────────────────────────────────────────────────────────

module bodenplatte() {
    // Rechteckige Bodenplatte mit abgerundeten Kanten.
    // Die Bodenkante bleibt scharf (bessere Betthaftung beim Druck),
    // alle anderen Kanten werden verrundet.
    // edges="Z" rundet nur die vertikalen (Z-achsialen) Kanten.
    // Die Ober- und Unterseite bleiben flach — wichtig für
    // Betthaftung und saubere Optik.
    cuboid(
        [breite, tiefe, platten_dicke],
        rounding = eckradius,
        edges = "Z",
        anchor = BOTTOM
    );
}

module aussparung() {
    // Halbrunde Aussparung an der Vorderkante (erleichtert Anheben).
    if (profil_aussparung) {
        difference() {
            children();
            // Zylindrische Aussparung an der vorderen Kante der Platte
            translate([0, tiefe/2, 0])
                cylinder(d = aussparung_breite, h = platten_dicke + 1);
        }
    } else {
        children();
    }
}

module stift_sockel() {
    // Kleiner zylindrischer Sockel unter jedem Stift.
    // Hebt die Spule leicht an, damit sie nicht auf der Platte kratzt.
    cyl(
        d = sockel_durchmesser,
        l = sockel_hoehe,
        rounding1 = min(stift_rundung_unten, sockel_hoehe),
        rounding2 = 0,
        anchor = BOTTOM
    );
}

module stift() {
    // Einzelner Stift mit verrundeten Kanten.
    up(sockel_hoehe) {
        cyl(
            d = stift_durchmesser,
            l = stift_hoehe - sockel_hoehe,
            rounding1 = stift_rundung_unten,
            rounding2 = stift_rundung_oben,
            anchor = BOTTOM
        );
    }
    stift_sockel();
}

module stifte() {
    // Raster von Stiften mittels grid_copies().
    grid_copies(spacing = stift_raster, n = stift_anzahl) {
        stift();
    }
}

module label_bereich() {
    // Optional: kleiner erhabener Bereich an der Rückseite (BACK)
    // für einen Aufkleber oder eine Beschriftung.
    // (Derzeit deaktiviert — kann bei Bedarf aktiviert werden.)
    // position(BACK) down(platten_dicke - 0.5)
    //     cuboid([30, 2, 0.5], rounding=0.5, anchor=TOP);
}

// ─── Modell ───────────────────────────────────────────────────────────────────

module spulen_organizer() {
    aussparung() {
        bodenplatte();
    }
    
    // Stifte auf der Oberseite der Platte positionieren
    up(platten_dicke) {
        stifte();
    }
    
    label_bereich();
}

spulen_organizer();
