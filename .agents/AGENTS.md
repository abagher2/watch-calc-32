# WatchCalc32 Protocol: Workspace Organization

This repository is a monorepo for the WatchCalc32 project, encompassing the iOS app, watchOS app, physical hardware (PCBs/3D Models), and microcontroller firmware.

To maintain a clean and structured repository that is ready for public open source distribution, **never place scratch files, scripts, or project files directly in the repository root.** 

Always strictly adhere to the following directory structure:

## 1. Temporary and Scratch Files
- **Directory:** `scratch/` (This directory is explicitly ignored by git)
- **Contents:** ALL temporary files, exploratory scripts (`.py`, `.rb`, `.sh`), ad-hoc test Swift scripts (`test_xxx.swift`), parsed logs, extracted coordinates, raw screenshots, and temporary JSON transcripts.
- **Rule:** If it's a one-off script used for code generation, bug fixing, layout extraction, or testing an idea, it belongs in `scratch/`. Do NOT put these in the root directory.

## 2. Hardware and Manufacturing
- **Directory:** `Hardware/`
- **Contents:** Everything related to the physical version of the calculator. This includes KiCAD schematics (`.kicad_sch`), PCB layouts (`.kicad_pcb`), OpenSCAD files, STL/STEP 3D models (for chassis, buttons, faceplates), gerber zips, and python scripts that directly generate or validate hardware (e.g., `generate_faceplate.py`, `check_unrouted.py`).

## 3. Microcontroller Firmware
- **Directory:** `Firmware/`
- **Contents:** All Swift Embedded firmware or Pico SDK code for the physical calculator's microcontroller.

## 4. Software App Targets
- **Watch App:** `WatchCalc32/`
- **iOS App:** `WatchCalc32-iOS/`
- **Shared Logic & Views:** `Shared/`
- **Core Calculator Engine:** `RPNCore/`

## 5. Repository Root
- **Contents:** ONLY standard repository configuration files (`.gitignore`, `project.yml`, `README.md`, `LICENSE`, `PrivacyPolicy.md`).
- **Rule:** Do not generate or store new files, certificates (`.p12`, `.cer`), binaries (`.ipa`), or build artifacts directly in the root directory.
