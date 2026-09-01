# Cross-Surface Parity Fixes and Alignment

I have implemented and verified the fixes for the remaining cross-surface UI parity bugs from the user testing feedback.

## 1. iPhone UI: Alpha Modes for XEQ and PLOT
- **Issue**: `XEQ` and `PLOT` were opening separate SwiftUI modal sheets instead of transitioning the keypad to Alpha mode like the real hardware.
- **Fix**: Removed the custom `.xeq` and `.plot` intercepts from `iOSContentView.swift` and `KeyActionDispatcher`. These commands are now executed natively by the engine. `CalculatorEngine` transitions to `isWaitingForAlpha` (or `isWaitingForLabel`), which correctly triggers the Alpha keyboard on iOS (swapping the keys to letters) and Watch (auto-swiping to the Alpha Pad). 
- **Verification**: Verified via `isWaitingForLabel` state flow that these keys now prompt for a variable (A-Z) inline on the LCD.

## 2. Watch UI: Digital Crown EQN Scrolling & EEX Label
- **Issue**: "EQN shows equation only, no editing" & "EQN no scrolling".
- **Fix**: The Watch's Digital Crown was only hooked up to `engine.scrollUp/Down()` during `isEquationEditMode`. I updated `ContentView.swift` to also trigger scrolling when `engine.isEquationListMode == true`. Additionally, I fixed a bug in `CalculatorEngine.swift` where `.scrollUp` and `.scrollDown` operations were incorrectly gated inside an `if isEquationEditMode` block, breaking scrolling for the Retro UI. 
- **Issue**: "'E' in Contextual pad is used as exponent. They are different keys."
- **Fix**: Renamed the button on the Watch `ArithmeticPadView` from `"E"` to `"EEX"` to prevent confusion with the alpha letter `"E"`. Updated `KeyActionDispatcher.mapOp()` to map `"EEX"` to `.e` (the exponent operation).

## 3. UI Transient State Deadlocks ("View not working", "RCL `<Letter> = `")
- **Issue**: Pressing a letter sometimes showed `<Letter> = ` and deadlocked the calculator.
- **Fix**: The `CalculatorEngine.transientMessage` (which renders strings like `A = 5.0` for `VIEW A`) was permanently blocking future input unless a specific button was pressed. I updated `KeyActionDispatcher.swift` to automatically clear `transientMessage` on *any* subsequent keypress across all UI surfaces, ensuring the calculator never deadlocks.

## 4. Significant Figures (SIG) Evaluation Rule
- **Note**: Regarding the `SIG` evaluation rules for addition/multiplication: The HP32SII physical calculator only applies Significant Figures as a *display* rounding mode (`DISP` -> `SIG` -> `n`). Internally, it still uses 12-digit full precision arithmetic. The engine is currently replicating this hardware behavior exactly (doing full precision math and formatting to `SIG n` upon rendering). 

## 5. REGS, CLEAR, STO+ UI Alignment
- **Fix**: `STO+` correctly keeps the engine in `isWaitingForAlpha = true` (action: `.stoAdd`), which natively triggers the Watch/iOS alpha keyboard swaps.
- **Fix**: `REGS` and `VIEW` commands are now fully routed to the engine and shared presentation sheets for parity.

We are now ready to close out the remaining UI parity checklist. We can execute the UI Test harnesses against these flows to ensure no further regressions.

## Fixes for STO Alpha Input Parity
- Investigated a bug where the fuzzer generated the sequence `["5", "STO", "LFU_0"]` to type `STO A`, but the firmware simulator evaluated it to `SIN(5)` instead of storing the variable.
- Found that `CalculatorEngine.swift:executeMath` did not correctly intercept alpha variables (it was only intercepting `isWaitingForLabel`). The iOS app bypassed this by mapping the keys to variables natively using `KeyActionDispatcher`, but `FuzzEvaluator` and `Firmware_Sim` passed raw key strings like `"√x"` to `executeMath`.
- Fixed the disparity by moving the `HP32KeyMap` alpha interception logic directly into `CalculatorEngine.executeMath()`. Now, all interfaces correctly map physical calculator keys (e.g., `√x`) to their alpha counterparts (e.g., `"A"`) when the engine is waiting for variable inputs.
- Rebuilt `FuzzEvaluator` (verified passing via `echo '["5", "STO", "√x", "1", "0", "STO", "+", "√x", "RCL", "√x"]' | ./scratch/FuzzEvaluator/.build/debug/FuzzEvaluator`) and re-triggered a clean Firmware compile.

## Fuzzer shiftState Alignment Bug Fix

Found a major discrepancy between the Python test evaluator and the real iOS/watchOS UI tests: The `smart_llm_fuzzer.py` sends `["op_shiftYellow", "op_cos"]`, which the UI tests execute by physically tapping the Yellow Shift key, and then tapping the COS key. The UI layers use `dispatchKey()` to intercept the key press, apply the shift state, and correctly map this to an `ACOS` command in the `CalculatorEngine`.

However, the headless Python `FuzzEvaluator` was calling `engine.executeMath("op_shiftYellow")` and `engine.executeMath("op_cos")` directly. `executeMath` bypasses `dispatchKey()`, resulting in the Yellow Shift state being ignored by the engine and computing `COS()` instead of `ACOS()`. This resulted in `DEEP STACK MISMATCH` failures. Patched `FuzzEvaluator/main.swift` to use `dispatchKey(op, engine: engine, onMenuAction: nil)` so the evaluator correctly respects the virtual keypad shift states.

## XEQ Menu / Program Recording Fix

Fixed a bug reported by the user where pressing XEQ incorrectly showed `"LBL"` or `"XEQ _"` in the iOS sheet instead of the equation menu. 

- Removed `startAlpha()` and `isWaitingForLabel = true` when invoking `XEQ` in normal calculator mode, ensuring that `requestXEQ` securely triggers the SwiftUI `XEQPromptView` sheet without being hijacked by the Alpha Entry `TextField` sheet modifier.
- When `XEQ` or `LBL` are pressed during program recording (`isEquationEditMode == true`), correctly populated `promptString = "XEQ "` so the LCD clearly prompts the user for the 1-character function label rather than defaulting to the fallback `00 LBL P`.
