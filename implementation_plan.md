# Fix Spring Attachments, ENTER Shaft, and Key Labels

This plan addresses all issues found in the recent slicer review of the print-in-place calculator keypad.

## Proposed Changes

### 1. Fix Spiral Spring Attachments
- **Issue:** The spiral springs currently stop at `r=4.0`, while the button cavity is `w+btn_gap` (~9.3mm). This leaves the ends of the springs floating in mid-air, requiring supports.
- **Fix:** Modify `button_solid` to calculate the exact distance to the cavity wall (`w/2 + btn_gap/2`). Extend the `spiral_arm` radius to completely bridge the gap.
- **Result:** The spiral arms will fuse perfectly to the faceplate cavity walls during slicing, anchoring the buttons without any supports.

### 2. Fix ENTER Button Shaft
- **Issue:** The ENTER button was generated with two inner shafts, which does not align with the single tactile switch on the PCB.
- **Fix:** Remove the `if (w > 15)` double-shaft logic in `generate_scad.py`. All buttons (including ENTER) will use a single, centrally-aligned inner shaft and spring mechanism.

### 3. Extract and Apply All iOS App Labels
- **Issue:** Side labels were only applied to a few keys using dummy data.
- **Fix:** Parse `HP32KeyMap.swift` to extract the `yellowLabel`, `blueLabel`, and `alphaLabel` for every single key on the grid.
- **Mapping:** 
  - `yellowLabel` -> Left Skirt (`label_left`)
  - `blueLabel` -> Right Skirt (`label_right`)
  - `alphaLabel` -> Front Skirt (`label_alpha`)

### 4. Rotate and Deepen Side Labels
- **Issue:** Side labels are oriented vertically, and the emboss depth is too shallow.
- **Fix:** Update the label `rotate()` transformations in `generate_scad.py` so they read horizontally (left-to-right) along the Y-axis. Increase the subtraction depth to `0.8mm` to ensure they slice clearly.

## User Review Required
Please approve this plan so I can proceed with patching the Python generator and extracting the exact labels from your iOS source code!
