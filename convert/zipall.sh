#!/bin/bash

clear

# Define constants
scriptv="v1.00"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"zipall.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "                     Batch zip tool for folders.   Copyleft 2023 Veederlicht@Github"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"

# Test nr. of arguments
if [ $# -eq 0 ]
  then
    echo "        No source files specified."
	exit 2
fi

for f in "$@"
do
	if [[ -d $f ]]; then
	    echo -e "\n\n     ➢➢  Archief maken van map ${f}..."
	    zip -r -1 "$f".zip "$f"
	elif [[ -f $f ]]; then
	    echo -e "\n\n     ➢➢  Archief maken van bestand ${f}..."
	    zip -r -1 "$f".zip "$f"
	else
	    echo -e "\n\n     ➢➢  Geen geldig formaat: ${f}"
	fi
done

echo -e "\n\n  --------------------------------------------- END OF SCRIPT -------------------------------------------------------\n"

