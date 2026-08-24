# PCBWay Manufacturing & Assembly Guide

## Overview
This guide provides specific instructions for ordering the StackCalc32 PCBA (Printed Circuit Board Assembly) through PCBWay. 

Because the calculator is designed around a zero-fastener "slide-in" cartridge architecture, the Z-height tolerances of the assembled components are absolutely critical. If components protrude too far, the cartridge will jam inside the 3D-printed chassis.

## 1. PCB Specifications
- **Layers:** 2 or 4 Layer (Standard FR4)
- **Thickness:** 1.6mm (CRITICAL: Do not use 1.2mm or 2.0mm, as the chassis rails are tuned for exactly 1.6mm + 0.2mm clearance).
- **Surface Finish:** ENIG (Electroless Nickel Immersion Gold) recommended for keypad reliability.
- **Solder Mask:** Matte Black (for aesthetics when viewed through chassis gaps).

## 2. PCBA (Assembly) Z-Height Requirements
When submitting the BOM and CPL (Component Placement List) to PCBWay, you **MUST** include the following custom assembly notes for the engineers. The fully assembled board must have a uniform front-facing component height of **1.5mm**.

### A. Tactile Switches (Keyboard)
- **Part:** ALPS SKQGABE010 (or equivalent ultra-low profile SMD tactile switch).
- **Assembly Note:** The Z-height of the tactile switches must be exactly **1.5mm** off the surface of the PCB. Negative tolerance (1.4mm) is acceptable. Positive tolerance (1.6mm+) will cause the buttons to permanently actuate against the faceplate.

### B. E-Ink Display Stackup
- **Part:** 24-pin FPC ZIF Connector (Bottom Contact) + Bare E-Ink Glass Panel (e.g., Good Display or Waveshare bare panel).
- **Assembly Note:** Do **NOT** use thick Arduino breakout boards with 8-pin headers. The bare E-Ink glass must be mounted directly to the PCB surface using thin double-sided adhesive foam. 
- **Tolerance Note:** The combined thickness of the adhesive foam + the E-Ink glass must not exceed **1.5mm**. (e.g., a 1.18mm glass panel requires a 0.3mm thick foam pad).

## 3. Submission Checklist
1. Export Gerber files from KiCad (`File -> Fabrication Outputs -> Gerbers`).
2. Run the `generate_pcbway_bom.py` script to generate the Rich BOM.
3. Upload the Gerbers, BOM, and Pick & Place (CPL) file to PCBWay.
4. **Important:** Add a "Customer Note" linking to this document or explicitly pasting the Z-Height tolerance requirements above.
