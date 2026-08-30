# HP32SII Deviation Rubric

This document tracks **only the ways StackCalc32 intentionally deviates from the original HP32SII**. Any key combination not listed here is expected to behave identically to the HP32SII (or DM32 where noted). Refer to the [HP 32SII Owner's Manual](https://www.hpcalc.org/hp32s/) and [DM32 User Manual](https://technical.swissmicros.com/dm32/) for baseline behavior.

For a full description of how every menu operates across all surfaces, see [menu_operation.md](menu_operation.md).

---

## Base State — Key Remaps & Additions

These keys exist on the physical StackCalc32 hardware but **differ in label or function** from the HP32SII.

| Button / Combo | HP32SII Original | StackCalc32 | Rationale |
|---|---|---|---|
| **BLUE + +/-** | `(` (open parenthesis — for EQN/solver entry) | `\|x\|` (Absolute Value) | Parentheses are less useful in RPN direct mode; ABS is more ergonomic. |
| **BLUE + E** | `)` (close parenthesis — for EQN/solver entry) | `÷R` (Integer Division) | Parentheses serve EQN mode only; `÷R` is more useful as a direct key. |
| **BLUE + <-** | `=` (equals — for EQN/solver entry) | *(no function)* | `=` is not needed in RPN mode; key is left unassigned. |
| **YELLOW + 0** | `INPUT` (program input prompt — recall var and show name+value) | `REGS` (Show Registers) | `INPUT` is programming-only. StackCalc32 repurposes the key for the register viewer. |
| **PLOT** | *(key does not exist on HP32SII)* | Opens Plot Mode | StackCalc32-exclusive key. Not on the HP32SII or DM32. |
| **YELLOW + PLOT** | *(key does not exist)* | `CNST` (Physical Constants Menu) | StackCalc32-exclusive. HP32SII has no built-in constants menu; users stored constants in registers. |

---

## LFU Row (Top 6 Dynamic Softkeys)

The **LFU (Least Frequently Used) row** is a StackCalc32-exclusive feature. The HP32SII has **no dedicated softkey row** — its top row of keys (`√𝑥`, `𝑒ˣ`, `LN`, `𝑦ˣ`, `¹/𝑥`, `Σ+`) are always fixed math function keys, with no dynamic softkey strip at all.

StackCalc32 permanently reserves the top 6 keys as a dynamic, context-aware softkey strip. In menu contexts, this LFU row repurposes identically to how the HP32SII repurposed its numeric top row — except it is reserved for this purpose at all times rather than only during menus.

| Context | HP32SII Original | StackCalc32 Firmware / RetroUI | iOS / watchOS |
|---|---|---|---|
| **Normal State** | Top row = `√𝑥 𝑒ˣ LN 𝑦ˣ ¹/𝑥 Σ+` (always fixed) | Top row shows 6 most recently used functions (LFU algorithm) | N/A — no physical row |
| **Menu Active** | Top numeric row remapped to softkey labels | LFU row remaps to softkeys (e.g., `FIX SCI ENG ALL`) | Native sheet / list replaces entirely |
| **EQN List** | *(no softkeys — navigate with `↓`/`↑` only)* | LFU row shows `EQN_NEW`, `EQN_EDIT` softkeys | Native list with `+` button and swipe-to-delete |

---

## Menu Navigation Model

All menus exist on all three surfaces and produce identical calculator results. The **mechanism** differs by surface. This is not a functional deviation — it is a platform adaptation.

| Surface | How Menus Are Navigated |
|---|---|
| **HP32SII** | Physical softkey row (top numeric keys) remapped to menu labels during menu state. User presses the key physically below the label on the LCD. Multi-page menus use a `▸` page key. |
| **Firmware / RetroUI** | LFU row replaces the softkey row. Same single-press selection. `requiresDigit` menus (FIX, SCI, ENG, SF, CF) wait for a follow-up digit keypress on the same row. |
| **iOS** | Native modal sheet with tappable list items. `requiresDigit` menus present an inline digit picker. Dismisses automatically after selection. |
| **watchOS** | Full-screen SwiftUI list. Tap or Digital Crown to select. Sub-picker for digit-requiring options. |

> [!NOTE]
> See [menu_operation.md](menu_operation.md) for the complete per-menu breakdown of items and behavior on each surface.

The following menus are present on all surfaces with **no functional deviation** from the HP32SII. Only the navigation mechanism differs as described above:

| Menu | Trigger | HP32SII Items | StackCalc32 Additions |
|---|---|---|---|
| **DISP** | `YELLOW + E` | `FIX n`, `SCI n`, `ENG n`, `ALL` | — |
| **MODES** | `YELLOW + +/-` | `DEG`, `RAD`, `GRAD` | — |
| **BASE** | `YELLOW + ×` | `HEX`, `DEC`, `OCT`, `BIN` | — |
| **CLEAR** | `YELLOW + <-` | `CLx`, `CLVARS`, `CLΣ`, `ALL` *(PGM only in PRGM mode)* | `CLEQN`, `CLREGS`, `CLSTK` added as always-visible items |
| **FLAGS** | `BLUE + ×` | `SF n`, `CF n`, `FS? n`, `FC? n` | `4-LVL`, `8-LVL`, `INF` stack-size options |
| **MEM** | `YELLOW + x≷y` | `VARS`, `PRGM`, `REGS` | — |
| **PARTS** | `BLUE + √𝑥` | `IP`, `FP`, `ABS` | `SGN` added |
| **PROB** | `BLUE + 𝑒ˣ` | `Cn,r`, `Pn,r`, `𝑥!`, `RAND` | — |
| **SUMS** | `BLUE + Σ+` | `Σx`, `Σy`, `Σx²`, `Σy²`, `Σxy`, `n` | — |
| **𝑥̄,𝑦̄** | `BLUE + 𝑦ˣ` | `x̄`, `ȳ`, `x̄w` | — |
| **s,σ** | `BLUE + ¹/𝑥` | `sx`, `sy`, `σx`, `σy` | — |
| **L.R.** | `BLUE + LN` | `ŷ`, `x̂`, `r`, `m`, `b` | — |
| **𝑥?𝑦** | `YELLOW + ÷` | `x=y`, `x≠y`, `x>y`, `x<y`, `x≥y`, `x≤y` | — |
| **𝑥?0** | `BLUE + ÷` | `x=0`, `x≠0`, `x>0`, `x<0`, `x≥0`, `x≤0` | — |

---

## Modeless / State-Specific Deviations

### 1. Programming / Equation Mode (EQN Edit)

> [!IMPORTANT]
> This is the **largest intentional deviation** from the HP32SII.

The HP32SII uses **algebraic entry** for equations (e.g., `SIN(X) + 1`). StackCalc32 intentionally deviates: all equation equations use **RPN instruction entry** (appending steps like `SIN`, `1`, `+`). This creates a unified execution model across the physical device, iOS, and watchOS.

| Button / Combo | HP32SII Original | StackCalc32 |
|---|---|---|
| **Base Functions (SIN, COS, etc.)** | Appends algebraic text character(s) to equation | Appends RPN instruction step |
| **Numpad** | Appends digit(s) to algebraic expression | Appends numeric constant as a discrete step |
| **ENTER** | Submits the algebraic equation | Commits the current RPN program to storage |
| **`<-` / C** | Backspaces one character in algebraic string | Deletes the previous RPN instruction step |

---

### 2. Plot Mode — `PLOT` key

The HP32SII has **no Plot Mode**. This entire section is a StackCalc32 extension.

| Button / Combo | HP32SII Original | StackCalc32 |
|---|---|---|
| **PLOT** | *(key does not exist)* | Enters Plot Mode — transitions UI to graph renderer |
| **Numpad 2/4/6/8** | *(N/A)* | Pans graph (Down/Left/Right/Up) |
| **+ / -** | *(N/A)* | Zooms in/out |
| **`<-` / C** | *(N/A)* | Exits plot, returns to normal mode |
| **LFU Keys (Top 6)** | *(N/A)* | Reserved for trace mode (not yet implemented) |

---

### 3. Alpha Mode — Platform Differences Only

The Alpha entry mode (triggered by `STO _`, `RCL _`, `XEQ _`, etc.) behaves identically to the HP32SII on the Firmware/RetroUI surface. The iOS and watchOS surfaces deviate only at the **input mechanism level** — the calculator engine behavior is identical.

| Platform | Alpha Input Method | Deviation from HP32SII? |
|---|---|---|
| **Firmware / RetroUI** | Physical alpha key labels (`A`–`Z` printed on key faces) | **No deviation** |
| **iOS** | Native iOS keyboard sheet | UI-level only — engine accepts same inputs |
| **watchOS** | Full-screen A–Z picker | UI-level only — engine accepts same inputs |

---

## Summary: StackCalc32-Only Additions (Not on HP32SII)

| Feature | Key / Trigger | HP32SII Original | Notes |
|---|---|---|---|
| LFU Dynamic Softkey Row | Top 6 physical keys | Fixed math keys (`√𝑥 𝑒ˣ LN 𝑦ˣ ¹/𝑥 Σ+`) | HP32SII had no softkey row |
| Physical Constants Menu (`CNST`) | `YELLOW + PLOT` | *(key doesn't exist)* | HP32SII: users stored constants in registers |
| Plot Mode | `PLOT` (dedicated key) | *(key doesn't exist)* | Full graphing; HP32SII had no plot capability |
| Register Viewer (`REGS`) | `YELLOW + 0` | `INPUT` (program input prompt) | Repurposes a programming-only key |
| Absolute Value (`\|x\|`) | `BLUE + +/-` | `(` (open parenthesis for EQN) | Parentheses less useful in RPN direct mode |
| Integer Division (`÷R`) | `BLUE + E` | `)` (close parenthesis for EQN) | Parentheses less useful in RPN direct mode |
| `CLEQN`, `CLREGS`, `CLSTK` | Inside `CLEAR` menu | Not in HP32SII CLEAR menu | HP32SII CLEAR has: `CLx`, `CLVARS`, `CLΣ`, `ALL` |
| `SGN` | Inside `PARTS` menu | Not in HP32SII PARTS menu | HP32SII PARTS has: `IP`, `FP`, `ABS` |
| Stack Size Flags (`4-LVL`, `8-LVL`, `INF`) | Inside `FLAGS` menu | HP32SII has a fixed 4-level stack | |
| `EQN_NEW`, `EQN_EDIT` softkeys | LFU row in EQN List | *(no softkeys in EQN list)* | HP32SII navigates equations with `↓`/`↑` only |
