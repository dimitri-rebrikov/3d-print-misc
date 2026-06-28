// Render file for the BadLuftungSchalldaempfer
// Open this file and export STL to generate the full model
// or use the individual modules for separate parts.

include <BOSL2/std.scad>;
include <BadLuftungSchalldaempfer.scad>;

// ============================================================
// Wähle aus, was gerendert werden soll:
// ============================================================

// 1. Gesamtmodell (zusammengebaut)
// schalldaempfer();

// 2. Nur Wandteil (für separaten Druck)
// nur_wandteil();

// 3. Nur Außenteil (für separaten Druck)
// nur_aussenteil();

// 4. Querschnitt (für Visualisierung)
// querschnitt();

// ============================================================
// Standard: Beide Einzelteile nebeneinander
// ============================================================
// Wandteil bei (0,0,0)
nur_wandteil();

// Außenteil daneben (verschoben in X-Richtung)
translate([aussenkante_wandteil * 2 + 20, 0, 0])
    nur_aussenteil();
