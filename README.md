# WatchCalc32 ⌚️🖩

WatchCalc32 is a comprehensive RPN (Reverse Polish Notation) calculator ecosystem inspired by classic HP calculators (like the HP-32S). Designed to be a world-class, rigorous tool for engineering and math students, it is available as a suite of Apple ecosystem apps and as a fully open-source physical hardware device.

This monorepo contains the entire project, spanning iOS, watchOS, embedded firmware, and physical hardware designs.

## 🌟 Features

- **True RPN Engine**: A robust Reverse Polish Notation core (`RPNCore`) designed for precision, speed, and mathematical rigor.
- **Cross-Platform Software**:
  - **Apple Watch App (`WatchCalc32`)**: A full-featured RPN calculator on your wrist, complete with equation plotting, statistical analysis, menus, and complex math functions.
  - **iOS/iPadOS App (`WatchCalc32-iOS`)**: A companion app featuring an immersive, haptic-enabled numpad (`HapticNumpadView`) that feels incredibly tactile—just like a classic physical calculator.
- **Physical Hardware**: Fully open-source 3D models (chassis, faceplates, buttons) and KiCAD PCB designs for building your own physical WatchCalc32 device.
- **Embedded Firmware**: Microcontroller code (utilizing Swift Embedded / Pico SDK) powering the physical calculator.

## 🚀 Modern Enhancements (vs. Classic HP-32SII)

While WatchCalc32 is heavily inspired by the classic HP-32SII and other vintage HP calculators, it introduces several modern capabilities designed for today's engineering workflows:

- **RPN Equation Editor**: An intuitive editor that feels like programming, but is optimized for quick equation entry and evaluation without the overhead of full program management.
- **Equation Plotting**: Visually plot your equations directly on the screen to analyze functions, roots, and behaviors.
- **Built-in Constants**: A comprehensive library of built-in scientific constants for quick access during calculations.
- **Registers Display List**: Easily view and manage the contents of all your memory registers in a dedicated list view, rather than blindly recalling them one by one.
- **Advanced Division Operations**: Native support for division with remainders and modulus operations.
- **LFU (Least Frequently Used) Keys**: Dynamic keys that adapt to your usage, keeping the interface uncluttered while ensuring you always have access to the functions you need.

## 📂 Repository Structure

To maintain a clean and organized monorepo ready for public open-source distribution, this repository strictly adheres to the following structure:

- `WatchCalc32/` - The watchOS application target.
- `WatchCalc32-iOS/` - The iOS/iPadOS application target (Container App).
- `RPNCore/` - The shared, core RPN mathematical engine.
- `Shared/` - Shared SwiftUI views, themes, and logic used across both Apple platforms.
- `Hardware/` - Physical calculator design files, including KiCAD schematics (`.kicad_sch`), PCB layouts (`.kicad_pcb`), OpenSCAD 3D models, and gerber files.
- `Firmware/` - Embedded Swift / C code for the physical microcontroller.
- `fastlane/` - Automated App Store screenshots, metadata, and submission scripts.
- `scratch/` - *(Git-ignored)* Directory for temporary scripts, parsed logs, exploratory testing, and raw extractions.

## 🛠️ Development & Building

### iOS & watchOS Apps

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to manage the Xcode project configuration, eliminating `.pbxproj` merge conflicts.

1. Ensure XcodeGen is installed (e.g., via Homebrew): 
   ```bash
   brew install xcodegen
   ```
2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
3. Open `WatchCalc32.xcodeproj` in Xcode and select the target (`WatchCalc32Container` for iOS/iPad or `WatchCalc32` for Apple Watch) to build and run.

### Hardware & Firmware

- **3D Models**: Modify the `.scad` files in `Hardware/` and use the provided `generate_scad.py` script to compile the final `.stl` files for 3D printing. *(Note: To keep the repository light, `.stl` files are explicitly git-ignored).*
- **Firmware**: Built using the Apple Swift Embedded toolchain or Raspberry Pi Pico SDK. See the `Firmware/` directory for specific hardware bring-up and build instructions.

## 📄 License & Privacy

- **License**: Please refer to the [LICENSE](LICENSE) file for open-source licensing details.
- **Privacy Policy**: See the [Privacy Policy](PRIVACY_POLICY.md) for information regarding data collection (WatchCalc32 does not collect or store user data).

---
*Built for the next generation of engineers who appreciate the elegance of RPN.*