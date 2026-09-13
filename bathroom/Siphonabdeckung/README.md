# Siphonabdeckung

Halbrunde Abdeckung (Blende) für den Siphon an der Wand — rekonstruiert aus den
beiden Skizzen in diesem Verzeichnis.

| Skizze | Datei |
| --- | --- |
| Ansicht von oben + von vorne | `photo_2026-09-13_16-31-57.jpg` |
| Ansicht von hinten | `photo_2026-09-13_16-32-01.jpg` |

## Maße (aus den Skizzen)

| Größe | Wert | Herkunft |
| --- | --- | --- |
| Außenbreite | 95 mm | Skizze (Ansicht von oben/vorne) |
| Lichte Weite innen | 70 mm | Skizze (Ansicht von oben) |
| Radius Front außen / innen | 47,5 / 35 mm | Skizze (Ansicht von oben) |
| Wandstärke | 12,5 mm | = (95 − 70) / 2 |
| Länge der geraden Seitenwände | 65 mm | Skizze (Ansicht von oben) |
| Gesamttiefe ab Wand | 112,5 mm | = 65 + 47,5 |
| Höhe | 65 mm | Ansicht von vorne (nicht 6,5 mm) |
| Kantenrundung | 5 mm | Skizze („5“) |

## Form

Grundriss = U mit halbrunder Front (Band aus 2 geraden Schenkeln + Halbrund),
das Band ist 65 mm hoch. Der Rücken (die 95 mm breite Seite) bleibt offen —
dort steht die Wand, die Abdeckung wird über den Siphon gestülpt. Oben und
unten ist der Kanal ebenfalls offen (durchgehendes Profil, wie in den Skizzen
gezeichnet).

Das Teil ist eine **gleichmäßig 12,5 mm dünne Schale**: der Grundriss ist ein
U-Band aus zwei Schenkeln und einem **konzentrischen** Halbrund (außen R 47,5,
innen R 35) — die Wandstärke ist überall 12,5 mm.

Damit der Innenbogen nicht versehentlich verkehrt herum wölbt (dann wäre die
Frontwand auf der Achse 82,5 mm dick, das sieht aus wie „ein Zylinder in der
Mitte“), rechnet die SCAD-Datei die Fläche des Grundrisses nach und vergleicht
sie mit dem Sollwert (Rechteck + Halbrund außen minus innen):

```
echte Fläche 3243,7 mm²  |  Sollwert 3244,9 mm²   (verdreht: 7089,4 mm² -> assert)
```

Nachweis-Bilder in `views/`:
* `Siphonabdeckung_schnitt_waagerecht.png` — Schnitt in halber Höhe: U-Band mit
  gleichmäßiger Wandstärke (Vergleich mit „Ansicht von oben“)
* `Siphonabdeckung_iso.png` — offene Halbrund-Schale
* `Siphonabdeckung_schnitt_senkrecht.png` — Schnitt auf der Achse (Wand 12,5 × 65)

```
Ansicht von oben          Ansicht von hinten        Schnitt auf der Achse
   ______                       ____________              ______
  /      \                     |  __    __  |            |      |
 |  ____  |                    | |  |  |  | |            |  ()  |
 | |    | |  70                | |  |  |  | |  70        |      |
 | |    | |                    | |__|  |__| |            |______|
 |_|    |_|                    |____________|            12,5 x 65
   95                              95
```

## Aufbau der Datei

`Siphonabdeckung.scad` enthält alles: Parameter, Grundriss, Modell und die
Prüfansichten. Fillets mit BOSL2:

* `offset_sweep()` mit `os_circle(r = radius_front)` — rundet **nur die obere
  Randkante** (die nach oben schauende Frontseite), außen und innen.

## Kanten (Vorgabe)

Die U liegt flach (Grundriss in X/Y, Z = Höhe):

| Kante | Behandlung |
| --- | --- |
| Frontseite (Z = 65, schaut nach oben) | alle Kanten gerundet (R 5) |
| Unterseite (Z = 0, liegt auf Boden/Druckbett) | scharf, flach |
| U-Spitzen (Stirnflächen der Schenkel) | auf ihren flachen Seiten scharf |

Die Schenkel behalten damit ihre volle Wandstärke von 12,5 mm, das Teil steht
plan auf der Unterseite und ist ohne Stützstruktur druckbar.

## Rendern

```bash
# Modell
openscad -o siphon.png --render --autocenter --viewall \
  --camera=0,0,0,55,0,45,600 --projection=perspective Siphonabdeckung.scad

# Prüfansichten (Vergleich mit den Skizzen)
openscad -o schnitt_grundriss.png --render --autocenter --viewall \
  --camera=0,0,0,0,0,0,600 --projection=ortho \
  -D 'PRUEFUNG="schnitt_grundriss"' Siphonabdeckung.scad   # waagerechter Schnitt -> "von oben"
openscad -o schnitt_laengs.png --render --autocenter --viewall \
  --camera=0,0,0,55,0,45,600 --projection=perspective \
  -D 'PRUEFUNG="schnitt_laengs"' Siphonabdeckung.scad      # Schnitt auf der Achse
```

Kontrolle der Proportionen am gerenderten Bild (orthografisch):
Ansicht von oben 95 : 112,5, von hinten/vorne 95 : 65 — geprüft, passt.

Fertige Bilder liegen in `views/`:

| Datei | Inhalt |
| --- | --- |
| `Siphonabdeckung_iso.png` | 3/4-Ansicht |
| `Siphonabdeckung_oben.png` | Draufsicht |
| `Siphonabdeckung_schnitt_waagerecht.png` | Schnitt in halber Höhe (U-Band) |
| `Siphonabdeckung_schnitt_senkrecht.png` | Schnitt auf der Symmetrieachse |

## Annahmen / noch zu bestätigen

* Kanal ist oben und unten offen (durchgehendes Profil, wie in den Skizzen).
* Wandstärke 12,5 mm (aus 95/70) — bestätigt.
* Rundungsradius der Frontseite 5 mm (Skizze: „5“).
* Keine Bohrungen/Halter (in den Skizzen nicht vorhanden).
