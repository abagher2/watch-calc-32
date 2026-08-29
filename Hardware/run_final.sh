#!/bin/bash
KICAD_PYTHON="/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3"

echo "Exporting DSN..."
$KICAD_PYTHON export_dsn.py "calculator.kicad_pcb" "board.dsn"
if [ $? -ne 0 ]; then exit 1; fi

echo "Running Freerouting..."
export JAVA_HOME="/usr/local/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
java -jar freerouting.jar -de board.dsn -do board.ses -mp 40 -mt 1
if [ $? -ne 0 ]; then exit 1; fi

echo "Importing SES..."
# We use || true because auto_router.py segfaults on exit after successfully saving
$KICAD_PYTHON auto_router.py "calculator.kicad_pcb" "board.ses" || true

echo "Updating STLs / Dummy PCB..."
$KICAD_PYTHON generate_scad.py
if [ $? -ne 0 ]; then exit 1; fi

echo "Packaging Manufacturing Files..."
bash package_manufacturing.sh
if [ $? -ne 0 ]; then exit 1; fi
