#!/bin/bash

# User information to inject in metadata
m_composer=''
m_copyright='Copyleft RickOrchard@Github'
m_comment='Upscaled & Blended using Waifu2x/enfuse/exiv2'
m_title=''
m_year=''

clear

# Define constants
scriptv="v1.27"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"upblend.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "              An image batch-upscale-&-merge script, copyleft 2020 RickOrchard@Github"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"
echo -e "\n ${sYe}  NOTE: metadata will be injected, to change it edit this scriptheader!  ${sNo} \n\n"

# Test nr. of arguments
if [ $# -eq 0 ]
  then
    echo "        No source files specified."
	exit 2
fi

mkdir -p ./upscaled
mkdir -p ./blended


# !!!! ARGUMENTS IN DOUBLE QOUTES TO AVOID PROBLEMS WITH SPACES IN FILENAMES!!! https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
for f in "$@"
# for f in *.png
do

	## Uncomment one or more of the upscaling methods below

	## 1. IMAGEMAGICK, convert point generates the most detail but is better used with many exposure blends because of pixelated appearance
		echo -e "\n"
		echo -e -n "\e[0m »»» Upscaling using convert: \e[1m $f... \e[2m"
#		time convert "$f" -filter point -resize "200%" "PNG24:./upscaled/${f}.up_convert_point.png"
		time convert "$f" -sigmoidal-contrast 1x20% -sigmoidal-contrast 1x55% -modulate 100,85 -normalize -filter point -resize "200%" "./upscaled/${f}.up_convert_point.jpg"


	## 2. XBRZSCALE, enhanced edge upscaling
#		echo -e "\n"
#		echo -e "\e[0m »»» Upscaling using xbrzscale: \e[1m $f... \e[2m"
#		time xbrzscale 2 "$f" "./upscaled/${f}.up_xbrzscale.png"


	## 3. WAIFU2X, best overall (by far!)
		echo -e "\n"
		echo -e "\e[0m »»» Upscaling using waifu2x: \e[1m $f... \e[2m"
#		time waifu2x-ncnn-vulkan -i "$f" -o "./upscaled/${f}.up_waifu2x.png"
		time waifu2x-ncnn-vulkan -i "$f" -f jpg -n -1 -o "./upscaled/${f}.up_waifu2x.jpg"

	#if [[ $1 == "--rename" ]]
	#  then
	#    mv "$f" "qbase-${f}"
	#fi

done


## ALIGN_IMAGE_STACK, doesnt work for 360 photos
	#echo "\n"
	#echo -e "\e[0m »»» Aligning images using align_image_stack... \e[2m"
	#align_image_stack --gpu -a alligned.tiff -C *.png


## ENFUSE, blend all exposures together
	echo "\n"
	echo -e "\e[0m »»» Blending multiple exposures using enfuse... \e[2m"
	time enfuse --output="./blended/${f}#enfused.jpg" --compression=90 ./upscaled/*.jpg --verbose=0 --exposure-optimum=0.5 --exposure-width=0.1 --exposure-weight-function=gaussian
	#time enfuse --output="./blended/blend_enfuse-${f}.png" ./upscaled/*.png

## EXIV2, copy EXIF data to new file
	echo "\n"
	echo -e "\e[0m »»» Copying EXIF data to the new file... \e[2m"
	exiv2 rm "./blended/${f}#enfused.jpg"
	exiv2 -ea- "$f" | exiv2 -ia- "./blended/${f}#enfused.jpg"
	if [ $? -eq 0 ]
	then
		exiv2 -r':basename:_exif' "./blended/${f}#enfused.jpg"
	fi
	
#rm -Rf "./upscaled/*"


echo -e "\n\n\n  \e[4mFinished!\e[0m \n\n\n"
