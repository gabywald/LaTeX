#!/bin/bash

#-------------------------
# Description: Merging sample page of [dot|graph|lined] Interior Pages to same booklet (for more than one page). 
# Author: Gabriel Chandesris 
# Date Created: May 14, 2025
# Date Modified: May 14, 2025
# Version: 1.0.0
# License: GPL
#-------------------------

for type in 1 2 3; do
    echo "${type}"
	echo "./mergeInteriorPagesDaily.py ${type} "
    ./mergeInteriorPagesDaily.py ${type} 
    echo "./mergeInteriorPagesWeekly.py ${type}
    ./mergeInteriorPagesWeekly.py ${type}  
    echo "./mergeInteriorPagesMonthly.py ${type} 
    ./mergeInteriorPagesMonthly.py ${type} 
done
