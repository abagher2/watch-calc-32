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


### 4. Error Handling and Prompts (Nuanced Deviations)

*   **Error States**: When an operation causes a mathematical exception (e.g., `DIVIDE BY 0`, `INVALID DATA`, `OVERFLOW`, `STAT ERROR`), the engine halts and displays the error message on the LCD.
    *   **Deviation from HP32SII**: On the original hardware, pressing a key while an error is displayed both clears the error *and* immediately executes the key's function. In StackCalc32, any keypress while an error is displayed is **swallowed entirely**. The first keypress strictly clears the error state and resets the UI, requiring the user to press the key a second time to execute it.
*   **Prompt Aborts**: When the engine is waiting for a specific digit (e.g., `FIX _` or `SF _`), pressing a random mathematical key (like `+` or `SIN`) is **swallowed entirely**, and the calculator **remains in the prompt state**. The only way to abort the prompt is to explicitly press `C` or `<-`.
*   **Menu Input**: In the Firmware/RetroUI, menus intercept keystrokes. If a key has an `alphaLabel` (like `J` for the `SIN` key), it will filter the menu items alphabetically rather than executing the math function.

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
| `km ↔ mi` Conversions | `YELLOW + 9`, `BLUE + 9` | *(not present)* | StackCalc32 adds km/mi conversions (`->km`, `->mi`) |
| Modulo (`MOD`) | Engine-level | *(not present)* | Supported natively, though not currently mapped to a default physical key |

---

## Summary: Omitted HP32SII Features

The following features from the original manuals have been intentionally omitted or completely replaced by StackCalc32 design choices:

| Omitted Feature | HP32SII Key / Trigger | Rationale for Omission |
|---|---|---|
| **Run/Stop (`R/S`)** | `R/S` physical key | Replaced entirely by the **`PLOT`** key. |
| **Program Mode (`PRGM`)** | `YELLOW + R/S` | Replaced by `CNST` (Physical Constants). Programming mode omitted. |
| **Pause (`PSE`)** | `BLUE + R/S` | Omitted along with the `R/S` key. |
| **Go To (`GTO`)** | Branching Instruction | Omitted. Traditional programming branching is not supported. |
| **Algebraic Equation Entry** | `=`, `(`, `)` | Replaced by RPN step entry. Keys were repurposed to `\|x\|`, `÷R`, and unassigned. |


## Appendix: Shared Operations & Fuzzer Seeds

This section details the operations that are **identical** between the original HP32SII (and DM32) and StackCalc32. These common operations serve as the foundation for the calculator engine. The examples provided here are intended to be used as **seeds for fuzzer testing** to ensure parity across all platforms (Hardware, iOS, watchOS).

### 1. Menu-Driven Operations

Menus require a sequence of keystrokes. The fuzzer must be able to navigate the menu and provide any required follow-up arguments (like a digit for `FIX`).

#### Display Formatting (`DISP` Menu)
Controls how numbers are rendered on the LCD.
*   **`FIX`**: Fixed decimal places. Requires a digit (0-9). Example: `[YELLOW] [DISP] [FIX] [4]` (Sets 4 decimal places).
*   **`SCI`**: Scientific notation. Requires a digit (0-9). Example: `[YELLOW] [DISP] [SCI] [2]` (Sets scientific with 2 decimal places).
*   **`ENG`**: Engineering notation. Requires a digit (0-9). Example: `[YELLOW] [DISP] [ENG] [3]`.
*   **`ALL`**: Show all significant digits. Example: `[YELLOW] [DISP] [ALL]`.

#### Angular Modes (`MODES` Menu)
Controls trigonometric interpretation.
*   **`DEG`**: Degrees. Example: `[YELLOW] [MODES] [DEG]`.
*   **`RAD`**: Radians. Example: `[YELLOW] [MODES] [RAD]`.
*   **`GRAD`**: Gradians. Example: `[YELLOW] [MODES] [GRAD]`.

#### Base & Logic Modes (`BASE` Menu)
Changes the integer base and enables bitwise operations.
*   **`HEX`**, **`DEC`**, **`OCT`**, **`BIN`**. Example: `[YELLOW] [BASE] [HEX]`.
*   **Logic Operations**: `AND`, `OR`, `XOR`, `NOT`. Example in HEX mode: `[A] [ENTER] [5] [BLUE] [AND]` (Result: 0).

#### Number Parts (`PARTS` Menu)
Extracts components of a number.
*   **`IP`**: Integer part. Example: `[1] [.] [5] [BLUE] [PARTS] [IP]` (Result: 1).
*   **`FP`**: Fractional part. Example: `[1] [.] [5] [BLUE] [PARTS] [FP]` (Result: 0.5).
*   **`ABS`**: Absolute value. (Also mapped to `BLUE + +/-`). Example: `[-] [5] [BLUE] [PARTS] [ABS]` (Result: 5).

#### Probability (`PROB` Menu)
*   **`nCr` (Combinations)**: Items in Y, choose X. Example: `[5] [ENTER] [2] [BLUE] [PROB] [nCr]` (Result: 10).
*   **`nPr` (Permutations)**: Items in Y, arrange X. Example: `[5] [ENTER] [2] [BLUE] [PROB] [nPr]` (Result: 20).
*   **`𝑥!` (Factorial)**: Example: `[5] [BLUE] [PROB] [𝑥!]` (Result: 120).
*   **`RAND`**: Generates a pseudo-random number $0 \le x < 1$. Example: `[BLUE] [PROB] [RAND]`.

#### Flags (`FLAGS` Menu)
Sets and clears boolean system flags. Requires a digit (0-9).
*   **`SF` (Set Flag)**: Example: `[BLUE] [FLAGS] [SF] [1]`.
*   **`CF` (Clear Flag)**: Example: `[BLUE] [FLAGS] [CF] [1]`.
*   **`FS?` / `FC?`**: Tests if flag is set/clear (useful in equations).

---

### 2. Standard Mathematical Operations

#### Basic Arithmetic & Unary
*   `+`, `-`, `×`, `÷`: Standard binary operators.
*   `√𝑥`: Square root. Example: `[9] [√𝑥]` (Result: 3).
*   `𝑥²`: Square. Example: `[3] [YELLOW] [𝑥²]` (Result: 9).
*   `𝑦ˣ`: Power. Example: `[2] [ENTER] [3] [𝑦ˣ]` (Result: 8).
*   `¹/𝑥`: Reciprocal. Example: `[4] [¹/𝑥]` (Result: 0.25).
*   `𝑒ˣ`, `LN`, `10ˣ`, `LOG`: Exponential and logarithmic functions.

#### Trigonometry
*   `SIN`, `COS`, `TAN`: Standard trig.
*   `ASIN`, `ACOS`, `ATAN`: Inverse trig (Yellow shifted).
*   **Fuzzer Seed**: `[3] [0] [SIN]` (In DEG mode, Result: 0.5).

#### Percentages
*   `%`: Calculates X percent of Y. Example: `[1] [0] [0] [ENTER] [5] [%]` (Result: 5).
*   `%CHG`: Percent change from Y to X. Example: `[1] [0] [0] [ENTER] [1] [1] [0] [BLUE] [%CHG]` (Result: 10).

---

### 3. Stack Manipulation

*   **`ENTER`**: Duplicates X to Y and disables stack lift.
*   **`x≷y`**: Swaps X and Y registers. Example: `[1] [ENTER] [2] [x≷y]` (X becomes 1, Y becomes 2).
*   **`R↓` (Roll Down)**: Rotates stack downward.
*   **`R↑` (Roll Up)**: Rotates stack upward (Blue shifted).
*   **`LAST𝑥`**: Recalls the value of X prior to the last operation. Example: `[5] [ENTER] [3] [+] [YELLOW] [LAST𝑥]` (X becomes 3).

---

### 4. Memory and Variables

*   **`STO` (Store)**: Requires an alpha character. Example: `[5] [STO] [A]`.
*   **`RCL` (Recall)**: Requires an alpha character. Example: `[RCL] [A]` (Result: 5).
*   **Storage Arithmetic**: Performs math directly on variables. Example: `[1] [0] [STO] [+] [A]` (Adds 10 to variable A).

---

### 5. Statistics & Sums

Statistics require accumulating data points into the summing registers.
*   **`Σ+`**: Adds the X (and Y) values to the statistical registers. Example: `[5] [ENTER] [2] [Σ+]`.
*   **`Σ-`**: Removes a data point.
*   **`SUMS` Menu**: Accesses the raw accumulation registers (`Σx`, `Σy`, `Σx²`, `Σy²`, `Σxy`, `n`).
*   **`𝑥̄,𝑦̄` Menu**: Means (`x̄`, `ȳ`, `x̄w`).
*   **`s,σ` Menu**: Sample and population standard deviations (`sx`, `sy`, `σx`, `σy`).
*   **`L.R.` Menu**: Linear regression (`ŷ`, `x̂`, `r`, `m`, `b`).

---

### 6. Logical Tests

Tests the X and Y registers. If the test is true in normal mode, nothing happens (execution proceeds). If false, it acts as a visual test or skips a step in equations.
*   **`x?y` Menu**: `x=y`, `x≠y`, `x>y`, `x<y`, `x≥y`, `x≤y`. Example: `[YELLOW] [x?y] [x=y]`.
*   **`x?0` Menu**: `x=0`, `x≠0`, `x>0`, `x<0`, `x≥0`, `x≤0`. Example: `[BLUE] [x?0] [x=0]`.

### 7. Nuanced Behaviors & Edge Cases (Fuzzer Targets)

To ensure the Fuzzer deeply validates parity, here are the more esoteric features that are accurately ported from the original hardware:

#### Fractions & Denominator Control (`/c` and `FDISP`)
*   **Toggle Fraction Mode**: `[.] [YELLOW] [FDISP]` switches the display to show fractions (Flag 7).
*   **Exact Denominator (`/c`)**: Sets the maximum denominator. 
    *   Example: `[1] [6] [.] [BLUE] [/c]` forces all fractions to be out of 16 (often used in construction/carpentry).
    *   This also implicitly evaluates system flags `Flag 8` and `Flag 9` to dictate if the fraction should forcefully remain unreduced (e.g., `8/16` vs `1/2`).

#### Storage Arithmetic (`STO+`, `STO-`, etc.)
Instead of recalling, adding, and storing, math can be performed directly on variables.
*   **`STO+`**: `[1] [0] [STO] [+] [A]` adds 10 to the current value of variable A.
*   **`STO×`**: `[2] [STO] [×] [A]` doubles variable A.

#### Indirect Addressing `(i)`
The `i` variable can be used as a pointer to other variables or statistical registers.
*   If `i = 1`, `(i)` targets variable `A`.
*   If `i = 26`, `(i)` targets variable `Z`.
*   If `i = 27`, `(i)` targets `i` itself.
*   If `i = 28` through `33`, `(i)` targets the statistical registers (`Σn` through `Σxy`).
*   **Fuzzer Seed**: `[1] [STO] [i]`, then `[9] [9] [STO] [(i)]` (stores 99 into variable A).

#### Complex Numbers (`CMPLX`)
*   **Creating a Complex Number**: Push the imaginary part to X, and real part to Y. 
    *   Example: `[3] [ENTER] [4] [YELLOW] [CMPLX]` creates `3 + 4i`.
*   **Complex Math**: Subsequent math operators (`+`, `-`, `×`, `÷`, `√𝑥`, `𝑒ˣ`, etc.) automatically branch to complex-domain equivalents if either operand has an imaginary component.

#### View Variable (`VIEW`)
*   **`VIEW`**: Transiently renders a variable's contents to the LCD without pushing it to the stack.
    *   Example: `[BLUE] [VIEW] [A]` temporarily displays `A = 99.0000` until the next keystroke.
