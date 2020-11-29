#!/bin/bash

clear
echo -e "\e[2m  =============================================================================================="
echo -e "\e[2m      An image batch deinterlace script using ffmpeg, RickOrchard 2020, no copyright"
echo -e "\e[2m  -----------------------------------------v1.0-------------------------------------------------"
echo -e "\n\n"

	base1="./"

	read -p "Output to separate directory? (y/n): " answer1

	if [[ $answer1 == "y" ]]
	  then
		mkdir -p ./out_deint
		base1="./out_deint/"
	fi

	echo "Batch deinterlace script - output"  > "${base1}"deint.rep
	date  >> "${base1}"deint.rep
	echo -e "+++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> "${base1}"deint.rep
	

	for f in *.jpg
	do

		echo "    Processing ${f}..."
		echo -e "\n\n\n  ⟹  PROCESSING  ${f}:" >> "${base1}"deint.rep

		## De-interlace
		ffmpeg -loglevel repeat+level+verbose -i "$f" -vf yadif  -qscale:v 3 ${base1}${f}_yadif.jpg -y 2>> "${base1}"deint.rep

	done


	echo -e "\n\n\n+++++++++++++++++++++++++++++++++++++++++++" >> "${base1}"deint.rep
	echo "   BATCH FINISHED"  >> "${base1}"deint.rep
	date  >> "${base1}"deint.rep

echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n"
