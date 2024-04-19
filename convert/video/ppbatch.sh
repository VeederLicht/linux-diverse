#!/bin/bash


####################  CHECK RUNCONDITIONS  ###############################
if [[ $# -eq 0 ]]	# Test nr. of arguments
  then
    echo "        No source files specified."
	exit 2
fi



####################  INITIALISATION & DEFINITIONS  ############################
# Define constants
scriptv="v1.2"
sYe="\e[93m"
sNo="\033[1;35m"

	clear
	echo -e "\n ${sNo}"
	echo -e "  ===========================================ppconv================================================="
	echo -e "                Quick script for running batch commands, RickOrchard 2023, no copyright"
	echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------\n\n"


for f in "$@"
do
ffmpeg \
 -i "$f" \
 -init_hw_device vaapi=va:/dev/dri/renderD128 \
  -c:v av1_qsv \
  -preset medium \
  -global_quality:v 25 \
  -look_ahead_depth 40 \
  -extbrc 1 \
  -low_power 0 \
  -adaptive_i 1 \
  -adaptive_b 1 \
  -b_strategy 1 \
  -bf 7 \
 -forced_idr 1 \
 -af loudnorm \
 -c:a libopus \
 -b:a 128K \
 "$f".1080p.av1.mp4 -y
done

#  -b:v 600K \
#  -bufsize 2M \
#  -rc_init_occupancy 512K \



#ffmpeg \
#  -i "$f" \
#  -init_hw_device vaapi=va:/dev/dri/renderD128 \
#  -c:v av1_qsv \
#  -preset veryslow \
#  -extbrc 1 \
#  -global_quality 25 \
#  -look_ahead 1 \
#  -look_ahead_depth 40 \
#  -low_power 0 \
#  -adaptive_i 1 \
#  -adaptive_b 1 \
#  -b_strategy 1 \
#  -bf 7 \
# -filter:a loudnorm \
 # -b:a 128K \
 # "$f".av1.mp4 -y
