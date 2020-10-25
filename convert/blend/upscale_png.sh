#!/bin/bash

clear
echo -e "\e[2m  ============================================================================================"
echo -e "\e[2m      An image batch upscale script using different tools, RickOrchard 2020, no copyright"
echo -e "\e[2m  --------------------------------------------------------------------------------------------"
echo -e "\n\n"

mkdir -p ./upscaled
mkdir -p ./blended

for f in *.png
do

## Select one of the 2 upscaling methods below, or both for even better detail

## 1. IMAGEMAGICK, convert point generates the most detail but is better used with exposure blends because of pixelated appearance
#echo -e "\n"
echo -e "\e[0m »»» Upscaling using convert: \e[1m $f... \e[2m"
time convert "$f" -filter point -resize "300%" "PNG24:./upscaled/${f}.up_convert_point.png"


## 2. XBRZSCALE, best for non-stacked images
echo -e "\n"
echo -e "\e[0m »»» Upscaling using xbrzscale: \e[1m $f... \e[2m"
time xbrzscale 3 "$f" "./upscaled/${f}.up_xbrzscale.png"


#if [[ $1 == "--rename" ]]
#  then
#    mv "$f" "qbase-${f}"
#fi

done


echo "\n"
echo -e "\e[0m »»» Blending multiple exposures using enfuse... \e[2m"
time enfuse --output="./blended/blend_enfuse-${f}.jpg" --compression=100 ./upscaled/*.png --verbose=0
#time enfuse --output="./blended/blend_enfuse-${f}.png" ./upscaled/*.png

echo "\n"
echo -e "\e[0m »»» Copying EXIF data to the new file... \e[2m"
exiv2 rm "./blended/blend_enfuse-${f}.jpg"
exiv2 -ea- "$f" | exiv2 -ia- "./blended/blend_enfuse-${f}.jpg"
#rm -Rf "./upscaled/*"

echo -e "\n\n\n  \e[4mFinished!\e[0m \n\n\n"
