with open("generate_manufacturing_files.sh", "r") as f:
    text = f.read()

text = text.replace(
    "zip -j WatchCalc32_Local_3D_Printing.zip ../scratch/stl/chassis.stl",
    "zip -j WatchCalc32_Local_3D_Printing.zip ../scratch/stl/chassis.stl ../scratch/stl/chassis_tapered.stl"
)

with open("generate_manufacturing_files.sh", "w") as f:
    f.write(text)
