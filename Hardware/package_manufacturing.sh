#!/bin/bash
set -e

echo "Cleaning up old directories..."
rm -rf output/WatchCalc32_Manufacturing
rm -rf output/gerbers
rm -f output/WatchCalc32_Gerbers.zip

# Create the single canonical directory
export OUTDIR="output/WatchCalc32_Manufacturing"
mkdir -p "$OUTDIR"

echo "Generating Gerbers and Drill Files..."
mkdir -p output/gerbers
/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli pcb export gerbers -o output/gerbers/ output/pcbs/calculator.kicad_pcb
/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli pcb export drill -o output/gerbers/ output/pcbs/calculator.kicad_pcb

cd output/gerbers
zip -r ../WatchCalc32_Manufacturing/WatchCalc32_Gerbers.zip *
cd ../..
rm -rf output/gerbers

echo "Packaging STLs..."
cd ../scratch/stl
zip -r ../../Hardware/output/WatchCalc32_Manufacturing/WatchCalc32_3D_Models.zip faceplate_mjf.stl faceplate_fdm.stl chassis_tapered.stl top_cap.stl tpu_stretch_cover.stl buttons.stl dummy_pcb.stl
cd ../../Hardware

echo "Generating BOM..."
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 generate_pcbway_bom.py output/pcbs/calculator.kicad_pcb "$OUTDIR/bom.csv"

echo "Generating Centroid..."
# We will use export_manufacturing.py which hardcodes output names, so we run it and move them
/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3 export_manufacturing.py
mv centroid.csv "$OUTDIR/centroid.csv"
# We discard export_manufacturing's bom.csv in favor of the rich one from generate_pcbway_bom
rm -f bom.csv

echo "Cleaning up redundant guides..."
rm -f PCBWAY_ORDERING_GUIDE.md
rm -f PCBWay_Order_Guide.md
rm -rf WatchCalc32_PCBWay_Order

cat << 'EOF' > "$OUTDIR/PCBWay_Order_Guide.md"
# WatchCalc32 PCBWay Ordering Guide

## Files to Upload:
1. **Gerbers:** `WatchCalc32_Gerbers.zip`
2. **BOM:** `bom.csv`
3. **Pick & Place:** `centroid.csv`
4. **3D Printed Parts:** `WatchCalc32_3D_Models.zip` (for CNC/3D printing service)

## Critical Assembly Notes:
- **J1 (LCD FPC):** ZIF Connector for the ERC13265FS-1 LCD display.
- **Battery:** DO NOT supply the CR2032 battery (it has shipping restrictions). Only the JST connector should be placed.
- **Top Clearances:** The MCU (Pico) is rotated horizontally on the back. The JST connector is located at the top-right corner to allow a CR2032 wired battery holder to perfectly clear the board and nest into the chassis top cap.

## PCB Specs:
- Layers: 4 (GND planes on all unused spaces)
- Material: TG 150 (Required)
- Thickness: 1.6mm
- Color: Any (Black/Green recommended)
EOF

echo "All manufacturing files cleanly packaged in $OUTDIR/"
