#!/bin/bash
set -e

echo "2. Exporting DSN..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 export_dsn.py calculator.kicad_pcb calculator.dsn

echo "3. Running Freerouting (this will take 1-2 minutes)..."
export JAVA_HOME="/usr/local/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
java -jar freerouting.jar -de calculator.dsn -do calculator.ses -mp 40 -mt 1

echo "4. Importing SES into PCB..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 auto_router.py calculator.kicad_pcb calculator.ses
