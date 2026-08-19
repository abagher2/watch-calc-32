set -e
KICAD_PYTHON="/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3"
npx -y ergogen ergogen_config.yaml
# $KICAD_PYTHON extract_coords.py

$KICAD_PYTHON add_silkscreen.py "output/pcbs/calculator.kicad_pcb"
$KICAD_PYTHON inject_eink.py "output/pcbs/calculator.kicad_pcb"
$KICAD_PYTHON inject_logo.py "output/pcbs/calculator.kicad_pcb"

$KICAD_PYTHON add_soft_keys.py
$KICAD_PYTHON sync_pcb.py

$KICAD_PYTHON set_rules.py "output/pcbs/calculator.kicad_pcb"
$KICAD_PYTHON fix_switch_pads.py "output/pcbs/calculator.kicad_pcb"
$KICAD_PYTHON export_dsn.py "output/pcbs/calculator.kicad_pcb" "output/pcbs/board.dsn"

export JAVA_HOME="/usr/local/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
java -jar freerouting.jar -de output/pcbs/board.dsn -do output/pcbs/board.ses -mp 40 -mt 1

$KICAD_PYTHON auto_router.py "output/pcbs/calculator.kicad_pcb" "output/pcbs/board.ses"

$KICAD_PYTHON generate_scad.py

mkdir -p output/WatchCalc32_PCBWay_Manufacturing/3D_Printing_Files/
cp designs/stl/*.stl output/WatchCalc32_PCBWay_Manufacturing/3D_Printing_Files/ || true
cp designs/stl/*.stl ./ || true

echo "PCB and STLs generated and successfully saved to Hardware/ directory!"
