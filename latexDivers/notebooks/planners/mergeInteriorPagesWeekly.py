#!/usr/bin/env python3

"""
Description: [Weekly Planner]Merging sample page of [dot|graph|lined] Interior Pages to same booklet (for more than one page). 
Author: Gabriel Chandesris 
Date Created: May 14, 2025
Date Created: May 14, 2025
Version: 1.0.0
Python Version: 3.8.10
Dependencies: PyPDF2
License: GPL
"""

## https://stackabuse.com/working-with-pdfs-in-python-reading-and-splitting-pages/
## https://pypi.org/project/PyPDF2/
## https://pypdf2.readthedocs.io/en/3.0.0/

## https://www.normaprint.fr/blog/les-zones-de-page-pdf/

## https://pypdf2.readthedocs.io/en/3.0.0/modules/PaperSize.html
## (width, height) of the paper in portrait mode in pixels at 72 ppi.
## A0 = Dimensions(width=2384, height=3370)
## A1 = Dimensions(width=1684, height=2384)
## A2 = Dimensions(width=1191, height=1684)
## A3 = Dimensions(width=842, height=1191)
## A4 = Dimensions(width=595, height=842)
## A5 = Dimensions(width=420, height=595)
## A6 = Dimensions(width=298, height=420)
## A7 = Dimensions(width=210, height=298)
## A8 = Dimensions(width=147, height=210)
## C4 = Dimensions(width=649, height=918)

usageTXT = "mergeInteriorPagesWeekly.py [1|2|3] \n\t where [dotgridinteriorpages|graphinteriorpages|linedinteriorpages]"
def printUsage():
  print("Usage: ", str(usageTXT))

import os
from PyPDF2 import PdfWriter, PdfReader, PaperSize

from enum import Enum
class Typology(Enum):
    DOTGRID = 1
    GRAPH = 2
    LINED = 3
    
import sys
print ('argument list', sys.argv)
print ('argument len', len(sys.argv) )

if (len(sys.argv) < 2): 
  printUsage()
  exit(1)

typeInt = int(sys.argv[1])
numbInt = 53 # default to 52-53 weeks

# choosing the type of second page
input_dir_path_graph_src = "../notebooks/"
if (typeInt == 1): 
  input_dir_path_graph = "dotgridinteriorpages"
elif (typeInt == 2): 
  input_dir_path_graph = "graphinteriorpages"
elif (typeInt == 3): 
  input_dir_path_graph = "linedinteriorpages"
else: 
  print("Unknown first arg [", str(typeInt), "]")
  printUsage()
  exit(1)
  
# choosing the type of second page
input_dir_path = "./"
input_dir_path = "weeklyplannerinteriorpages"

input_final_path = "modele.pdf"
input_final_path_graph = "modele.pdf"
# setting output path (generate if not present)
output_path = input_dir_path + "_" + input_dir_path_graph + "_" + str(numbInt) + "_" + input_final_path

pdf_reader_graph = PdfReader(input_dir_path_graph_src + "/" + input_dir_path_graph + "/" + input_final_path_graph)
basicModelPageGraph = pdf_reader_graph.pages[0]

pdf_reader = PdfReader(input_dir_path + "/" + input_final_path)
basicModelPage = pdf_reader.pages[0]

pdf_writer = PdfWriter()
pdf_writer.add_metadata( pdf_reader.metadata )
pdf_writer.add_metadata({
	"/Author": "Gaby Wald",
	"/Producer": "Gaby Wald Script",
	"/Title": "Fuzion made by GabyWald's Script", 
	"/Creator" : "Python Script using PyPDF2"
})

for x in range( numbInt ):
  pdf_writer.add_page( basicModelPageGraph )
  pdf_writer.add_page( basicModelPage )
pdf_writer.add_page( basicModelPageGraph )

pdf_writer.write( output_path )
pdf_writer.close()
# pdf_reader.close()

print( "Final Number of pages: ", len(pdf_writer.pages) )
print( "GENERATED: ", output_path)
