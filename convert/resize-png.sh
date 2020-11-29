#!/bin/bash


echo -e "\e[2m  ======================================================================================="
echo -e "\e[2m  An image batch convert-for-web script using ImageMagick, RickOrchard 2017 \e[0m \n\n"

mkdir ./webconvert-png

for f in *.png
do
echo ""
echo -e -n "  Converting \e[1m $f:\e[0m  "
#printf "  q5-huge..." && convert "$f"  -quality 00 -strip -filter Lanczos -colorspace RGB -resize "3840x3840>" -unsharp 0x0.75+0.75+0.008 -colorspace sRGB "./webconvert-png/q5-${f}"
printf "  q4-large..." && convert "$f"  -quality 00 -strip -filter Lanczos -colorspace RGB -resize "1920x1920>" -unsharp 0x0.75+0.75+0.008 -colorspace sRGB "./webconvert-png/q4-${f}"
printf "  q3-medium..." && convert "$f"  -quality 00 -strip -filter Lanczos -colorspace RGB -resize "720x720>" -unsharp 0x0.75+0.75+0.008 -colorspace sRGB "./webconvert-png/q3-${f}"
printf "  q2-small..." && convert "$f"  -quality 00 -strip -filter Lanczos -colorspace RGB -resize "360x360>" -unsharp 0x0.75+0.75+0.008 -colorspace sRGB "./webconvert-png/q2-${f}"
printf "  q1-tiny..." && convert "$f"  -quality 00 -strip -filter Lanczos -colorspace RGB -resize "90x90>" -unsharp 0x0.75+0.75+0.008 -colorspace sRGB "./webconvert-png/q1-${f}"

if [[ $1 == "--rename" ]]
  then
    mv "$f" "qbase-${f}"
fi
done

echo -e "\n\n\n  \e[4mFinished!\e[0m \n\n\n"
