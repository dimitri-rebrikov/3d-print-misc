// Spulen-Organizer — Parametrischer Nähspulen-Ständer
// =====================================================
//
// Ein Tablett mit aufrechten Stiften für Nähmaschinenspulen.
// Nur vier Werte müssen von außen kommen: Spulendurchmesser,
// Stifthöhe, maximale Plattentiefe und -breite.
// Alles andere wird daraus abgeleitet.
//
// Abhängigkeiten: BOSL2 (https://github.com/BelfrySCAD/BOSL2)
//   Installation: ~/.local/share/OpenSCAD/libraries/BOSL2/
//
// Lizenz: MIT (siehe Hauptverzeichnis LICENSE)

include <BOSL2/std.scad>

// ─── Von außen kommende Werte ─────────────────────────────────────────────────
// Diese vier Parameter steuern das gesamte Modell.

/* [Spule] */
spulen_durchmesser = 21;    // [10:0.5:40]
  // Außendurchmesser der Nähspule (Class 15 ≈ 21 mm)
  // → bestimmt den Stiftabstand

/* [Stifte] */
stift_hoehe = 50;           // [20:5:80]
  // Höhe der Stifte (ragen über die Spulen hinaus)

/* [Platte] */
max_breite = 140;           // [50:5:350]
  // Gewünschte maximale Plattenbreite
  // → die Anzahl Spalten wird automatisch berechnet

max_tiefe = 290;            // [50:5:350]
  // Gewünschte maximale Plattentiefe
  // → die Anzahl Reihen wird automatisch berechnet

// ─── Optionale Feineinstellung ─────────────────────────────────────────────────

/* [Spulen-Feintuning] */
spulen_loch_durchmesser = 6.5;  // [4:0.5:12]
  // Innendurchmesser Spulenkern → Stiftdurchmesser = Loch - 1mm

/* [Design] */
platten_dicke = 2.5;        // [1.5:0.5:5]
eckradius = 5;              // [1:1:10]
konus_rundung = 2;          // [0.5:0.5:3]
  // Radius der Verrundung am Konusfuß (Übergang zur Platte)
stift_rundung_oben = 2;     // [0:0.5:3]
$fn = 32;
fingerausschnitt = true;    // [true, false]

// ─── Berechnungen ──────────────────────────────────────────────────────────────

// Abstand der Stifte = Spulendurchmesser + 6 mm Luft
stift_abstand = spulen_durchmesser + 6;

// Rand = halber Stiftabstand → Platte symmetrisch um die äußeren Stifte
rand = stift_abstand / 2;

// Raster aus max_breite und max_tiefe berechnen
spalten = floor(max_breite / stift_abstand);
reihen  = floor(max_tiefe  / stift_abstand);

// Stiftdurchmesser aus Spulenloch (1 mm Spiel)
stift_durchmesser = spulen_loch_durchmesser - 1.0;

// Konus an der Stiftbasis für stabileren Übergang
konus_durchmesser = stift_durchmesser + 4;  // ≈ 9,5 mm
konus_hoehe = 4;

// Plattenmaße (vereinfacht: rand = stift_abstand/2 → breite = spalten * abstand)
breite = spalten * stift_abstand;
tiefe  = reihen  * stift_abstand;

// Raster für grid_copies
stift_raster = [stift_abstand, stift_abstand];
stift_anzahl = [spalten, reihen];

// ─── Module ────────────────────────────────────────────────────────────────────

module bodenplatte() {
    cuboid(
        [breite, tiefe, platten_dicke],
        rounding = eckradius,
        edges = "Z",
        anchor = BOTTOM
    );
}

module fingerausschnitt() {
    if (fingerausschnitt) {
        difference() {
            children();
            translate([0, tiefe/2, 0])
                cylinder(d = 12, h = platten_dicke + 1);
        }
    } else {
        children();
    }
}

module stift() {
    // Konischer Fuß für stabilen Übergang zur Platte
    cyl(
        d1 = konus_durchmesser,
        d2 = stift_durchmesser,
        l = konus_hoehe,
        rounding1 = konus_rundung,
        rounding2 = 0,
        anchor = BOTTOM
    );
    // Gerader Stift
    up(konus_hoehe) {
        cyl(
            d = stift_durchmesser,
            l = stift_hoehe - konus_hoehe,
            rounding1 = 0,
            rounding2 = stift_rundung_oben,
            anchor = BOTTOM
        );
    }
}

module stifte() {
    grid_copies(spacing = stift_raster, n = stift_anzahl) {
        stift();
    }
}

// ─── Modell ───────────────────────────────────────────────────────────────────

module spulen_organizer() {
    fingerausschnitt() {
        bodenplatte();
    }
    up(platten_dicke) {
        stifte();
    }
}

spulen_organizer();

// ─── Info-Ausgabe ─────────────────────────────────────────────────────────────

echo(str("Stifte: ", spalten, " × ", reihen, " = ", spalten * reihen));
echo(str("Platte: ", breite, " × ", tiefe, " × ", platten_dicke, " mm"));
echo(str("Stiftabstand: ", stift_abstand, " mm, Rand: ", rand, " mm"));
