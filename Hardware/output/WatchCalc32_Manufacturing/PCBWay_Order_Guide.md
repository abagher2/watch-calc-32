# WatchCalc32 PCBWay Ordering Guide

## Files to Upload:
1. **Gerbers:** `WatchCalc32_Gerbers.zip`
2. **BOM:** `bom.csv`
3. **Pick & Place:** `centroid.csv`
4. **3D Printed Parts:** `WatchCalc32_3D_Models.zip` (for CNC/3D printing service)

## Critical Assembly Notes:
- **J1 (LCD FPC):** The LCD must be shimmed exactly 0.07mm to achieve a 1.5mm coplanarity with the tactile switches.
- **Battery:** DO NOT supply the CR2032 battery (it has shipping restrictions). Only the JST connector should be placed.
- **Top Clearances:** The MCU (Pico) is rotated horizontally on the back. The JST connector is located at the top-right corner to allow a CR2032 wired battery holder to perfectly clear the board and nest into the chassis top cap.

## PCB Specs:
- Layers: 4 (GND planes on all unused spaces)
- Material: TG 150 (Required)
- Thickness: 1.6mm
- Color: Any (Black/Green recommended)
