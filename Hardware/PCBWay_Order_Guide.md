# StackCalc32 Prototype Ordering Guide

For this prototyping phase, we are splitting the manufacturing between **PCBWay** (for the complex printed circuit board and the faceplate) and **Local 3D Printing** (for the chassis, buttons, top cap, and cover).

## 1. PCBWay Order Bundle (`StackCalc32_PCBWay_Manufacturing_Bundle.zip`)

This bundle contains everything you need to send to PCBWay. It is split into internal folders:

### A. `PCBA_Files` (The Circuit Board)
Upload this folder to the **PCB Assembly (PCBA)** quoting engine.
- **Material**: FR-4
- **Layers**: 4
- **Thickness**: 1.6mm
- **Solder Mask**: Matte Black
- **Surface Finish**: ENIG (Electroless Nickel Immersion Gold)
- **Turnkey Assembly:** Yes (PCBWay sources ALPS switches, Pico 2 RP2350, Sharp Memory LCD LS027B7DH01, JST battery connector, etc.).
- **CRITICAL ASSEMBLY NOTE (COPLANARITY):** You MUST instruct PCBWay to shim the Sharp LCD with tape by exactly **0.07mm** so its Z-height off the PCB is exactly **1.50mm**. This perfectly matches the height of the ALPS switches, allowing the assembled PCBA to slide flush into the chassis rails.
- **Conformal Coating:** **YES**. Specify "Acrylic (AR)" coating.
- **CRITICAL MASKING INSTRUCTION:** You MUST instruct PCBWay to apply Kapton tape masks over all 40 tactile switches AND the Sharp LCD connector *before* conformal coating.

### B. `Faceplate_Files` (The MJF Nylon Cover)
Go to the **CNC/3D Printing** quoting engine and upload the `.stl` file from this folder.
* **faceplate_fdm.stl** (Standard flat design)
* **faceplate_tapered.stl** (Classic HP-32SII style with raised, sloped bezel around screen)
- **Technology:** MJF (Multi Jet Fusion)
- **Material:** HP Nylon PA12
- **Surface Finish:** Dyed Black + UV Silkscreen (Upload `uv_silkscreen.svg` to apply labels)
- **Clearance Note for Factory:** This part contains print-in-place moving buttons with exactly **0.60mm** clearance on a 45-degree chamfer. This gap is well within the 0.3mm to 0.5mm standard clearance for moving parts in MJF. Ensure unsintered powder is blown out of the internal button gaps.

---

## 2. Local 3D Printing Bundle 

This bundle contains the parts you can print locally on your own FDM or Resin printer for the prototype.

- **chassis.stl** (Standard) OR **chassis_tapered.stl** (Classic wedge-shaped back) OR **chassis_tpu.stl** (For use with flexible materials)
- **top_cap.stl**: The top cover that seals the display/battery end.
- **sliding_cover.stl**: Optional hard sliding cover (PLA/PETG).
- **tpu_stretch_cover.stl**: Solid TPU flexible bumper cover (Tupperware lid style, no cutouts).
- **faceplate_fdm.stl**: Standard faceplate with 0.4mm micro-supports for local FDM testing.

---

## 3. Final Assembly Steps

1. Place the assembled PCB into your locally printed Chassis. It sits on the embedded standoffs.
2. Slide the Top Cap into place over the display end.
3. Place the Faceplate over the PCB.
4. **Fastening:** Use **four M2 machine screws**. The clearance holes in the chassis are precisely `d=2.2mm` (Do NOT use M3 screws!). The faceplate has blind holes designed to receive the M2 thread.
