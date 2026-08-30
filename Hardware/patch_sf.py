import re

with open("designs/button_v9_test.scad", "r") as f:
    code = f.read()

code = code.replace("dummy_text(label_alpha)", "sf_word(label_alpha, d_button - 2.0, min(d_button*0.16, z_top*0.18))")
code = code.replace("dummy_text(label_left)", "sf_word(label_left, d_button - 2.0, min(d_button*0.16, z_top*0.18))")
code = code.replace("dummy_text(label_right)", "sf_word(label_right, d_button - 2.0, min(d_button*0.16, z_top*0.18))")

with open("designs/button_v9_test.scad", "w") as f:
    f.write(code)

