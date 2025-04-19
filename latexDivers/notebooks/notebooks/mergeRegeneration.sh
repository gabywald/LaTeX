#!/bin/bash

#-------------------------
# Description: Merging sample page of [dot|graph|lined] Interior Pages to same booklet (for more than one page). 
# Author: Gabriel Chandesris 
# Date Created: April 19, 2025
# Date Modified: April 19, 2025
# Version: 1.0.0
# License: GPL
#-------------------------

for type in 1 2 3; do
    # echo "${type}"
    for nbpages in 64 128 256; do
        # echo "${nbpages}"
        echo "${type} ${nbpages}"
    	echo "./mergeInteriorPages.py ${type} ${nbpages}"
	    ./mergeInteriorPages.py ${type} ${nbpages}
    done
done
