#!/bin/bash

clear
echo -e "\e[2m  =============================================================================================="
echo -e "\e[2m      An image colorizing batch script using DeepAI.org, RickOrchard 2020, no copyright"
echo -e "\e[2m  -----------------------------------------v1.0-------------------------------------------------"
echo -e "\n\n"

	out1="./"

# ...



	echo "Batch deinterlace script - output"  > "${out1}"colorize.rep
	date  >> "${out1}"colorize.rep
	echo -e "+++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> "${out1}"colorize.rep
	

	for f in *.jpg
	do

		echo "    Processing ${f}..."
		echo -e "\n\n\n  ⟹  PROCESSING  ${f}:" >> "${out1}"colorize.rep

# ...

	done


	echo -e "\n\n\n+++++++++++++++++++++++++++++++++++++++++++" >> "${out1}"colorize.rep
	echo "   BATCH FINISHED"  >> "${out1}"colorize.rep
	date  >> "${out1}"colorize.rep

echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n"
