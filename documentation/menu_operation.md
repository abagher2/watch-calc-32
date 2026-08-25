# Menu Operation Reference

This document defines the **intended operation** of every menu and prompt across the three surfaces. All three surfaces produce the same calculator result — they differ only in how the user navigates to it.

> [!NOTE]
> **Firmware/RetroUI** is the closest to the original HP32SII experience. **iOS and watchOS** replace physical softkey navigation with native platform UI (sheets, lists, pickers) to make the same operations ergonomic on a touchscreen.

---

## Alpha Prompts
*Operations that ask the user to name a variable, label, or register.*

### STO — Store to Variable
| Surface | Operation |
|---|---|
| **HP32SII** | Press `STO`. LCD shows `STO _`. Press any alpha key (A–Z) or digit (0–9 for `R0`–`R9`). Value stores immediately. |
| **Firmware** | Identical. LCD renders `STO _`, waits for physical key with an `alphaLabel`. |
| **iOS** | `STO` opens a full-screen alpha keyboard sheet. User types one character and taps Done. |
| **watchOS** | `STO` opens a full-screen A–Z crown/tap picker. |

### RCL — Recall from Variable
| Surface | Operation |
|---|---|
| **HP32SII** | Press `RCL`. LCD shows `RCL _`. Press any alpha key or digit. Value pushed to X register. |
| **Firmware** | Identical to HP32SII. |
| **iOS** | `RCL` opens the alpha keyboard sheet. |
| **watchOS** | Full-screen A–Z picker. |

### XEQ — Execute Program
| Surface | Operation |
|---|---|
| **HP32SII** | Press `XEQ`. LCD shows `XEQ _`. Press alpha label (A–Z) to run program from that label. |
| **Firmware** | Identical. LCD renders `XEQ _`. |
| **iOS** | Opens alpha keyboard sheet. |
| **watchOS** | Full-screen A–Z picker. |

### FN= — Set Solver/Integral Function
| Surface | Operation |
|---|---|
| **HP32SII** | Press `YELLOW + XEQ`. LCD shows `FN= _`. Press alpha label of the equation to use for SOLVE/∫. |
| **Firmware** | Identical. |
| **iOS** | Opens alpha keyboard sheet. |
| **watchOS** | Full-screen A–Z picker. |

### LBL — Define Program Label
| Surface | Operation |
|---|---|
| **HP32SII** | In program mode, press `YELLOW + +`. LCD shows `LBL _`. Press alpha to set the label. |
| **Firmware** | Identical. |
| **iOS** | Alpha keyboard sheet, used within program editor. |
| **watchOS** | Full-screen A–Z picker within program editor. |

### x↔? — Swap X with Named Register
| Surface | Operation |
|---|---|
| **HP32SII** | Press `BLUE + x≷y`. LCD shows `x↔_`. Press alpha or digit for register name. |
| **Firmware** | Identical. |
| **iOS** | Alpha keyboard sheet. |
| **watchOS** | Full-screen A–Z picker. |

### VIEW — View Register Value
| Surface | Operation |
|---|---|
| **HP32SII** | Press `BLUE + 0`. LCD shows `VIEW _`. Press alpha/digit. LCD displays `[var]=[value]`. |
| **Firmware** | Identical. |
| **iOS** | Alpha picker → displays result in a toast/alert. |
| **watchOS** | Alpha picker → displays result on screen. |

---

## Softkey Menus
*Operations that present a set of choices on the HP32SII's top-row softkeys.*

### DISP — Display Format (`YELLOW + E`)
**Items:** `FIX n`, `SCI n`, `ENG n`, `ALL`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkey row shows `FIX SCI ENG ALL`. Press the key below the label. `FIX/SCI/ENG` then immediately prompt for a digit (0–9) on the same row. |
| **Firmware** | Identical softkey flow. LFU row shows `FIX SCI ENG ALL`. After selecting, firmware waits for a digit keystroke. |
| **iOS** | Opens a sheet with `FIX / SCI / ENG / ALL` as tappable options. `FIX/SCI/ENG` present an inline number picker (0–9). |
| **watchOS** | Full-screen list → sub-picker for decimal places. |

### MODES — Angle Mode (`YELLOW + +/-`)
**Items:** `DEG`, `RAD`, `GRAD`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkey row shows `DEG RAD GRAD`. Press to set immediately. |
| **Firmware** | Identical softkey flow via LFU row. |
| **iOS** | Sheet with three tappable options. Tapping sets immediately. |
| **watchOS** | Full-screen list with three options. |

### BASE — Number Base (`YELLOW + ×`)
**Items:** `HEX`, `DEC`, `OCT`, `BIN`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkey row shows `HEX DEC OCT BIN`. Press to switch base. LCD displays current value in new base. Keyboard remapped for hex entry. |
| **Firmware** | Identical. LFU row shows base options. |
| **iOS** | Sheet with four base options. Tapping switches base and dismisses. |
| **watchOS** | Full-screen list. |

### CLEAR — Clear Options (`YELLOW + <-`)
**HP32SII items:** `CLx`, `CLVARS`, `CLΣ`, `ALL` *(PGM only in PRGM mode)*
**StackCalc32 adds:** `CLPRGM`, `CLREGS`, `CLSTK` as always-visible items

| Surface | Operation |
|---|---|
| **HP32SII** | Softkey row shows `x VARS Σ ALL`. In PRGM mode, `PGM` also appears. Press to clear immediately. There is no `CLSTK` or `CLREGS` on the HP32SII. |
| **Firmware** | LFU row shows all 6 items including StackCalc32 additions. Press to clear immediately. |
| **iOS** | Sheet with all options as a list. Destructive actions show a confirmation. |
| **watchOS** | Full-screen list with confirmation on destructive items. |

### FLAGS — Flag Operations (`BLUE + ×`)
**Items:** `SF n`, `CF n`, `FS? n`, `FC? n`, `4-LVL`, `8-LVL`, `INF`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkey row shows `SF CF FS? FC?`. Press flag operation, then enter flag number (0–9). Stack-size options (`4-LVL`, `8-LVL`, `INF`) are StackCalc32 additions. |
| **Firmware** | LFU row shows all 7 items. `SF/CF/FS?/FC?` wait for a digit press. Stack-level items apply immediately. |
| **iOS** | Sheet lists all options. Flag number options open an inline digit picker. |
| **watchOS** | Full-screen list → sub-picker for flag number. |

### MEM — Memory Info (`YELLOW + x≷y`)
**Items:** `VARS`, `PRGM`, `REGS`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkey row shows `VARS PRGM REGS`. Press to view the count/size of each category on the LCD. |
| **Firmware** | LFU row shows `VARS PRGM REGS`. Pressing displays info on the LCD. |
| **iOS** | Sheet shows a summary card with counts for each category. |
| **watchOS** | Full-screen view with memory breakdown. |

---

## Statistical & Math Menus

### PARTS — Number Parts (`BLUE + √𝑥`)
**HP32SII items:** `IP` (integer part), `FP` (fractional part), `ABS`
**StackCalc32 adds:** `SGN`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkeys `IP FP ABS`. Press to apply to X register. |
| **Firmware** | LFU row shows `IP FP ABS SGN`. Applies immediately to X register. |
| **iOS** | Sheet with four tappable operations. |
| **watchOS** | Full-screen list. |

### PROB — Probability (`BLUE + 𝑒ˣ`)
**HP32SII items:** `Cn,r` (combinations), `Pn,r` (permutations), `𝑥!`, `RAND`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkeys `Cn,r Pn,r 𝑥! RAND`. `Cn,r` uses Y=n, X=r; pops both and pushes result. |
| **Firmware** | Identical. LFU row applies operation immediately. |
| **iOS** | Sheet with four tappable operations. |
| **watchOS** | Full-screen list. |

### SUMS — Statistical Sums (`BLUE + Σ+`)
**Items:** `Σx`, `Σy`, `Σx²`, `Σy²`, `Σxy`, `n`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkeys page through the six accumulated sums. Press to push the value onto X register. |
| **Firmware** | LFU row shows all 6. Press to push value onto X register. |
| **iOS** | Sheet lists all sums with current values displayed inline. Tap to push. |
| **watchOS** | Full-screen scrollable list with values shown. |

### 𝑥̄,𝑦̄ — Statistical Means (`BLUE + 𝑦ˣ`)
**Items:** `x̄`, `ȳ`, `x̄w` (weighted mean)

| Surface | Operation |
|---|---|
| **HP32SII** | Softkeys show mean options. Press to push result to X register. |
| **Firmware** | LFU row. Press to push result to X. |
| **iOS** | Sheet with three options. |
| **watchOS** | Full-screen list. |

### s,σ — Standard Deviation (`BLUE + ¹/𝑥`)
**Items:** `sx`, `sy`, `σx`, `σy`

| Surface | Operation |
|---|---|
| **HP32SII** | Softkeys for sample and population std dev of x and y datasets. |
| **Firmware** | LFU row. Press to push result to X. |
| **iOS** | Sheet with four options. |
| **watchOS** | Full-screen list. |

### L.R. — Linear Regression (`BLUE + LN`)
**Items:** `ŷ` (estimate + correlation), `x̂`, `r` (correlation coefficient), `m` (slope), `b` (intercept)

| Surface | Operation |
|---|---|
| **HP32SII** | Softkeys for regression results. `ŷ` uses X as the input value. Press to push result. |
| **Firmware** | LFU row. Identical to HP32SII behavior. |
| **iOS** | Sheet with all options. |
| **watchOS** | Full-screen list. |

### 𝑥?𝑦 — Conditional Tests vs Y (`YELLOW + ÷`)
**Items:** `x=y`, `x≠y`, `x>y`, `x<y`, `x≥y`, `x≤y`

| Surface | Operation |
|---|---|
| **HP32SII** | In programming mode, inserts a conditional test instruction. In direct mode, skips the next instruction if the condition is false. |
| **Firmware** | Identical. |
| **iOS** | In program editor: sheet with 6 test options to insert. In direct mode: applies test immediately. |
| **watchOS** | Full-screen list within program editor. |

### 𝑥?0 — Conditional Tests vs 0 (`BLUE + ÷`)
**Items:** `x=0`, `x≠0`, `x>0`, `x<0`, `x≥0`, `x≤0`

| Surface | Operation |
|---|---|
| **HP32SII** | Same pattern as 𝑥?𝑦, comparing X against zero. |
| **Firmware** | Identical. |
| **iOS** | Sheet with 6 test options. |
| **watchOS** | Full-screen list. |

---

## StackCalc32-Only Menus

### CONST — Physical Constants (`YELLOW + PLOT`)
**Items:** π, e, h, c, G, Nₐ, R, k *(expandable to 40+ constants)*

| Surface | Operation |
|---|---|
| **HP32SII** | *Does not exist.* Users stored constants in lettered registers manually. |
| **Firmware** | LFU row shows first 6 constants. Press to push value to X. |
| **iOS** | Searchable sheet with symbol and description. Tap to push to X. |
| **watchOS** | Full-screen scrollable list with search via crown. |

---

## EQN List (`BLUE + STO`)

| Surface | Operation |
|---|---|
| **HP32SII** | LCD shows equation list. Navigate with `YELLOW + 7` (↓) / `YELLOW + 8` (↑). `ENTER` evaluates (prompts for unknown variables). No softkeys for management. |
| **Firmware** | LCD-based list with same navigation. LFU row adds `EQN_NEW` and `EQN_EDIT` softkeys (StackCalc32 additions). `ENTER` evaluates. |
| **iOS** | `NavigationStack` list. Tap row to evaluate. `+` button to add. Swipe-to-delete. |
| **watchOS** | Full-screen SwiftUI list. Tap to evaluate. Long-press for edit/delete. |

---

## SOLVE and ∫ Prompts

### SOLVE (`BLUE + 7`)
| Surface | Operation |
|---|---|
| **HP32SII** | LCD shows `SOLVE _`. Press alpha label of equation. Prompts for known variable values; solves for the unknown. |
| **Firmware** | Identical. |
| **iOS** | Alpha picker to select equation label, then native input fields for known variables. |
| **watchOS** | EQN list picker → crown/digit input for variable values. |

### ∫ — Integrate (`BLUE + 8`)
| Surface | Operation |
|---|---|
| **HP32SII** | LCD shows `∫ _`. Press alpha label. Integration limits supplied via X and Y registers before calling. |
| **Firmware** | Identical. |
| **iOS** | Alpha picker → native input for integration limits. |
| **watchOS** | EQN list picker → crown input for limits. |
