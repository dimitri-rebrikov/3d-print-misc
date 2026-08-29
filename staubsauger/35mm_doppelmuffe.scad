$fn = 120; // Hohe Auflösung

// Parameter
total_length = 60;
outer_dia    = 41;

entry_dia    = 35.4; // Öffnung außen
stop_dia     = 34.8; // Verjüngung am Steg
center_hole  = 32.0; // Innendurchmesser Mittelsteg
pocket_depth = 29;   // Einstecktiefe pro Seite
chamfer      = 1.5;  // Fase an den Enden

difference() {
    // 1. Grundkörper (Zylinder außen)
    cylinder(h = total_length, d = outer_dia, center = true);
    
    // 2. Konus Oben (Eingang 35.4 -> Steg 34.8)
    translate([0, 0, total_length/2 - pocket_depth])
        cylinder(h = pocket_depth + 0.1, d1 = stop_dia, d2 = entry_dia, center = false);
        
    // 3. Konus Unten (Eingang 35.4 -> Steg 34.8)
    translate([0, 0, -total_length/2 - 0.1])
        cylinder(h = pocket_depth + 0.1, d1 = entry_dia, d2 = stop_dia, center = false);
        
    // 4. Durchgangsloch in der Mitte (Mittelsteg)
    cylinder(h = total_length + 2, d = center_hole, center = true);
    
    // 5. Entgratung / Anfasung Oben
    translate([0, 0, total_length/2])
        rotate_extrude()
            translate([outer_dia/2, 0, 0])
                polygon(points=[[0.1, 0.1], [-chamfer, 0.1], [0.1, -chamfer]]);
                
    // 6. Entgratung / Anfasung Unten
    translate([0, 0, -total_length/2])
        rotate_extrude()
            translate([outer_dia/2, 0, 0])
                polygon(points=[[0.1, -0.1], [-chamfer, -0.1], [0.1, chamfer]]);
}