#!/bin/bash

clear


# Define text styles
sYe="\e[93m"
sNo="\e[36m"


# Show banner
echo -e "\n ${sYe}"
echo -e "  ============================================================================"
echo -e "  An image2WEBP conversion script using ffmpeg, RickOrchard 2021, no copyright"
echo -e "  ------------------------------ v1.1 ----------------------------------------"
echo -e "${sNo}"


# Set arguments
    i="jpg"
    r=99999
    q=85
    x="-map_metadata -1"  # by default, DONT copy metadata/exif
    
    while getopts ":i:r:q:x:" opt; do
      case $opt in
        #i) i="${OPTARG:-jpg}"   # If i not set or null, use default
        i) i=$OPTARG
           echo "    file-type=${i}"
        ;;
        r) r=$OPTARG
           echo "    resolution=${r}"
        ;;
        q) q=$OPTARG
           echo "    quality=${q}"
        ;;
        x) x="-map_metadata 0"
           echo "    keep-metadata=yes"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
      esac
    done


# Execute
	echo "WEBP batch conversion script - output"  > 2webp.rep
	date  >> 2webp.rep
	echo -e "+++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> 2webp.rep
	
    echo -e "\n"

	for f in *.$i
	do

		echo "    Processing ${f}..."
		echo -e "\n\n\n  ⟹  PROCESSING  ${f}:" >> 2webp.rep

		## De-interlace
		ffmpeg -loglevel repeat+level+verbose -i "${f}" -vf "spp=4:6,bm3d=sigma=2,scale=w='min(iw,$r)':h='min(ih,$r)':force_original_aspect_ratio=decrease,unsharp=3:3:0.5" $x -q:v $q "${f}.webp" -y 2>> 2webp.rep

	done


	echo -e "\n\n\n+++++++++++++++++++++++++++++++++++++++++++" >> 2webp.rep
	echo "   BATCH FINISHED"  >> 2webp.rep
	date  >> 2webp.rep


echo -e "\n\n\n  ${sYe} Finished \e[5m              ´jpeg is outdated, please stop using it...´ \e[0m \n\n\n"
