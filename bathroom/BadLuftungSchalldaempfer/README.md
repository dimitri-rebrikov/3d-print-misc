# BadLuftungSchalldaempfer — Schalldämpfer für Badezimmer-Lüftung

**Schalldämpfer-Kappe für das Badezimmer-Lüftungsrohr**

Der Ventilator im 100mm-Lüftungsrohr überträgt Betriebsgeräusche und Strömungsgeräusche durch das Rohr in den Raum. Dieser Schalldämpfer wird als Kappe über das Wandloch gesetzt und dämpft die Geräusche durch ein **zirkuläres Labyrinth**, das die Luft auf ihrem Weg vom Bad ins Rohr mehrfach umlenkt, bevor sie abgesaugt wird.

---

## 📋 Inhaltsverzeichnis

1. [Funktionsprinzip](#funktionsprinzip)
2. [Technische Daten](#technische-daten)
3. [Aufbau & Design](#aufbau--design)
4. [Montage](#montage)
5. [3D-Druck Anleitung](#3d-druck-anleitung)
6. [SCAD-Parameter](#scad-parameter)
7. [Materialliste](#materialliste)
8. [Wartung](#wartung)

---

## Funktionsprinzip

### Luftstrom

```
Bad → [radialer Eintrittsspalt] → über Zylinder 4 → Spalt 4-3
→ über Zylinder 3 → Spalt 3-2 → über Zylinder 2 → Spalt 2-1
→ über Zylinder 1 → Innenraum → 100mm Rohr → Außen
```

Die Luft wird **radial** zwischen Wandteil und Außenteil eingesaugt, durchläuft dann das Labyrinth aus 4 konzentrischen/versetzten Zylinderwänden und wird schließlich durch das 100mm-Rohr abgesaugt.

### Schalldämpfung

- **Mehrfache Umlenkung:** Die Luft wird 4× um 180° umgelenkt → Schallwellen werden reflektiert und absorbiert
- **Gedruckte TPU-Dämmringe:** 3 Dämmringe (5-10mm dick) aus flexiblem TPU-Filament werden in die Zwischenräume eingelegt — passgenau aus dem SCAD-Modell generiert
- **Versetzte Mittelpunkte:** Wand- und Außenteil haben unterschiedliche Mittelpunkte → variierende Spaltbreiten → verbesserte Dämpfung durch asymmetrische Resonanz


---

## Technische Daten

| Eigenschaft | Wert |
|-------------|------|
| **Rohr-Durchmesser** | 100 mm |
| **Wandloch-Durchmesser** | 130 mm |
| **Lochmittelpunkt → Ecke** | 105 mm |
| **Abstand zur Eckwand** | ~10 mm (min.) |
| **Außendurchmesser (Wandteil)** | ~212 mm |
| **Außendurchmesser (Außenteil)** | ~190 mm (versetzt) |
| **Bautiefe (gesamt)** | ~36 mm (berechnet) |
| **Labyrinth-Tiefe** | ~30 mm (berechnet) |
| **Wandstärke** | 3 mm |

| **Gewicht (ca.)** | ~80-120g pro Teil (PLA) |
| **Befestigung Wandteil** | Tesa-Streifen (oder Schrauben) |
| **Befestigung Außenteil** | 3× Neodym-Magnete (6×2 mm) |

### Zylinder-Geometrie (von innen nach außen)

Die Radien und Höhen aller Zylinder werden automatisch aus den Parametern berechnet:

**Radiale Spalte (zwischen den Zylindern) — Strömungsprinzip:**

Die Luft muss zwischen den Zylindern hindurchströmen. Damit sie **nicht schneller** wird als im Rohr (sonst gibt's Strömungsgeräusche), muss die seitliche Durchtrittsfläche an jedem Zylinder mindestens so groß sein wie die Rohr-Querschnittsfläche.

Die Rohrfläche ist:
```
A_rohr = π × (rohr_durchmesser/2)² = π × 50² = 7.854 mm²
```
m 
Die seitliche Fläche an Zylinder i ist: `Umfang × Spalt = 2π × r_i × spalt_i`

Daraus folgt die **optimale** Spaltbreite:
```
spalt_i = A_rohr / (2π × r_i)
```

**Problem — zu wenig Platz:** Die optimalen Spalte sind zusammen breiter als der verfügbare Platz zwischen Rohrloch-Rand und Eckwand. Z.B.:
- Z1 (r=53mm): optimaler Spalt = 7.854 / (2π × 53) ≈ 23.6 mm
- Z2 (r≈80mm): optimaler Spalt ≈ 15.7 mm
- Z3 (r≈98mm): optimaler Spalt ≈ 12.7 mm
- Z4_außen ≈ 114 mm, aber max_radius_ecke = 95 mm

**Lösung — Proportionaler Versatz (keine Skalierung!):** Die Spaltbreiten bleiben optimal. Stattdessen bekommt **jeder Zylinder einen eigenen Versatz** in X-Richtung (von der Ecke weg), proportional zu seinem Außenradius. Z1 bleibt fix (Versatz = 0), Z4 bekommt den maximalen Versatz, Z2 und Z3 proportionale Anteile:

```
versatz_4 = zylinder_4_aussen - max_radius_ecke
versatz_i = versatz_4 × (r_i_aussen - r_1_aussen) / (r_4_aussen - r_1_aussen)
```

Bei den aktuellen Parametern:
- `versatz_2 = 19 × (79.6 - 53) / (114 - 53) = 8.3 mm`
- `versatz_3 = 19 × (98.3 - 53) / (114 - 53) = 14.1 mm`
- `versatz_4 = 19 mm`

Auf der Eckseite gilt: `loch_mitte_x + versatz_4 - wand_abstand_ecke = 105 + 19 - 10 = 114 = zylinder_4_aussen` ✅

**Vorteil:** Die Spalte bleiben optimal groß → die Luft strömt nicht schneller → keine Strömungsgeräusche. Der proportionale Versatz erzeugt ein **konisches Labyrinth** mit variablen Spaltbreiten, das stehende Wellen verhindert und die Dämpfung über ein breiteres Frequenzspektrum verbessert.






**Höhen:** Jeder Zylinder hat seinen eigenen axialen Spalt zur gegenüberliegenden Wand:
```
axial_spalt_i = A_rohr / (2π × r_i_aussen) + daemmung_dicke
zylinder_i_hoehe = zylinder_tiefe - axial_spalt_i
```

Die Bautiefe `zylinder_tiefe` wird aus der Mindesthöhe der niedrigsten Wand abgeleitet:
```
zylinder_tiefe = zylinder_mindest_hoehe + axial_spalt_1
```
(Z1 hat den größten axialen Spalt → ist die niedrigste Wand → bekommt genau `zylinder_mindest_hoehe`)

| Zylinder | Teil | Innenradius | Außenradius | Höhe (ca.) | Axialer Spalt zu |
|----------|------|-------------|-------------|------------|------------------|
| **1** | Wandteil | rohr_radius | +wand_dicke | zylinder_mindest_hoehe | Vorderwand |
| **2** | Außenteil | Z1_außen + spalt_12 | +wand_dicke | berechnet | Bodenplatte |
| **3** | Wandteil | Z2_außen + spalt_23 | +wand_dicke | berechnet | Vorderwand |
| **4** | Außenteil | Z3_außen + spalt_34 | +wand_dicke | berechnet | Bodenplatte |



**Dämmringe (separat aus TPU drucken):**

| Dämmung | Von | Bis | Form | Beschreibung |
|---------|-----|-----|------|-------------|
| **1** | Z1_außen (53mm) | Z2_innen (66.5mm) | **Volle Scheibe** | Innenhof von Wand 2 |
| **2** | Z1_außen (53mm) | Z3_innen (77.2mm) | Ring mit Loch | Zwischen Wand 1 und Wand 3 |
| **3** | Z2_außen (69.5mm) | Z4_innen (91.2mm) | Ring mit Löchern | Zwischen Wand 2 und Wand 4, mit Aussparungen für Magnete |

> **Hinweis:** Die Dämmringe (6mm TPU) liegen auf den Flächen (Bodenplatte/Vorderwand) und füllen die Zwischenräume zwischen den Zylindern. Der Luftspalt zwischen den Zylindern bleibt frei für die Strömung.




---

## Aufbau & Design

### Die zwei Teile

#### 1. Wandteil (Wall Part) — an der Wand

```
┌─────────────────────────────────┐
│  ╭───────────────────────────╮  │
│  │  ╭─────────────────────╮  │  │
│  │  │    ╭───────╮        │  │  │
│  │  │    │ ○  ○  │        │  │  │
│  │  │    │  ○○   │        │  │  │
│  │  │    ╰───────╯        │  │  │
│  │  ╰─────────────────────╯  │  │
│  ╰───────────────────────────╯  │
└─────────────────────────────────┘
```

- **Hintere Wand** (3mm): Runde Scheibe mit 100mm-Loch für das Rohr
- **Zylinder 1** (innen): Direkt um das Rohrloch, 30mm hoch
- **Zylinder 3** (außen): Äußerer Ring des Wandteils, 30mm hoch
- **Rückseite:** Glatte Fläche für Tesa-Streifen

#### 2. Außenteil (Outer Part) — sichtbar im Raum

```
┌─────────────────────────────────┐
│  ╭───────────────────────────╮  │
│  │  ╭─────────────────────╮  │  │
│  │  │                     │  │  │
│  │  │   (geschlossene     │  │  │
│  │  │    Frontfläche)     │  │  │
│  │  │                     │  │  │
│  │  ╰─────────────────────╯  │  │
│  ╰───────────────────────────╯  │
└─────────────────────────────────┘
```

- **Vordere Wand** (3mm): Geschlossene runde Scheibe (Luft tritt radial ein)
- **Zylinder 2** (innen): Passt zwischen Zylinder 1 und 3, 30mm hoch
- **Zylinder 4** (außen): Umschließt Zylinder 3, 30mm hoch

### Räumliche Anordnung (wichtig für Montage!)

Der Schalldämpfer besteht aus zwei Teilen, die **ineinander greifen**:

```
                    ┌──────────────────┐
                    │  Vorderwand      │  ← Außenteil (im Raum sichtbar)
                    │  (Außenteil)     │
       ┌──────┐     │  ┌────┐  ┌────┐ │     ┌──────┐
       │      ├─────┤  │ W2 │  │ W4 │ ├─────┤      │
       │  W1  │     │  │    │  │    │ │     │  W3  │
       │      │     │  └────┘  └────┘ │     │      │
──[Rohr]─►    │     └──────────────────┘     │      │
       │      │                              │      │
       └──┬───┘                              └──┬───┘
          │    ┌──────────────────────────┐     │
          │    │  Bodenplatte (Wandteil)  │     │
          │    └──────────────────────────┘     │
          └──────────────────┬──────────────────┘
                             │
                      ← Luft Eintritt →
```

**Wandteil** (an der Wand montiert):
- **Bodenplatte** — runde Scheibe, deckungsgleich mit der Vorderwand des Außenteils (gleicher Mittelpunkt bei `versatz_4`, gleicher Außenradius). Das 100mm-Rohrloch liegt separat bei (0,0) und wird ausgeschnitten.
- **Wand 1** (Z1) — innerster Zylinder, direkt um das Rohrloch bei (0,0)
- **Wand 3** (Z3) — äußerer Zylinder des Wandteils, mit Magnetsäulen


**Außenteil** (im Raum sichtbar, magnetisch gehalten):
- **Vorderwand** — geschlossene runde Scheibe (Luft tritt radial ein)
- **Wand 2** (Z2) — innerer Zylinder, passt zwischen Z1 und Z3
- **Wand 4** (Z4) — äußerer Zylinder, umschließt Z3

**Luftstrom-Pfad (von außen nach innen):**

```
Bad → [radial zwischen Vorderwand und Bodenplatte]
     → über Z4 hinweg → durch Spalt 4-3 (zwischen Z3 und Z4)
     → über Z3 hinweg → durch Spalt 3-2 (zwischen Z2 und Z3)
     → über Z2 hinweg → durch Spalt 2-1 (zwischen Z1 und Z2)
     → über Z1 hinweg → durch Rohrloch (100mm) → Außen
```

Die Luft wird **4× um 180° umgelenkt** — jede Umlenkung reflektiert und absorbiert Schallwellen.

### Dämmungen — wo liegen sie?

Die Dämmringe werden **separat aus TPU gedruckt** (ohne Wände/Top/Bottom Layers)
und auf der Seite angebracht, wo die jeweilige Wand angeschlossen ist:

```
                    ┌──────────────────┐
                    │  Vorderwand      │
                    │  ┌────┐  ┌────┐ │
       ┌──────┐     │  │ W2 │  │ W4 │ │     ┌──────┐
       │      ├─────┤  │ ██│  │ ██│ │ ├─────┤      │
       │  W1  │     │  │ ██│  │ ██│ │ │     │  W3  │
       │      │     │  └─██┘  └─██┘ │ │     │      │
──[Rohr]─►    │     └──────────────────┘     │      │
       │      │         ░░░░░░░              │      │
       └──┬───┘         ░░░░░░░              └──┬───┘
          │    ┌──────────────────────────┐     │
          │    │  Bodenplatte             │     │
          │    └──────────────────────────┘     │
          └──────────────────┬──────────────────┘
                             │
```

| Dämmung | Liegt auf | Bereich | Form |
|---------|-----------|---------|------|
| **1** ██ | **Vorderwand** (Außenteil) | Z1_außen (53mm) bis Z2_innen (66.5mm) | Volle Scheibe — Z1 ist nicht hier |
| **2** ░░ | **Bodenplatte** (Wandteil) | Z1_außen (53mm) bis Z3_innen (80.2mm) | Ring mit Loch für Z1 |
| **3** ██ | **Vorderwand** (Außenteil) | Z2_außen (69.5mm) bis Z4_innen (92.0mm) | Ring mit Löchern für Magnete |


> **Wichtig:** Dämmung 1 und 3 werden auf der **Vorderwand des Außenteils** angebracht (die Seite mit den Zylindern 2 und 4). Dämmung 2 wird auf der **Bodenplatte des Wandteils** angebracht (zwischen Zylinder 1 und 3).


### Versatz-Prinzip (proportional)

Jeder Zylinder (außer Z1) bekommt einen eigenen Versatz in X-Richtung (von der Ecke weg), **proportional zu seinem Außenradius**. Dadurch:

- **Auf der Eckseite:** Z4_außen passt in den verfügbaren Platz (≤ max_radius_ecke)
- **Auf der Raumseite:** Die Zylinder haben mehr Platz → größerer Abstand zur Wand
- **Konisches Labyrinth:** Variable Spaltbreiten durch proportionale Verschiebung → verbesserte Dämpfung über ein breiteres Frequenzspektrum

**Automatische Berechnung:** Die radialen Spaltbreiten werden nach dem Strömungsprinzip berechnet (optimal, nicht skaliert). Da Z4_außen dadurch größer ist als `max_radius_ecke`, bekommt jeder Zylinder einen proportionalen Versatz:

```
versatz_4 = zylinder_4_aussen - max_radius_ecke
versatz_i = versatz_4 × (r_i_aussen - r_1_aussen) / (r_4_aussen - r_1_aussen)
```

Bei den aktuellen Parametern:
- `versatz_2 = 8.3 mm` (Z2, Außenteil)
- `versatz_3 = 14.1 mm` (Z3, Wandteil)
- `versatz_4 = 19.0 mm` (Z4, Außenteil)






---

## Montage

### Benötigte Materialien

| Teil | Menge | Spezifikation |
|------|-------|---------------|
| Gedrucktes Wandteil | 1 | PLA/PETG, 3mm Wandstärke |
| Gedrucktes Außenteil | 1 | PLA/PETG, 3mm Wandstärke |
| Gedruckte Dämmung 1 (innen) | 1 | TPU, ohne Wände/Top/Bottom |
| Gedruckte Dämmung 2 (mitte) | 1 | TPU, ohne Wände/Top/Bottom |
| Gedruckte Dämmung 3 (außen) | 1 | TPU, ohne Wände/Top/Bottom |
| Neodym-Magnete | 6 | Ø6mm × 2mm, Scheiben |
| Sekundenkleber | 1 | Für Magnete |
| Tesa-Streifen (Powerstrips) | 2-4 | Für Wandmontage |


### Schritt-für-Schritt

#### 1. Magnete einkleben

**Wandteil (Zylinder 3):**
1. Die 3 Magnetsäulen auf der **Oberseite von Zylinder 3** (die Seite, die zum Außenteil zeigt) mit Sekundenkleber bestreichen
2. Magnete (Ø6×2mm) auf die Säulen setzen — **Polarität beachten:** Alle Magnete mit gleicher Polung (z.B. Norden zeigt nach oben)
3. Andrücken und trocknen lassen

**Außenteil (Vorderwand):**
1. Die 3 Mini-Säulen (2mm hoch) auf der **Rückseite der Vorderwand** dienen als Markierung für die Magnet-Positionen
2. Magnete (Ø6×2mm) auf die Mini-Säulen kleben
3. **Polarität umgekehrt** zum Wandteil (damit sie sich anziehen)
4. Mit Sekundenkleber fixieren

> **Tipp:** Am einfachsten: Magnete auf die Säulen des Wandteils kleben, dann Außenteil aufsetzen → die Magnete rasten durch die Anziehungskraft automatisch an den Mini-Säulen ein. Dann die Magnete auf dem Außenteil festkleben.


#### 2. TPU-Dämmringe einlegen

Die 3 Dämmringe werden passgenau aus dem SCAD-Modell generiert (separate STLs).
Sie werden auf die folgenden Flächen geklebt:

| Dämmung | Liegt auf | Bereich | Form |
|---------|-----------|---------|------|
| **1** | Vorderwand (Außenteil) | 53–66.5mm | Volle Scheibe |
| **2** | Bodenplatte (Wandteil) | 53–80.2mm | Ring mit Loch für Z1 |
| **3** | Vorderwand (Außenteil) | 69.5–92.0mm | Ring mit Löchern für Magnete |


**Einlegen:**
1. Dämmung 1 und 3 auf die **Rückseite der Vorderwand** (Außenteil) kleben — zwischen die Zylinder 2 und 4
2. Dämmung 2 auf die **Bodenplatte** (Wandteil) kleben — zwischen Zylinder 1 und 3
3. Sekundenkleber oder Sprühkleber dünn auftragen
4. Andrücken und trocknen lassen

> **Wichtig:** Die Dämmringe sind 6mm dick und passgenau aus TPU gedruckt. Sie müssen nicht zugeschnitten werden — einfach aus dem Druckbett lösen und einkleben.



#### 3. Wandteil montieren

1. Wandloch reinigen (Staub, alter Schmutz)
2. Tesa-Streifen auf der **Rückseite** des Wandteils anbringen (auf der glatten Fläche)
3. Wandteil zentriert über das 100mm-Loch positionieren und andrücken
4. Optional: Zusätzlich mit Schrauben durch die dafür vorgesehenen Stellen sichern

#### 4. Außenteil aufsetzen

1. Außenteil mit den Zylindern voraus vor das Wandteil halten
2. Die Magnete ziehen das Teil automatisch in die korrekte Position
3. Leicht andrücken bis die Magnete einrasten

> **Wichtig:** Das Außenteil muss so ausgerichtet sein, dass der Versatz (die "dickere" Seite) von der Ecke weg zeigt.

---

## 3D-Druck Anleitung

### Druck-Einstellungen

| Parameter | Empfehlung |
|-----------|------------|
| **Filament** | PLA, PETG oder ABS |
| **Schichthöhe** | 0.2 mm |
| **Düse** | 0.4 mm |
| **Wandlinien** | 3 (für 0.4mm Düse = 1.2mm, aber wir brauchen 3mm → 7-8 Linien) |
| **Perimeter** | 7-8 (für 3mm Wandstärke bei 0.4mm Düse) |
| **Infill** | 15-20% (Gyroid oder Honeycomb) |
| **Top/Bottom Layers** | 4-5 |
| **Support** | **Nicht benötigt** (beide Teile drucken flach auf dem Bett) |
| **Brim** | Empfohlen (5mm) für bessere Haftung |
| **Material** | ~80-120g pro Teil |

### Druck-Orientierung

#### Wandteil

```
        ╔═══════════════════╗
        ║   Zylinder 1,3    ║  ← nach oben
        ║   (untersch. hoch)║
        ║                   ║
        ╠═══════════════════╣
        ║  Hintere Wand     ║  ← auf dem Druckbett
        ║  (flach, 3mm)     ║
        ╚═══════════════════╝
```

- **Druckbett:** Die flache Rückseite liegt auf dem Bett
- **Zylinder** zeigen nach oben → kein Support nötig
- Z1 ist die niedrigste Wand (zylinder_mindest_hoehe), Z3 ist höher

#### Außenteil

```
        ╔═══════════════════╗
        ║  Vordere Wand     ║  ← auf dem Druckbett
        ║  (flach, 3mm)     ║
        ╠═══════════════════╣
        ║   Zylinder 2,4    ║  ← nach oben
        ║   (untersch. hoch)║
        ╚═══════════════════╝
```

- **Druckbett:** Die flache Vorderseite liegt auf dem Bett
- **Zylinder** zeigen nach oben → kein Support nötig
- Z2 ist niedriger als Z4 (Z4 hat kleineren axialen Spalt)


### STL-Export

`export.bat` doppelklicken — exportiert alle 5 STLs auf einmal:

| # | Exportiert aus | STL-Datei |
|---|---------------|-----------|
| 1 | `export_wandteil.scad` | `BadLuftungSchalldaempfer_wandteil.stl` |
| 2 | `export_aussenteil.scad` | `BadLuftungSchalldaempfer_aussenteil.stl` |
| 3 | `export_daemmung_1.scad` | `BadLuftungSchalldaempfer_daemmung_1.stl` |
| 4 | `export_daemmung_2.scad` | `BadLuftungSchalldaempfer_daemmung_2.stl` |
| 5 | `export_daemmung_3.scad` | `BadLuftungSchalldaempfer_daemmung_3.stl` |



### Nachbearbeitung

1. **Stützstrukturen entfernen** (falls verwendet)
2. **Grat entfernen** - besonders an den Zylinder-Endkanten
3. **Passprobe:** Außenteil auf Wandteil stecken → sollte leichtgängig sein aber kein Spiel haben
4. **Optional:** Kanten mit Schleifpapier (400er) brechen für bessere Optik


---

## SCAD-Parameter

Alle relevanten Parameter können in `BadLuftungSchalldaempfer.scad` angepasst werden:

| Variable | Standard | Beschreibung |
|----------|----------|-------------|
| `rohr_durchmesser` | 100 | Lüftungsrohr-Innendurchmesser (mm) |
| `loch_durchmesser` | 130 | Wandloch-Durchmesser (mm) |
| `loch_mitte_x` | 105 | Lochmittelpunkt → Ecke (mm) |
| `wand_abstand_ecke` | 10 | Min. Abstand zur Eckwand (mm) |
| `wand_dicke` | 3.0 | Zylinder-Wandstärke (mm) |
| `boden_dicke` | 3.0 | Vordere/hintere Wandstärke (mm) |
| `zylinder_mindest_hoehe` | 30.0 | Mindesthöhe der niedrigsten Zylinderwand (Z1) (mm) |
| `daemmung_dicke` | 6.0 | TPU-Dämmring (mm) |

| `magnet_durchmesser` | 6.0 | Neodym-Magnet Durchmesser (mm) |
| `magnet_dicke` | 2.0 | Neodym-Magnet Dicke (mm) |
| `magnet_anzahl` | 3 | Anzahl Magnete (3-Punkt = kein Wackeln) |
| `radius_aussen` | 5.0 | Äußere Kanten-Abrundung (mm) |
| `radius_zylinder` | 2.0 | Zylinder-Endkanten Abrundung (mm) |


### Parameter anpassen

Wenn deine Einbausituation abweicht:

1. **Anderes Rohrmaß:** `rohr_durchmesser` anpassen
2. **Anderer Eckabstand:** `loch_mitte_x` und ggf. `wand_abstand_ecke` anpassen
3. **Dünnere/dickere Dämmung:** `daemmung_dicke` anpassen (die Spaltbreiten passen sich automatisch an)
4. **Versatz:** `versatz_2`, `versatz_3`, `versatz_4` werden automatisch proportional zu den Zylinder-Radien berechnet. Die Spaltbreiten bleiben dabei optimal (keine Skalierung). Jeder Zylinder wird proportional von der Ecke weg verschoben.






---

## Materialliste

| Material | Menge | Bezugsquelle | Preis (ca.) |
|----------|-------|-------------|-------------|
| PLA-Filament (1.75mm) | ~200g | Beliebig | ~5-8 € |
| TPU-Filament (1.75mm) | ~30g | Beliebig | ~2-3 € |
| Neodym-Magnete Ø6×2mm | 6 Stk. | Amazon, eBay | ~3-5 € |
| Tesa Powerstrips | 2-4 Stk. | Baumarkt | ~3-5 € |
| Sekundenkleber | 1 Tube | Beliebig | ~2-3 € |

**Gesamtkosten:** ca. 15-24 € (ohne Drucker)


---

## Wartung

### Regelmäßige Reinigung (alle 6-12 Monate)

1. Außenteil vorsichtig abziehen (Magnete lösen)
2. TPU-Dämmringe auf Verschmutzung prüfen
3. Staub von den Dämmringen mit Staubsauger (Bürstenaufsatz) entfernen
4. Innenraum des Wandteils und Rohröffnung reinigen
5. Außenteil wieder aufsetzen (rastet durch Magnete ein)

### Austausch der TPU-Dämmringe

Bei starker Verschmutzung oder nachlassender Dämpfungswirkung:

1. Alte Dämmringe abziehen
2. Klebereste entfernen (Isopropanol)
3. Neue Dämmringe aus TPU drucken (export_daemmung_1/2/3.scad)
4. Einkleben (siehe Montage-Schritt 2)
5. Außenteil wieder montieren


### Magnete prüfen

Falls die Haltekraft nachlässt:
- Korrosion prüfen (bei Beschädigung der Nickel-Beschichtung)
- Ggf. Magnete austauschen (aushebeln und neue einkleben)

---

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz veröffentlicht. Siehe `LICENSE` im Repository.

---

## Siehe auch

- [tablet-wall-holder](../tablet-wall-holder/README.md) — Vorheriges SCAD-Projekt mit ähnlichem Aufbau
