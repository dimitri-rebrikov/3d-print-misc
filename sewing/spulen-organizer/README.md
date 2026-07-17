# Spulen-Organizer — Nähmaschinenspulen-Ständer

**Parametrischer Ständer für Nähmaschinenspulen (Class 15).**

Ein Tablett mit aufrechten Stiften, auf die Nähspulen aufgesteckt werden.
Alle Maße sind über OpenSCAD-Customizer anpassbar — für verschiedene
Spulengrößen, Rasterdimensionen und Designs.

## Eigenschaften

- **4 Werte steuern alles:** Spulendurchmesser, Stifthöhe, max. Breite, max. Tiefe
  — Raster (Reihen × Spalten) wird automatisch berechnet
- **BOSL2:** Saubere Verrundungen mit `cuboid(rounding=)`, `grid_copies()`, `cyl(rounding=)`
- **Druckfreundlich:** Flache Unterseite (scharfe Kanten für Betthaftung),
  abgerundete Ecken oben, optionaler Fingerausschnitt
- **Stift-Sockel:** Kleines Plateau unter jedem Stift hebt die
  Spule von der Platte ab — vermeidet Kratzer

## Parameter (Customizer)

| Parameter | Default | Beschreibung |
|-----------|---------|-------------|
| `spulen_durchmesser` | 21 mm | Außendurchmesser Spule → bestimmt Stiftabstand |
| `stift_hoehe` | 50 mm | Höhe der Stifte |
| `max_breite` | 140 mm | Gewünschte max. Plattenbreite → Spaltenzahl |
| `max_tiefe` | 290 mm | Gewünschte max. Plattentiefe → Reihenzahl |
| `spulen_loch_durchmesser` | 6.5 mm | Innendurchmesser Spulenkern |
| `platten_dicke` | 4 mm | Dicke der Bodenplatte |
| `eckradius` | 5 mm | Radius der Eckverrundung |
| `stift_rundung_unten` | 1 mm | Radius Stiftfuß (Übergang) |
| `stift_rundung_oben` | 2 mm | Radius Stiftspitze |
| `fingerausschnitt` | true | Fingerausschnitt an Vorderkante |
| `$fn` | 32 | Auflösung

## Dateien

| Datei | Beschreibung |
|-------|-------------|
| `spulen-organizer.scad` | Hauptmodell (alle Parameter + Module) |
| `render.scad` | Render-Skript (`openscad -o spulen-organizer.stl render.scad`) |
| `spulen-organizer.stl` | Exportiertes STL (5×10 = 50 Stifte, 135×270 mm) |
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
