"""
This code scans the docx version of the TS 38.331 file and extracts 
all the IEs so that they can be compiled using ASN1.C.

Author: Milind Kumar V
"""

import re
import numpy as np
import docxpy


################### defining variables ###################

path_ts = "./38331-f80.docx"
path_out_text = "./definitions.txt"


################### process the file ###################

contents = docxpy.process(path_ts)

contents = contents.strip().split("\n")


start_tag = "-- ASN1START"
stop_tag = "-- ASN1STOP"

with open(path_out_text, "w") as file:
	copy = False
	for line_idx in range(len(contents)):
		line = contents[line_idx]
		if line.strip() == start_tag:
			copy = True
			continue
		elif line.strip() == stop_tag:
			copy = False
			continue
		elif copy:
			file.write(line + "\n")


