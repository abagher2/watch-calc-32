import re
import uuid

BOARD_FILE = "output/pcbs/calculator.kicad_pcb"

def add_soft_keys():
    with open(BOARD_FILE, "r") as f:
        data = f.read()

    if "SOFT1" in data:
        print("Soft keys already exist in the PCB.")
        return

    # Extract B3 footprint as template using stack parsing to handle nested parentheses
    start_idx = data.find('(footprint "E73:SW_TACT_ALPS_SKQGABE010"')
    b3_text = ""
    while start_idx != -1:
        # Find the end of this footprint
        paren_count = 0
        end_idx = -1
        for i in range(start_idx, len(data)):
            if data[i] == '(':
                paren_count += 1
            elif data[i] == ')':
                paren_count -= 1
                if paren_count == 0:
                    end_idx = i
                    break
        
        if end_idx != -1:
            candidate = data[start_idx:end_idx+1]
            if '"B3"' in candidate:
                b3_text = candidate
                break
        
        start_idx = data.find('(footprint "E73:SW_TACT_ALPS_SKQGABE010"', start_idx + 1)
        
    if not b3_text:
        print("Could not find B3 footprint to clone.")
        return
    
    col_nets = ["P7", "P8", "P9", "P15", "P14", "P16"]
    row_net = "P20" # Free GPIO
    
    new_footprints = []
    
    for i in range(6):
        fp_text = b3_text
        
        # Give unique UUIDs
        def repl_uuid(m):
            return f'(uuid "{str(uuid.uuid4())}")'
        fp_text = re.sub(r'\(uuid "[0-9a-f\-]+"\)', repl_uuid, fp_text)
        
        # Change Reference
        fp_text = fp_text.replace('"B3"', f'"SOFT{i+1}"')
        
        # Change Row Net (B3 Pad 1 is P4 -> P20)
        fp_text = fp_text.replace('(net "P4")', f'(net "{row_net}")')
        
        # Change Col Net (B3 Pad 2 is P7 -> col_nets[i])
        if col_nets[i] != "P7":
            fp_text = fp_text.replace('(net "P7")', f'(net "{col_nets[i]}")')
            
        # Change initial placement so sync_pcb groups it as the Top Row (Y = -137.9)
        fp_text = re.sub(r'\(at [-\d\.]+ [-\d\.]+\)', f'(at 0 -137.9)', fp_text, count=1)
        
        new_footprints.append(fp_text)
        
    # Append to board right before the last closing parenthesis
    data = data.rstrip()
    if data.endswith(")"):
        data = data[:-1]
        
    for fp in new_footprints:
        data += "\n\t" + fp.replace("\n", "\n\t")
        
    data += "\n)\n"
    
    with open(BOARD_FILE, "w") as f:
        f.write(data)
        
    print("Successfully injected 6 soft keys into PCB.")

if __name__ == "__main__":
    add_soft_keys()
