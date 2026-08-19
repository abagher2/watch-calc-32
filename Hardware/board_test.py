import machine
import time

# --- PINS DEFINITION ---
# OLED I2C
SDA_PIN = 0
SCL_PIN = 1

# DM32 Keyboard Matrix (6 Columns x 8 Rows)
COL_PINS = [10, 11, 12, 13, 14, 15]
ROW_PINS = [5, 6, 7, 8, 26, 27, 28, 29]

print("===================================")
print("WatchCalc 32 - Hardware Diagnostics")
print("===================================")

# --- 1. TEST I2C BUS (OLED) ---
print("\n[1] Testing I2C Bus for OLED...")
i2c = machine.I2C(0, sda=machine.Pin(SDA_PIN), scl=machine.Pin(SCL_PIN), freq=400000)
devices = i2c.scan()
if devices:
    print(f"✅ Success! Found I2C devices at addresses: {[hex(d) for d in devices]}")
    print("   (Standard OLED is usually 0x3c or 0x3d)")
else:
    print("❌ FAILED: No I2C devices found. Check OLED soldering and wiring.")

# --- 2. SETUP MATRIX ---
print("\n[2] Setting up Button Matrix...")
rows = [machine.Pin(p, machine.Pin.IN, machine.Pin.PULL_UP) for p in ROW_PINS]
cols = [machine.Pin(p, machine.Pin.OUT) for p in COL_PINS]

# Set all columns HIGH initially
for col in cols:
    col.value(1)

print("\n--- DIAGNOSTICS READY ---")
print("Press any button on the 43-key DM32 layout. Press Ctrl+C to stop.\n")

def scan_matrix():
    pressed_keys = []
    for c_idx, col in enumerate(cols):
        # Pull column LOW
        col.value(0)
        time.sleep_us(10) # Small delay to let voltage settle
        
        # Read rows
        for r_idx, row in enumerate(rows):
            if row.value() == 0: # Button pressed pulls row to LOW
                pressed_keys.append(f"R{r_idx + 1}-C{c_idx + 1}")
                
        # Pull column back HIGH
        col.value(1)
    return pressed_keys

last_pressed = []

try:
    while True:
        # Read Matrix
        current_pressed = scan_matrix()
        if current_pressed and current_pressed != last_pressed:
            print(f"⌨️  Button(s) Pressed: {', '.join(current_pressed)}")
            
        last_pressed = current_pressed
        
        time.sleep(0.01)

except KeyboardInterrupt:
    print("\nExiting hardware test.")
