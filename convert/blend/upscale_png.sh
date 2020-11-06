#!/bin/bash

clear
echo -e "\e[2m  ==============================================================================================="
echo -e "\e[2m      An image batch-upscale-&-merge script using different tools, RickOrchard 2020, no copyright"
echo -e "\e[2m  -----------------------------------------v1.05-------------------------------------------------"
echo -e "\n\n"

mkdir -p ./upscaled
mkdir -p ./blended

for f in *.png
do

	## Uncomment one or more of the upscaling methods below

	## 1. IMAGEMAGICK, convert point generates the most detail but is better used with many exposure blends because of pixelated appearance
#		echo -e "\n"
#		echo -e -n "\e[0m »»» Upscaling using convert: \e[1m $f... \e[2m"
#		time convert "$f" -filter point -resize "200%" "PNG24:./upscaled/${f}.up_convert_point.png"


	## 2. XBRZSCALE, enhanced edge upscaling
#		echo -e "\n"
#		echo -e "\e[0m »»» Upscaling using xbrzscale: \e[1m $f... \e[2m"
#		time xbrzscale 2 "$f" "./upscaled/${f}.up_xbrzscale.png"


	## 3. WAIFU2X, best overall (by far!)
		echo -e "\n"
		echo -e "\e[0m »»» Upscaling using waifu2x: \e[1m $f... \e[2m"
		time waifu2x-ncnn-vulkan -i "$f" -o "./upscaled/${f}.up_waifu2x.png"

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
	time enfuse --output="./blended/${f}#enfused.jpg" --compression=100 ./upscaled/*.png --verbose=0
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
