# Spulen-Organizer — Nähmaschinenspulen-Ständer

**Parametrischer Ständer für Nähmaschinenspulen (Class 15).**

Ein Tablett mit aufrechten Stiften, auf die Nähspulen aufgesteckt werden.
Alle Maße sind über OpenSCAD-Customizer anpassbar — für verschiedene
Spulengrößen, Rasterdimensionen und Designs.

## Eigenschaften

- **Parametrisch:** Spulengröße, Stiftanzahl, Abstände, Verrundungen — alles
  über den OpenSCAD-Customizer einstellbar
- **BOSL2:** Nutzt die Belfry OpenSCAD Library v2 für saubere Verrundungen
- **Druckfreundlich:** Flache Unterseite (scharfe Kanten für Betthaftung),
  abgerundete Ecken oben, optionaler halbrunder Fingerausschnitt
- **Stift-Sockel:** Kleiner zylindrischer Sockel am Fuß jedes Stifts hebt die
  Spule von der Platte ab — vermeidet Kratzer und erleichtert das Greifen

## Parameter (Customizer)

| Parameter | Default | Beschreibung |
|-----------|---------|-------------|
| `spulen_loch_durchmesser` | 6.5 mm | Innendurchmesser Spulenkern (Class 15) |
| `spulen_aussendurchmesser` | 21 mm | Außendurchmesser Spule |
| `spulen_hoehe` | 11 mm | Höhe der Spule |
| `reihen` | 10 | Reihen in Y-Richtung |
| `spalten` | 5 | Spalten in X-Richtung |
| `stift_abstand` | 25 mm | Mittenabstand der Stifte |
| `rand` | 12.5 mm | Rand um äußere Stifte |
| `platten_dicke` | 4 mm | Dicke der Bodenplatte |
| `eckradius` | 5 mm | Radius der Eckverrundung |
| `stift_rundung_oben` | 2 mm | Radius Stiftspitze (abgerundet) |
| `stift_rundung_unten` | 1 mm | Radius Stiftfuß (Übergang) |
| `profil_aussparung` | true | Fingerausschnitt an Vorderkante |
| `$fn` | 32 | Auflösung (höher = glatter, langsamer) |

## Dateien

| Datei | Beschreibung |
|-------|-------------|
| `spulen-organizer.scad` | Hauptmodell (alle Parameter + Module) |
| `render.scad` | Render-Skript (`openscad -o spulen-organizer.stl render.scad`) |
| `spulen-organizer.stl` | Exportiertes STL (10×5, Class 15) |
| `README.md` | Diese Datei |

## Abhängigkeiten

- **[BOSL2](https://github.com/BelfrySCAD/BOSL2)** — Belfry OpenSCAD Library v2
- **OpenSCAD 2021.01+**

### BOSL2 Installation

```bash
# Linux
mkdir -p ~/.local/share/OpenSCAD/libraries
cd ~/.local/share/OpenSCAD/libraries
curl -sL https://github.com/BelfrySCAD/BOSL2/archive/refs/heads/master.tar.gz | tar xz
mv BOSL2-master BOSL2
```

Oder über den OpenSCAD-Bibliotheksmanager: Menü → Datei → Bibliotheken öffnen…

## Druck-Einstellungen

| Einstellung | Wert |
|-------------|------|
| Material | PLA oder PETG |
| Schichthöhe | 0.2 mm |
| Wände | 3 (0.4 mm Düse → 1.2 mm) |
| Infill | 15–20 % |
| Support | Nicht benötigt |
| Betthaftung | Keine (flache Unterseite) |
| Orientierung | Platte auf Bett (Stifte zeigen nach oben) |

## Lizenz

Siehe `LICENSE` im Hauptverzeichnis.
