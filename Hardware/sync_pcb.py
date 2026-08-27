import pcbnew
import os

BOARD_FILE = "output/pcbs/calculator.kicad_pcb"

def sync_pcb():
    print(f"Loading {BOARD_FILE}...")
    board = pcbnew.LoadBoard(BOARD_FILE)
    bbox = board.GetBoardEdgesBoundingBox()
    
    x_min = bbox.GetX() / 1e6
    y_max = bbox.GetBottom() / 1e6
    
    # 1. Extract and sort buttons
    buttons = []
    disp_fp = None
    
    for fp in board.GetFootprints():
        ref = fp.GetReference()
        if (ref.startswith("B") and len(ref) <= 4) or ref.startswith("SOFT"):
            pos = fp.GetPosition()
            x = pos.x / 1e6 - x_min
            y = y_max - pos.y / 1e6 
            buttons.append({'fp': fp, 'ref': ref, 'x': x, 'y': y})
        elif "Disp" in ref:
            disp_fp = fp
            
    # Group into rows by Y coordinate
    buttons.sort(key=lambda b: b['y'], reverse=True)
    rows = []
    current_row = []
    if not buttons:
        print("No buttons found!")
        return
        
    current_y = buttons[0]['y']
    for b in buttons:
        if abs(b['y'] - current_y) > 5:
            current_row.sort(key=lambda b: b['x'])
            rows.append(current_row)
            current_row = []
            current_y = b['y']
        current_row.append(b)
    if current_row:
        current_row.sort(key=lambda b: b['x'])
        rows.append(current_row)
        
    print(f"Found {len(rows)} rows of buttons.")
    
    # Procedural Constants from generate_scad.py
    X_START = 7.6
    X_SPACING = 11.0
    Y_START = 94.0 # Soft keys
    Y_SPACING = 12.0
    Y_NUMPAD_GAP = 0.0
    
    # Determine if soft keys exist in the schematic yet
    has_soft_keys = len(rows) >= 8
    
    labels = [
        ["", "", "", "", "", ""], # Soft keys
        ["√𝑥", "𝑒ˣ", "LN", "𝑦ˣ", "1/𝑥", "Σ+"],
        ["STO", "RCL", "R↓", "SIN", "COS", "TAN"],
        ["ENTER", "𝑥≷𝑦", "+/-", "E", "<-"],
        ["XEQ", "7", "8", "9", "÷"],
        ["yellow", "4", "5", "6", "×"],
        ["blue", "1", "2", "3", "-"],
        ["C", "0", ".", "PLOT", "+"]
    ]
    
    if not has_soft_keys:
        labels = labels[1:] # Skip soft key math if they aren't on the PCB yet
        Y_START = Y_START - Y_SPACING # Start at Row 1 instead of Row 0
        
    for r_idx, row_labels in enumerate(labels):
        if r_idx >= len(rows):
            break
            
        y_scad = Y_START - r_idx * Y_SPACING
        # If we skipped soft keys, the numpad gap occurs at r_idx=3 instead of 4
        if (has_soft_keys and r_idx >= 4) or (not has_soft_keys and r_idx >= 3):
            y_scad -= Y_NUMPAD_GAP
            
        y_kicad = y_max - y_scad
        
        for c_idx, lbl in enumerate(row_labels):
            if c_idx >= len(rows[r_idx]):
                continue
                
            if len(row_labels) == 6:
                x_scad = X_START + c_idx * X_SPACING
            else: # 5 columns
                if c_idx == 0:
                    if lbl == "ENTER":
                        x_scad = X_START + (X_SPACING / 2)
                    else:
                        x_scad = X_START
                else:
                    x_scad = X_START + (c_idx + 1) * X_SPACING
                    
            x_kicad = x_min + x_scad
            
            # Apply to footprint
            fp = rows[r_idx][c_idx]['fp']
            fp.SetPosition(pcbnew.VECTOR2I(int(x_kicad * 1e6), int(y_kicad * 1e6)))
            print(f"Moved {fp.GetReference()} to X:{x_kicad:.2f} Y:{y_kicad:.2f}")

    # Move display
    if disp_fp:
        DISP_Y_SCAD = 117.0
        y_disp_kicad = y_max - DISP_Y_SCAD
        # Keep original X
        x_disp_kicad = disp_fp.GetPosition().x / 1e6
        disp_fp.SetPosition(pcbnew.VECTOR2I(int(x_disp_kicad * 1e6), int(y_disp_kicad * 1e6)))
        print(f"Moved Display to Y:{y_disp_kicad:.2f}")

    # Move MCU and JST underneath the display (on the back of the PCB)
    mcu_fp = board.FindFootprintByReference("MCU1")
    if mcu_fp:
        x_mcu_kicad = x_min + 37.325
        y_mcu_kicad = -103.0
        mcu_fp.SetPosition(pcbnew.VECTOR2I(int(x_mcu_kicad * 1e6), int(y_mcu_kicad * 1e6)))
        mcu_fp.SetOrientation(pcbnew.EDA_ANGLE(90.0, pcbnew.DEGREES_T))
        print(f"Moved and Rotated MCU1 to X:{x_mcu_kicad:.2f} Y:{y_mcu_kicad:.2f}")

    jst_fp = board.FindFootprintByReference("JST1")
    if jst_fp:
        x_jst_kicad = x_min + 62.0
        y_jst_kicad = (bbox.GetY() / 1e6) + 15.0  # 15mm from the top edge
        jst_fp.SetPosition(pcbnew.VECTOR2I(int(x_jst_kicad * 1e6), int(y_jst_kicad * 1e6)))
        # Rotate it so the connector faces inward/upward
        jst_fp.SetOrientation(pcbnew.EDA_ANGLE(0.0, pcbnew.DEGREES_T))
        print(f"Moved JST1 (Battery) to X:{x_jst_kicad:.2f} Y:{y_jst_kicad:.2f}")

    pcbnew.SaveBoard(BOARD_FILE, board)
    print("PCB successfully aligned to STLs!")

if __name__ == "__main__":
    sync_pcb()