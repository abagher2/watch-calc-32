#!/bin/bash
set -e
echo "1. Applying layout fixes..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 fix_layout_v14.py

echo "2. Exporting DSN..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 export_dsn.py calculator.kicad_pcb calculator.dsn

echo "3. Running Freerouting (this will take 1-2 minutes)..."
export JAVA_HOME="/usr/local/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
java -jar freerouting.jar -de calculator.dsn -do calculator.ses -mp 40 -mt 1

echo "4. Importing SES into PCB..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 auto_router.py calculator.kicad_pcb calculator.ses || true

echo "5. Packaging Manufacturing files..."
cp calculator.kicad_pcb output/pcbs/calculator.kicad_pcb
./package_manufacturing.sh
cd output && zip -r WatchCalc32_Manufacturing.zip WatchCalc32_Manufacturing
cd ..

echo "6. Generating 3D Models via OpenSCAD (this will take 2-3 minutes)..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 generate_scad.py

echo "All Done!"
