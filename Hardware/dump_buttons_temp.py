import pcbnew

board = pcbnew.LoadBoard("calculator.kicad_pcb")

print("Button X Coordinates:")
x_coords = []
for module in board.GetFootprints():
    val = module.GetValue()
    if "Tactile" in val:
        pos = module.GetPosition()
        x = pcbnew.ToMM(pos.x)
        x_coords.append(x)

if x_coords:
    min_x = min(x_coords)
    max_x = max(x_coords)
    print(f"Buttons span from X = {min_x:.2f} to X = {max_x:.2f}")
    print(f"Total span = {max_x - min_x:.2f} mm")
else:
    print("No tactile buttons found.")
