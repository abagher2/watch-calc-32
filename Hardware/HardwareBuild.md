# Hardware Build: Rugged WatchCalc 32 (Kid-Friendly)

This document outlines the components needed to build a physical, rugged 3D-printed calculator for kids. Our target BOM (Bill of Materials) is **under $15** so it can be sold for ~$20. 

To achieve this at scale and without the nightmare of hand-soldering, we will use a **PCBA (Printed Circuit Board Assembly)** service. The factory will manufacture the board AND machine-solder all the microscopic components for you!

## 1. The "Fully Assembled" PCBA Route
Instead of buying a separate "Pico 2" board and a "TP4056 charge board", we just put the raw silicon chips directly onto our custom board. Services like JLCPCB or PCBWay offer **SMT (Surface Mount Technology) Assembly**. You upload the design, and they use robotic Pick-and-Place machines to solder everything. 

You receive a 100% finished calculator motherboard in the mail.

### SMT Factory Parts (Soldered by the Factory)
| Component | Description | Est. Cost (per board) |
| :--- | :--- | :--- |
| **RP2350 Chip & Flash Memory** | The raw silicon brain of the Raspberry Pi Pico 2 (with hardware FPU). | ~$1.20 |
| **40x SMD Tactile Switches** | Surface-mount buttons. The robot solders all 40 instantly. | ~$0.80 |
| **Passives** | All the tiny resistors, capacitors, and crystal oscillators needed. | ~$0.50 |
| **PCB Fab & Assembly Labor** | The cost of making the board and the robotic soldering. | ~$4.00 |
| **Subtotal** | **A fully functioning motherboard!** | **~$6.60** |

### Off-Board Parts (You plug/solder these in yourself)
Because some parts are bulky, they usually aren't machine-soldered on the cheapest tiers. You just solder 4-6 large pins when the boards arrive:
| Component | Description | Est. Cost |
| :--- | :--- | :--- |
| **2.13" E-Ink Display (SPI)** | Standard Waveshare-compatible 2.13" E-Ink. Plugs into the 8-pin header. Uses zero power when static! | ~$5.00 |
| **CR2450 Battery & Wired Holder** | A 600mAh coin cell in a plastic holder with a JST-PH wire. Plugs directly into the `JST1` port on the motherboard. Lasts for months. | ~$1.00 |
| **Clear Polycarbonate Screen Lens** | A 1mm piece of clear plastic to glue over the E-Ink screen so kids can't poke it. | ~$0.50 |

**Total Estimated Hardware BOM Cost:** ~$10.90 per unit
*(This leaves room for 3D printing filament, screws, and your $5 markup!)*

---

## 2. Making it "Rugged for Kids"

When designing the 3D printed case and PCB, you must account for drops, spills, and rough handling:

1.  **The Screen Protector:** Bare E-Ink glass shatters easily when pressed by a child's thumb. The 3D printed case *must* have a recessed window with a clear acrylic or polycarbonate lens covering the E-Ink display.
2.  **No Exposed Wires:** Because the factory soldered the RP2350 directly onto the board, and the case uses 4 corner screws, it is one solid, indestructible piece of fiberglass. The CR2450 battery will last for months, after which the 4 screws can be removed to swap it.
3.  **TPU Bumper (Optional):** Design the case as a two-part hard shell (PETG or ABS) with an outer sleeve or corner bumpers printed in flexible TPU to absorb shock.

---

## 3. Workflow: Designing for PCBA

If you want the factory to solder everything, the workflow is slightly different:

### Step 1: Schematic Design
We will use KiCad or EasyEDA. Instead of dropping in an "Pico 2" board, we place the raw RP2350 chip symbol and connect its pins to the USB port, the Flash memory, and the 40-button matrix. 

### Step 2: Order the Assembled Boards
Export the Gerber files (for the board shape), the BOM (Bill of Materials), and the CPL/Pick-and-Place file (tells the robot exactly where each button goes). Send to JLCPCB SMT Assembly. 

### Step 3: Final Assembly & Hardware Validation
When the boards arrive, you solder the 2.13" E-Ink display into its designated 8-pin holes, plug the CR2450 wired battery holder into the JST port, and run the MicroPython `board_test.py` script to verify the factory did a good job!
