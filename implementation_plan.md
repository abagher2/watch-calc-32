# Solid Unibody Face-Up Faceplate Refactor

We will refactor `button_faceplate` in `generate_scad.py` to be a solid unibody block that prints perfectly face-up (Z=0 at the back, Z=3.0 at the front) with integrated compliant buttons.

## User Review Required
The faceplate body will be completely solid from Z=0 to Z=3.0, except for the squircle cutouts for the buttons. This guarantees extreme rigidity. 

## Open Questions
- Is a 3.0mm total thickness correct for the button faceplate? 
- We will set the button top surface flush with Z=3.0, and the sunken labels etched from Z=3.0 down to Z=2.6. Does this match your intent?

## Proposed Changes

### `Hardware/generate_scad.py`

#### [MODIFY] generate_scad.py
- **Remove** the hollow shell logic (Front Face, Side Walls, Bottom/Top walls).
- **Create** a solid `squircle_centered` block for the entire faceplate body from Z=0 to Z=3.0 (with rails integrated at the edges).
- **Implement a new `button_hole_and_mechanism` module**:
    - **Cut** a squircle hole through the solid faceplate from Z=0 to Z=3.0 for each button.
    - **Add** the spiral spring at Z=0 to Z=0.6 (connecting the hole wall to the shaft).
    - **Add** the cruciform shaft at Z=0.
    - **Add** the upper dome from Z=0.6 upwards, hulling out to the full squircle button shape.
    - **Add** the squircle button top and subtract the 3D text label.

## Verification Plan
1. Generate the SCAD and STL files using `generate_scad.py`.
2. Inspect the STL in a 3D viewer (via a Python PyVista script) to guarantee:
   - The faceplate is solid.
   - The spiral springs are flat on the bottom (Z=0).
   - The button tops are squircles with sunken text.
   - Zero overhangs > 45 degrees.
