# StackCalc32 Prototype Ordering Guide

For this prototyping phase, we are splitting the manufacturing between **PCBWay** (PCBA — board + assembly) and **Local 3D Printing** (chassis, buttons, top cap, and cover).

---

## 1. PCBWay PCBA Order (`WatchCalc32_Gerbers.zip`)

Upload `output/WatchCalc32_Gerbers.zip` + BOM + centroid to PCBWay's **PCB Assembly** quoting engine.

### Verified Specs (from KiCad PCB file)

| Parameter | Value | Notes |
|---|---|---|
| **Board Type** | Single pieces | |
| **Layers** | **2** | F.Cu + B.Cu only. Inner layer exists in stackup but carries zero routing. |
| **Size** | 70.65 × 143.15 mm | |
| **Quantity** | 5 | |
| **Material** | FR-4 TG130 | Standard. TG150 unnecessary for a 2-layer board. |
| **Thickness** | 1.6 mm | |
| **Min Track/Spacing** | **6/6 mil** | 0.150mm = metric 6mil (PCBWay's standard process). Not a fine-line board. |
| **Min Hole Size** | **0.2 mm** | Surcharge applies (↑). Cannot change without PCB redesign. |
| **Solder Mask** | **Green** | ~~Matte Black~~ — incompatible with J1's 0.2mm pad spacing (PCBWay min bridge = 0.22mm). |
| **Silkscreen** | White | |
| **Surface Finish** | **ENIG (1U")** | Required for J1 fine-pitch FFC connector. HASL cannot reliably solder 0.2mm pitch. |
| **Via Process** | Tenting | |
| **Finished Copper** | 1 oz Cu | |
| **Remove Product No.** | Yes | |
| **Assembly** | **Turnkey** | PCBWay sources all components and assembles. |

---

### PCBWay Engineering Hold — Resolution

PCBWay flagged J1: pad spacing **0.2mm < 0.22mm** minimum for black soldermask bridges.
**Resolution: change soldermask to green.** Updated gerbers attached.

---

### What Changed vs. Original Order

| Spec | Original | Corrected | Reason |
|---|---|---|---|
| Layers | 4 | **2** | Inner copper layer has zero routing |
| Min Track | 6/6 mil | **6/6 mil** ✓ | No change needed — 0.150mm = metric 6mil |
| Solder Mask | Matte Black | **Green** | J1's 0.2mm spacing is below PCBWay's 0.22mm black mask minimum |
| Material | S1000H TG150 | **TG130** | TG150 is for high-temp multilayer; unnecessary here |

---

### Critical Assembly Instructions for PCBWay

> **⚠️ COPLANARITY — Sharp LCD (LS027B7DH01):**
> The Sharp Memory LCD must be shimmed so its top surface sits exactly **1.50mm** above the PCB surface. This matches the height of the ALPS switches and allows the assembled PCBA to slide into the chassis rails without rocking. Apply **0.07mm Kapton tape** shim beneath the LCD module before soldering its connector.

> **Note:** No conformal coating. This is a prototype — skip coating to allow easy rework and avoid masking complexity on the 40 ALPS switches.

---

## 2. Draft Email to PCBWay

---

**To:** service@pcbway.com  
**Subject:** Re: Engineering Question — Order #[YOUR ORDER NUMBER] — Soldermask Update + New Gerbers

---

Hi PCBWay Engineering Team,

Thank you for reviewing our files and catching this issue.

**Resolution for the soldermask bridge question:**
Please change the soldermask color from **Matte Black to Green**. We have attached updated Gerber files (`WatchCalc32_Gerbers.zip`) reflecting this change. No pad spacing or layout changes were made — the updated files are otherwise identical to the original submission.

**Updated board specifications:**

| Parameter | Value |
|---|---|
| Layers | 2 |
| Material | FR-4 TG130 |
| Thickness | 1.6mm |
| Min Track/Spacing | 6/6 mil |
| Min Hole Size | 0.2mm |
| **Solder Mask** | **Green** (updated from Matte Black) |
| Silkscreen | White |
| Surface Finish | ENIG (1U") |
| Via Process | Tenting |
| Finished Copper | 1 oz Cu |
| Assembly | Turnkey |

**Special assembly instruction (please confirm receipt):**

1. **LCD Coplanarity:** The Sharp Memory LCD (LS027B7DH01) must be shimmed with **0.07mm Kapton tape** beneath the module before soldering, so that its top surface sits exactly **1.50mm** above the PCB. This height matches the ALPS tactile switches and is required for the mechanical chassis fit.

Please confirm that you have received the updated Gerber files and that these assembly instructions are noted on the work order. Let us know if you have any further questions.

Thank you,  
[YOUR NAME]

---

**Attachments:**
- `WatchCalc32_Gerbers.zip` (updated — soldermask Green)
- `bom.csv` (unchanged)
- `centroid.csv` (unchanged)

---

## 3. Local 3D Printing Bundle

| File | Description | Material |
|---|---|---|
| `chassis_tapered.stl` | Main chassis (tapered wedge back) | PLA or PETG |
| `top_cap.stl` | Seals display/battery end | PLA |
| `tpu_stretch_cover.stl` | Flexible bumper cover | TPU |
| `faceplate_fdm.stl` | Faceplate with print-in-place buttons | PLA |
| `buttons.stl` | Separate button caps | PLA |

> **Nozzle:** 0.4mm standard. For sharper sunken button labels, upgrade to 0.25mm ([Prusa Brass 0.25mm — $21.99](https://www.prusa3d.com/en/product/prusa-nozzle-brass-0-25-mm/))

---

## 4. Final Assembly Steps

1. Slide the assembled PCBA into the chassis from the display end.
2. Slide the Top Cap onto the display end.
3. Slide the Faceplate in from the top — button caps align with PCB switch positions.
4. **Fasten** with **four M2 machine screws** (clearance holes `d=2.2mm` — do NOT use M3).
