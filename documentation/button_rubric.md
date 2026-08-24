# HP32SII UI & Implementation Rubric

This document tracks how every physical button on the original HP32SII is implemented across all surfaces, providing a definitive reference for parity testing.

## Base State

| Button / Combo | HP32SII Original | Firmware / RetroUI | iOS | WatchOS |
|---|---|---|---|---|
| **√𝑥** | Calculates square root | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **√𝑥** (`𝑥²`) | Calculates square | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **√𝑥** (`PARTS`) | Opens PARTS menu | `shiftState=2` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **𝑒ˣ** | Calculates 𝑒ˣ | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **𝑒ˣ** (`10ˣ`) | Calculates 10ˣ | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **𝑒ˣ** (`PROB`) | Opens PROB menu | `shiftState=2` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **LN** | Calculates natural log | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **LN** (`LOG`) | Calculates base-10 log | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **LN** (`L.R.`) | Opens Linear Reg. menu| `shiftState=2` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **𝑦ˣ** | Calculates power | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **𝑦ˣ** (`ˣ√𝑦`) | Calculates x-root of y | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **𝑦ˣ** (`𝑥̄,𝑦̄`) | Means of x/y | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **¹/𝑥** | Calculates reciprocal | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **¹/𝑥** (`𝑥!`) | Calculates factorial | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **¹/𝑥** (`s,σ`) | StdDev of x/y | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **Σ+** | Adds to stat sum | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **Σ+** (`Σ-`) | Subtracts from stat sum | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **Σ+** (`SUMS`) | Opens SUMS menu | `shiftState=2` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **STO** | Prompts `STO _` | Renders `STO _` on LCD | Opens SwiftUI Alpha Sheet | Opens Full-screen Alpha Picker |
| **YELLOW** + **STO** (`CMPLX`) | Opens Complex Menu | `shiftState=1` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **BLUE** + **STO** (`EQN`) | Opens Equation List | `shiftState=2` -> Physical Key | Opens SwiftUI NavigationStack | Full-screen SwiftUI List |
| **RCL** | Prompts `RCL _` | Renders `RCL _` on LCD | Opens SwiftUI Alpha Sheet | Opens Full-screen Alpha Picker |
| **YELLOW** + **RCL** (`RND`) | Rounds X register | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **RCL** (`SCRL`) | Scrolls LCD | Handled by `RetroUIController` | Handled by `iOSContentView` | Handled by `WatchContentView` |
| **R↓** | Rolls stack down | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **R↓** (`HYP`) | Sets `HYP` flag | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **R↓** (`R↑`) | Rolls stack up | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **SIN** | Calculates sine | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **SIN** (`ASIN`) | Calculates arcsine | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **SIN** (`π`) | Enters PI | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **COS** | Calculates cosine | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **COS** (`ACOS`) | Calculates arccosine | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **COS** (`%`) | Calculates percentage | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **TAN** | Calculates tangent | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **TAN** (`ATAN`) | Calculates arctangent | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **TAN** (`%CHG`) | Percent change | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **ENTER** | Commits stack / eval | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **ENTER** (`LAST𝑥`) | Recalls Last X | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **ENTER** (`SHOW`) | Shows full precision | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **𝑥≷𝑦** | Swaps X and Y | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **𝑥≷𝑦** (`MEM`) | Opens MEM menu | `shiftState=1` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **BLUE** + **𝑥≷𝑦** (`𝑥≷?`) | Prompts `x<>_` | `shiftState=2` -> Physical Key | Opens SwiftUI Alpha Sheet | Opens Full-screen Alpha Picker |
| **+/-** | Toggles sign | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **+/-** (`MODES`) | Opens MODES menu | `shiftState=1` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **BLUE** + **+/-** (`MOD`) | Calculates modulo | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **E** | Starts scientific not. | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **E** (`DISP`) | Opens DISP menu | `shiftState=1` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **BLUE** + **E** (`INT÷`) | Integer division | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **<-** | Backspaces digit/alpha | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **<-** (`CLEAR`) | Opens CLEAR menu | `shiftState=1` -> Physical Key | Opens SwiftUI Menu Sheet | Full-screen SwiftUI List |
| **XEQ** | Prompts `XEQ _` | Renders `XEQ _` on LCD | Opens SwiftUI Alpha Sheet | Opens Full-screen Alpha Picker |
| **YELLOW** + **XEQ** (`FN=`) | Prompts `FN= _` | Renders `FN= _` on LCD | Opens SwiftUI Alpha Sheet | Opens Full-screen Alpha Picker |
| **Numpad 7-9** | Enters 7-9 | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **YELLOW** + **7/8** (`↓/↑`) | Scrolls up/down | `shiftState=1` -> Physical Key | Taps yellow shift -> Button | Tap yellow shift -> Button |
| **BLUE** + **7/8** (`SOLVE/∫`) | Prompts `SOLVE/∫ _` | Renders `SOLVE _` on LCD | Opens SwiftUI Alpha Sheet | Opens Full-screen Alpha Picker |
| **BLUE** + **9** (`▸mi`) | Converts to miles | `shiftState=2` -> Physical Key | Taps blue shift -> Button | Tap blue shift -> Button |
| **Numpad 4-6** | Enters 4-6 | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **Numpad 1-3** | Enters 1-3 | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **Numpad 0** | Enters 0 | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **.** | Enters decimal | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |
| **PLOT** | Enters Plot Mode | Transitions UI to Plot | Opens NavigationStack | Full Screen Plot View |
| **+ / - / × / ÷** | Arithmetic operations | Physical Key -> LCD | Taps native SwiftUI Button | Taps native SwiftUI Button |

---

## Modeless / State-Specific Overrides
The sections below describe how the physical keys behave differently when the calculator is in a specific mode. If a key is not mentioned, it performs its Base State behavior or is disabled (ignored) in that context.

### 1. Menu Mode (e.g., `DISP`, `MODES`, `CLEAR`)
Activated when a menu key is pressed and softkey options are presented.

| Button / Combo | HP32SII Original | Firmware / RetroUI | iOS | WatchOS |
|---|---|---|---|---|
| **LFU Keys (Top 6)** | N/A (Uses softkeys on Retro) | Directly maps to on-screen softkeys | Irrelevant (Taps SwiftUI List/Button) | Irrelevant (Taps SwiftUI List/Button) |
| **<- / C** | Cancels menu | Clears active menu state | Native "Cancel/Done" button or dismisses sheet | Native back button |
| **Numeric Entry** | N/A | Intercepted if `requiresDigit` (e.g. `FIX 4`) | Native number pad on sheet | Full screen digit picker |

### 2. Equation Mode (EQN List)
Activated via `BLUE + STO (EQN)`. Displays the list of available equations.

| Button / Combo | HP32SII Original | Firmware / RetroUI | iOS | WatchOS |
|---|---|---|---|---|
| **LFU Keys (Top 6)** | N/A | Maps to `EQN_NEW` and `EQN_EDIT` softkeys | Uses SwiftUI List interactions | Uses SwiftUI List interactions |
| **YELLOW + 7/8 (`↓/↑`)** | Scrolls equation list | Uses `scrollUp` / `scrollDown` via `c47ActionStr` | Native ScrollView | Native ScrollView |
| **ENTER** | Evaluates equation | Prompts for inputs then evaluates | Evaluates via list tap | Evaluates via list tap |

### 3. Programming Mode (EQN Edit)
Activated when editing a specific Equation/Program. 
> [!NOTE]
> We intentionally deviate from the HP32SII's Algebraic mode here. All targets use a unified RPN Programming Mode to define equations, ensuring a consistent execution model.

| Button / Combo | HP32SII Original | Firmware / RetroUI | iOS | WatchOS |
|---|---|---|---|---|
| **Base Functions (SIN, COS, etc)** | Enters algebraic text | Appends instruction to program steps | Taps iOS button -> Appends step | Taps Watch button -> Appends step |
| **Numpad** | Enters algebraic text | Appends numeric constant as step | Appends numeric constant | Appends numeric constant |
| **ENTER** | Submits equation | Commits current line | Commits current line | Commits current line |
| **<- / C** | Backspaces character | Deletes previous program step | Deletes previous program step | Deletes previous program step |

### 4. Alpha Mode (LBL, STO, RCL Prompts)
Activated when the engine requires a variable or label name (e.g. `STO _`).

| Button / Combo | HP32SII Original | Firmware / RetroUI | iOS | WatchOS |
|---|---|---|---|---|
| **A-Z Keys (Alpha)** | Appends letter | Evaluates physical key's `alphaLabel` | Native iOS Keyboard | Full-screen A-Z Picker |
| **Numpad 0-9** | Appends number | Appends number | Native iOS Keyboard | Full-screen A-Z Picker |
| **<- / C** | Backspaces character | Backspaces character | Native backspace | Native backspace |
| **ENTER** | Submits string | Submits string | Native Enter/Done | Native Enter/Done |

### 5. Plot Mode
Activated via the `PLOT` key.

| Button / Combo | HP32SII Original | Firmware / RetroUI | iOS | WatchOS |
|---|---|---|---|---|
| **Numpad 2/4/6/8** | Pans graph | Pans graph (Up/Left/Right/Down) | Touch pan gesture | Digital Crown or Touch pan |
| **+ / -** | Zooms in/out | Zooms in/out | Pinch gesture | Tap +/- buttons |
| **<- / C** | Exits plot | Exits plot | SwiftUI Back/Done button | SwiftUI Back/Done button |
| **LFU Keys (Top 6)** | N/A | N/A or trace mode | Tap to trace | Tap to trace |
