#!/bin/bash

# User information to inject in metadata
m_composer=''
m_copyright='Copyleft RickOrchard@Github'
m_comment='Upscaled & Blended using Waifu2x/enfuse/exiv2'
m_title=''
m_year=''

clear

# Define constants
scriptv="v2.1"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"upblend.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "              An image batch-upscale-&-merge script, copyleft 2023 RickOrchard@Github"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"
echo -e "\n ${sYe}  NOTE: metadata will be injected, to change it edit this scriptheader!  ${sNo} \n\n"

# Test nr. of arguments
exitcode=0
if [ $# -eq 0 ]
then
	echo "        No source files specified."
	exit
fi
if ! command -v enfuse &> /dev/null
then
	echo "Essential program is not installed: enfuse"
	exit
fi
if ! command -v align_image_stack &> /dev/null
then
	echo "Essential program is not installed: align_image_stack"
	exit
fi
if ! command -v waifu2x-ncnn-vulkan &> /dev/null
then
	echo "Essential program is not installed: waifu2x-ncnn-vulkan"
	exit
fi
if ! command -v exiv2 &> /dev/null
then
	echo "Essential program is not installed: exiv2"
	exit
fi


# »»»»»»»»»»»»»»»»»» DIALOG
echo -e ""
read -p "      Enter the size of each image stack:" answer_size
echo -e ""
if ! [[ "$answer_size" =~ ^[0-9]+$ ]]; then
	echo -e "    ERROR:  Enter whole numbers only, exiting...."
	exit
fi

echo -e ""
read -p "      Upscale (2x) resulting images? [y/n]:" answer_upscale
echo -e ""
if [ $answer_upscale = "y" ]; then
	echo -e "    ...upscaling selected."
else
	echo -e "    ...skip upscaling."
fi


# »»»»»»»»»»»»»»»»»» EXECUTION
iStart=$(date +%s)
usdir=./upblend.d
tmpdir=$usdir/0.tmp
blenddir=$usdir/1.blended
scaledir=$usdir/2.scaled
rm -Rf $usdir
mkdir -p $tmpdir
mkdir -p $blenddir
mkdir -p $scaledir

echo -e "\n \e[0m      »»» Blending multiple exposures using enfuse... \e[2m \n"

count=0
for f in "$@"
do
	((count++))
echo -e "-------$f"
	cp "$f" $tmpdir/
	if [ $count -eq $answer_size ]
	then
		align_image_stack --gpu -i -d -C -v -a "${tmpdir}/"aligned "${tmpdir}/"*
		outfile="${blenddir}/${f}#enfused.jpg"
		enfuse --compression=90 --verbose=0 --exposure-weight-function=gaussian --output="${outfile}" "${tmpdir}/"*.tif
		exiv2 rm "${outfile}"
		exiv2 -ea- "$f" | exiv2 -ia- "${outfile}"
		if [ $? -eq 0 ]
		then
			exiv2 -r':basename:_exif' "${outfile}"
		fi
		rm -f "${tmpdir}/"*
		count=0
	fi

done


if [ $answer_upscale = "y" ]; then
# UPSCALE, nog aanpassen naar brondirectory, evt EXIF kopieren
	for f in "${blenddir}/"*
	do
		infile=$(basename -- "${f}")
		outfile="${scaledir}/${infile}#w2x.jpg"
		echo -e "\e[0m »»» Upscaling using waifu2x: \e[1m $infile... \e[2m"
		waifu2x-ncnn-vulkan -i "$f" -s 2 -f jpg -o "${outfile}"
		exiv2 rm "${outfile}"
		exiv2 -ea- "$f" | exiv2 -ia- "${outfile}"
		if [ $? -eq 0 ]
		then
			exiv2 -r':basename:_exif' "${outfile}"
		fi
	done
fi

iEnd=$(date +%s)
echo -e "\n \e[0m »»» Total processing time: $((iEnd-iStart)) seconds \e[2m"
echo -e "\n\n \e[4mFinished!\e[0m \n\n\n"

# !!!! ARGUMENTS IN DOUBLE QOUTES TO AVOID PROBLEMS WITH SPACES IN FILENAMES!!! https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
# !!!! In order to make use of the wildcard I need to leave * outside of the quotes  https://stackoverflow.com/questions/50354995/bash-wildcard-working-in-command-line-but-not-script
