@echo off
echo ========================================
echo  Exportiere alle STL-Dateien...
echo ========================================
echo.

echo [1/5] Wandteil...
openscad -o BadLuftungSchalldaempfer_wandteil.stl --export-format binstl export_wandteil.scad
echo.

echo [2/5] Außenteil...
openscad -o BadLuftungSchalldaempfer_aussenteil.stl --export-format binstl export_aussenteil.scad
echo.

echo [3/5] Dämmung 1 (innen)...
openscad -o BadLuftungSchalldaempfer_daemmung_1.stl --export-format binstl export_daemmung_1.scad
echo.

echo [4/5] Dämmung 2 (mitte)...
openscad -o BadLuftungSchalldaempfer_daemmung_2.stl --export-format binstl export_daemmung_2.scad
echo.

echo [5/5] Dämmung 3 (außen)...
openscad -o BadLuftungSchalldaempfer_daemmung_3.stl --export-format binstl export_daemmung_3.scad
echo.

echo ========================================
echo  Fertig! Alle 5 STL-Dateien exportiert.
echo ========================================


