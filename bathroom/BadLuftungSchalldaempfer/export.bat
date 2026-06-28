@echo off
echo ========================================
echo  Exportiere alle STL-Dateien...
echo ========================================
echo.

echo [1/4] Wandteil...
openscad -o BadLuftungSchalldaempfer_wandteil.stl --export-format binstl -D "export_part=\"wandteil\"" BadLuftungSchalldaempfer.scad
echo.

echo [2/4] Außenteil...
openscad -o BadLuftungSchalldaempfer_aussenteil.stl --export-format binstl -D "export_part=\"aussenteil\"" BadLuftungSchalldaempfer.scad
echo.

echo [3/4] Dämmung 1 (innen)...
openscad -o BadLuftungSchalldaempfer_daemmung_1.stl --export-format binstl -D "export_part=\"daemmung_1\"" BadLuftungSchalldaempfer.scad
echo.

echo [4/4] Dämmung 2 (mitte)...
openscad -o BadLuftungSchalldaempfer_daemmung_2.stl --export-format binstl -D "export_part=\"daemmung_2\"" BadLuftungSchalldaempfer.scad
echo.

echo ========================================
echo  Fertig! Alle 4 STL-Dateien exportiert.
echo ========================================
