#!/bin/bash
set -e

mkdir -p output/gerbers
rm -rf output/gerbers/*

echo "Generating Gerbers..."
/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli pcb export gerbers -o output/gerbers/ output/pcbs/calculator.kicad_pcb
/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli pcb export drill -o output/gerbers/ output/pcbs/calculator.kicad_pcb

cd output/gerbers
zip -r ../WatchCalc32_Gerbers.zip *
cd ../..

