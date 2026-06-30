# BadLuftungSchalldaempfer — Schalldämpfer für Badezimmer-Lüftung

## Zweck

Der Schalldämpfer wird als große Kappe über das Lüftungsrohr in der Wand aufgesetzt. Der Lüfter selbst befindet sich im Rohr (Durchmesser 100 mm) und leitet die Geräusche durch das Rohr in das Badezimmer. Dieser Schalldämpfer reduziert diese Geräusche, indem er ein zirkuläres Labyrinth bildet, das den Schallweg verlängert und dämpft.

## Aufbau

Der Schalldämpfer besteht aus **zwei Hauptteilen** und **zwei Dämmschichten**:

### 1. Wandteil (wandteil)
- **Bodenplatte** (hintere Wand): Scheibe mit Loch (Durchmesser 130 mm) für das Rohr, abgerundete Außenkante zur Wand hin
- **Zylinder 1 (Z1)**: Innerster Ring um das Rohr (Innendurchmesser = Lochdurchmesser 130 mm)
- **Zylinder 3 (Z3)**: Äußerer Ring (Außendurchmesser max. 200 mm)
- **3 Podeste**: Kleine zylindrische Erhebungen (Durchmesser 6 mm, Höhe 2 mm) auf der Bodenplatte für die Gegenmagnete

### 2. Außenteil (aussenteil)
- **Vorderwand**: Scheibe mit abgerundeter Außenkante, bündig mit Z2
- **Zylinder 2 (Z2)**: Mittlerer Ring, der zwischen Z1 und Z3 passt
- **3 Magnetsäulen**: Zylindrische Säulen (Durchmesser 6 mm) auf der Unterseite der Vorderwand, die zu den Podesten ragen

### 3. Dämmung 1 (daemmung_1)
- Ring aus TPU oder anderem dämmenden Material (Dicke 6 mm)
- Liegt auf der **Innenseite** der Vorderwand (Außenteil), innerhalb von Z2
- Die Magnetsäulen ragen **durch** die Dämmung hindurch (Säulen sind länger als die Dämmung dick ist)
- Mit **Aussparungen** für die 3 Magnetsäulen (Durchmesser + 0,5 mm Spiel)
- Durchmesser: Z2-Innendurchmesser - 0,2 mm Spiel

### 4. Dämmung 2 (daemmung_2)
- Ring aus TPU oder anderem dämmenden Material (Dicke 6 mm)
- Liegt auf der Bodenplatte (Wandteil), zwischen Z1 und Z3
- Mit Aussparungen für die Podeste
- Durchmesser: Z3-Innendurchmesser - 0,2 mm Spiel

## Funktionsprinzip

### Labyrinth-Struktur

Beim Zusammensetzen fahren die Zylinderwände ineinander:

```
Wandteil:          Außenteil:
  Z1 (innen) ────  Z2 (mitte) ────  Z3 (außen)
       ↑                 ↑                 ↑
    axialer           axialer           axialer
    Spalt 1           Spalt 2           Spalt 3
```

Die Luft strömt durch das Rohr (100 mm) in den Schalldämpfer und wird durch folgende Spalte geführt:

1. **Radialer Spalt Z1→Z2**: Seitlicher Spalt zwischen Z1 (außen) und Z2 (innen)
2. **Axialer Spalt 1**: Vertikaler Spalt zwischen Z1-Oberkante und Vorderwand (Außenteil)
3. **Radialer Spalt Z2→Z3**: Seitlicher Spalt zwischen Z2 (außen) und Z3 (innen)
4. **Axialer Spalt 2**: Vertikaler Spalt zwischen Z2-Unterkante und Bodenplatte (Wandteil)

## Berechnungshierarchie

Die Berechnung erfolgt in einer klaren Hierarchie:

### Schritt 1: Strömungsspalte (basierend auf A_rohr)

Alle Spalte sind so dimensioniert, dass die **Strömungsfläche** (Querschnittsfläche für die Luft) überall gleich groß ist wie die des 100-mm-Rohrs:

$$A_{Rohr} = \pi \cdot (50\text{ mm})^2 = 7854\text{ mm}^2$$

**Radiale Spalte** (seitlich zwischen den Zylindern):
$$s_{12} = \frac{A_{Rohr}}{2\pi \cdot r_{Z1,außen}} \quad\text{und}\quad s_{23} = \frac{A_{Rohr}}{2\pi \cdot r_{Z2,außen}}$$

**Axiale Spalte** (vertikal zwischen Zylinderkanten und gegenüberliegenden Wänden):
$$a_1 = \frac{A_{Rohr}}{2\pi \cdot r_{Z1,außen}} + d_{Dämmung} \quad\text{und}\quad a_2 = \frac{A_{Rohr}}{2\pi \cdot r_{Z2,außen}} + d_{Dämmung}$$

Die Dämmungsdicke wird addiert, da die Dämmung im Spalt liegt und den verfügbaren Luftquerschnitt verkleinert.

### Schritt 2: Labyrinth-Überlappung

Die Labyrinth-Überlappung ist der zentrale Parameter, der die Zylinderhöhen bestimmt:

$$Überlappung = Z1_{Höhe} + Z2_{Höhe} - Zylinder_{Tiefe}$$

Mit $Z2_{Höhe} = Zylinder_{Tiefe} - a_2$ ergibt sich:

$$Überlappung = Z1_{Höhe} - a_2$$

Daraus folgt:

$$Z1_{Höhe} = Überlappung + a_2$$

Die Überlappung beträgt **20 mm** — das sorgt für ausreichend Labyrinth-Wirkung, ohne dass die Zylinder zu lang werden.

### Schritt 3: Alle anderen Werte

Aus den Strömungsspalten und der Labyrinth-Überlappung werden alle weiteren Maße abgeleitet:

- **Zylinder-Tiefe** (Abstand Bodenplatte → Vorderwand): $Z1_{Höhe} + a_1$
- **Z2-Höhe**: $Zylinder_{Tiefe} - a_2$
- **Z3-Höhe**: $Zylinder_{Tiefe} + Boden_{Dicke}$ (reicht bis Vorderwand-Oberseite)
- **Säulenhöhe**: $Z2_{Höhe} + a_2 - Boden_{Dicke} + Dämmung_{Dicke}$ (von Vorderwand-Innenseite durch die Dämmung bis zu den Podesten + 1 mm Überstand)

### Beispielwerte (mit aktuellen Parametern)

| Größe | Wert | Formel |
|-------|------|--------|
| A_rohr | 7854 mm² | π · 50² |
| Z1_aussen | 68 mm | 65 + 3 |
| spalt_12 | 18,4 mm | 7854 / (2π · 68) |
| Z2_aussen | 89,4 mm | 68 + 18,4 + 3 |
| spalt_23 | 14,0 mm | 7854 / (2π · 89,4) |
| Z3_aussen | 106,4 mm | 89,4 + 14,0 + 3 |
| axial_spalt_1 | 24,4 mm | 7854 / (2π · 68) + 6 |
| axial_spalt_2 | 20,0 mm | 7854 / (2π · 89,4) + 6 |
| Z1_Höhe | 40,0 mm | 20 + 20,0 |
| Zylinder_Tiefe | 64,4 mm | 40,0 + 24,4 |
| Z2_Höhe | 44,4 mm | 64,4 - 20,0 |
| Z3_Höhe | 67,4 mm | 64,4 + 3 |
| Säulenhöhe | 67,4 mm | 44,4 + 20,0 - 3 + 6 (Z2_Höhe + a_2 - Boden + Dämmung) |

### Befestigung

- **3 Neodym-Magnete** (Durchmesser 6 mm, Dicke 2 mm) halten das Außenteil am Wandteil
- Jeweils ein Magnet wird auf die Unterseite jeder Säule und auf die Oberseite jedes Podestes geklebt
- Die Säulen ragen 1 mm über die Podeste hinaus, sodass die Magnete sicher Kontakt haben
- 3 Magnete im 120°-Winkel = 3-Punkt-Auflage = kein Wackeln

## Parameter

| Parameter | Wert | Beschreibung |
|-----------|------|-------------|
| `rohr_durchmesser` | 100 mm | Lüftungsrohr-Innendurchmesser |
| `loch_durchmesser` | 130 mm | Wandloch-Durchmesser |
| `max_durchmesser` | 200 mm | Maximaler Außendurchmesser (Druckbett) |
| `wand_dicke` | 3,0 mm | Zylinder-Wandstärke |
| `boden_dicke` | 3,0 mm | Vordere/hintere Wandstärke |
| `labyrinth_ueberlappung` | 20,0 mm | Überlappung der Zylinder im Labyrinth |
| `daemmung_dicke` | 6,0 mm | TPU-Dämmring-Dicke |
| `magnet_durchmesser` | 6,0 mm | Neodym-Magnet Durchmesser |
| `magnet_dicke` | 2,0 mm | Neodym-Magnet Dicke |

## 3D-Druck-Anleitung

### Benötigte Dateien

| Datei | Beschreibung |
|-------|-------------|
| `BadLuftungSchalldaempfer_wandteil.stl` | Wandteil (Bodenplatte + Z1 + Z3 + Podeste) |
| `BadLuftungSchalldaempfer_aussenteil.stl` | Außenteil (Vorderwand + Z2 + Säulen) |
| `BadLuftungSchalldaempfer_daemmung_1.stl` | Dämmung 1 (innen, auf Vorderwand) |
| `BadLuftungSchalldaempfer_daemmung_2.stl` | Dämmung 2 (mitte, auf Bodenplatte) |

### Druck-Einstellungen

**Wandteil und Außenteil (PLA/PETG):**
- Material: PLA oder PETG
- Schichthöhe: 0,2 mm
- Wandstärke: 3 Wände (0,4 mm Düse → 1,2 mm)
- Infill: 15-20 %
- Support: **Nicht benötigt** (alle Überhänge < 45°)
- Betthaftung: Brim empfohlen (große Grundfläche)

**Dämmringe (TPU):**
- Material: TPU (flexibel)
- Schichthöhe: 0,2 mm
- Wandstärke: 2 Wände
- Infill: 100 % (für beste Dämmwirkung)
- Support: Nicht benötigt
- Hinweis: Langsam drucken (20-30 mm/s)

### Montage

1. **Wandteil montieren**: Wandteil mit der Bodenplatte zur Wand auf das Rohr stecken (Rohr durch das 130-mm-Loch)
2. **Dämmung 2 einlegen**: Dämmring 2 auf die Bodenplatte legen (zwischen Z1 und Z3, über die Podeste gestülpt)
3. **Magnete auf Podeste kleben**: 3 Magnete auf die Podeste kleben
4. **Magnete in Säulen kleben**: 3 Magnete auf die Unterseite der Säulen kleben (Außenteil)
5. **Dämmung 1 einlegen**: Dämmring 1 in das Außenteil legen (auf die Vorderwand, innerhalb von Z2)
6. **Außenteil aufsetzen**: Außenteil auf das Wandteil setzen — die Magnete rasten ein und halten alles zusammen

## Dateien

| Datei | Beschreibung |
|-------|-------------|
| `BadLuftungSchalldaempfer.scad` | Haupt-SCAD-Datei mit allen Modulen |
| `render.scad` | Render-Datei für Vorschau/Export |
| `export.bat` | Batch-Skript zum Export aller STLs |
| `README.md` | Diese Datei |

## Abhängigkeiten

- [BOSL2](https://github.com/BelfrySCAD/BOSL2) — Bell's OpenSCAD Library v2 (für `round_corners()`)

## Lizenz

Siehe `LICENSE` im Hauptverzeichnis.
