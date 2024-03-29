#!/bin/bash


####################  CHECK RUNCONDITIONS  ###############################
if [[ $# -eq 0 ]]	# Test nr. of arguments
  then
    echo "        No source files specified."
	exit 2
fi



####################  INITIALISATION & DEFINITIONS  ############################
# Define constants
scriptv="v1.1"
sYe="\e[93m"
sNo="\033[1;35m"

	clear
	echo -e "\n ${sNo}"
	echo -e "  ===========================================ppconv================================================="
	echo -e "                Quick script for testing batch commands, RickOrchard 2023, no copyright"
	echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------\n\n"


for f in "$@"
do
    ffmpeg -hwaccel cuda \
    -i "$f" \
    -c:v h264_nvenc -coder:v cabac -profile:v high \
    -level:v auto -rc-lookahead:v 32 -refs:v 16 -spatial-aq true \
    -bf:v 3 -b_ref_mode:v middle -qp 26 \
    "$f".cuda.mp4 -y
done


    #-filter:v hwupload_cuda,scale_cuda=-2:1440 \

# working opencl example (ffmpeg complains about invalid output format without the format specifier in the filters)
# ffmpeg -init_hw_device opencl=gpu -filter_hw_device gpu -i testvideo2.original.m4v -vf "hwupload, nlmeans_opencl, hwdownload, format=yuv420p" opencl.mp4 -y
