# WatchCalc 32 PCBWay Ordering Guide

The manufacturing files have been successfully bundled into `output/WatchCalc32_PCBWay_Manufacturing.zip`. This zip contains three folders: `PCBA_Files` (for the circuit board assembly), `3D_Printing_Files` (for the ruggedized shell), and `Firmware_Files` (for factory IC programming).

To achieve your target of **$10 per unit** while ensuring the device is waterproof and drop-resistant, please select the following options on the PCBWay UI.

## 1. Ordering the PCBA (Circuit Board Assembly)
Upload the `PCBA_Files` folder to the **PCB Assembly (PCBA)** quoting engine.

### PCB Options
- **Material**: FR-4
- **Layers**: 4
- **Dimensions**: ~71mm x 144mm (refer to gerber bounding box)
- **Thickness**: 1.6mm
- **Min Track/Spacing**: 6/6 mil (0.15mm) - Standard tier
- **Min Hole Size**: 0.2mm
- **Solder Mask**: Matte Black (For premium calculator look)
- **PCB Silkscreen**: White (Note: PCBWay's CAM engineers will automatically trim the PCB silkscreen where it overlaps the 40 tactile switch pads. This is expected and acceptable.)
- **Surface Finish**: ENIG (Electroless Nickel Immersion Gold) - Highly recommended for tactile switch pads and E-Ink FPC connector.
- **Via Process**: Tenting Vias

* **Quantity:** 100 (This amortizes the ~$30 setup fee down to $0.30 per board).
* **Turnkey Assembly:** Yes (PCBWay will source the ALPS switches, the Pico 2 (RP2350) module, the E-Ink display, and the JST battery connector).
* **Factory IC Programming (Firmware):** Upload the `.uf2` file from the `Firmware_Files` folder (e.g. `WatchCalcFirmware_RP2350.uf2` for Pico 2) and request PCBWay to pre-flash the microcontrollers before final assembly.
* **Conformal Coating:** **YES**. *This is the critical step for waterproofing!* Specify "Acrylic (AR)" coating. **CRITICAL INSTRUCTION FOR PCBWAY:** You must instruct them to apply Kapton tape masks over all 40 tactile switches and all headers/through-holes *before* applying the conformal coating. If the liquid coating gets inside the mechanical domes of the switches, it will permanently ruin the buttons.

## 2. Ordering the 3D Printed Shell (Ruggedized)
Go to the **CNC/3D Printing** quoting engine and upload the `.stl` files from `3D_Printing_Files`. Since you are ordering 100 units, 3D printing starts to scale well, but you must choose the right materials.

### Chassis.stl (The Bottom Tub)
* **Technology:** MJF (Multi Jet Fusion)
* **Material:** HP Nylon PA12
* **Color:** Black (Dyed)
* **Why?** Nylon PA12 is extremely tough, highly impact-resistant, and slightly flexible. It will easily survive drops off a school desk without shattering. 

### faceplate_mjf.stl (The Top Cover)
* **Technology:** MJF (Multi Jet Fusion)
* **Material:** HP Nylon PA12
* **Important Note for Factory:** This part contains print-in-place moving buttons with a 0.5mm clearance. Please ensure all unsintered powder is thoroughly blown out of the internal button gaps with compressed air during post-processing.
* **Why?** Same as the chassis. Nylon provides a fantastic matte texture that feels premium and resists scratches.
* **Custom UV Screen Print:** Included in your `3D_Printing_Files` folder is `uv_silkscreen.svg`. Request a "Custom UV Print" for the faceplate and upload this vector file. PCBWay will precisely align this graphic onto the physical faceplate so the calculator keys and titles are perfectly labeled in full color!

## 3. Final Assembly Steps
1. Place the PCB into the Nylon Chassis.
2. Screw the Nylon Faceplate (with its integrated print-in-place buttons) down over the chassis using four M3 self-tapping screws.
3. Stick the 3D-printed angled feet (or standard rubber bumpers) to the back.
4. (Optional) Apply a clear polycarbonate adhesive square over the OLED screen cutout to seal the front display.
