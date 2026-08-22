#!/bin/bash
set -e

echo "Creating PCBWay Manufacturing Zip..."
rm -f WatchCalc32_PCBWay_Order.zip
mkdir -p output/PCBWay_Order/PCBA_Files
mkdir -p output/PCBWay_Order/Faceplate_Files

# PCBA Files
cp output/WatchCalc32_Gerbers.zip output/PCBWay_Order/PCBA_Files/
cp bom.csv output/PCBWay_Order/PCBA_Files/
cp centroid.csv output/PCBWay_Order/PCBA_Files/

# Faceplate Files
cp ../scratch/stl/faceplate_mjf.stl output/PCBWay_Order/Faceplate_Files/
cp uv_silkscreen.svg output/PCBWay_Order/Faceplate_Files/

cd output/PCBWay_Order
zip -r ../../WatchCalc32_PCBWay_Order.zip *
cd ../..

echo "Creating Local 3D Printing Zip..."
rm -f WatchCalc32_Local_3D_Printing.zip
zip -j WatchCalc32_Local_3D_Printing.zip ../scratch/stl/chassis.stl ../scratch/stl/chassis_tapered.stl ../scratch/stl/top_cap.stl ../scratch/stl/sliding_cover.stl ../scratch/stl/feet.stl ../scratch/stl/tpu_feet.stl ../scratch/stl/faceplate_fdm.stl ../scratch/stl/buttons.stl ../scratch/stl/back_cover.stl ../scratch/stl/battery_door.stl

echo "Done!"
