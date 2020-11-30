#!/bin/bash

if [ $# != 1 ]
  then
    echo "Invalid arguments supplied. Input should be 'viddis.sh inputfile'"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "$1 is not an existing file."
    exit 2
fi


clear
echo -e "\e[2m  =============================================================================================="
echo -e "\e[2m      A video dismembering batch script using ffmpeg, RickOrchard 2020, no copyright"
echo -e "\e[2m  -----------------------------------------v1.1-------------------------------------------------"
echo -e "\n\n"
	
	base1="./${1}.dir/"
	rm -Rf "${base1}"
	mkdir -p "${base1}"
	out_i="${base1}ext_i/"
	mkdir -p "${out_i}"
	log1="viddis.rep"
	out_a="${base1}ext_a/"
	mkdir -p "${out_a}"
	out_m="${base1}ext_m/"
	mkdir -p "${out_m}"
	
# ...

	read -p "Extract images to JPG or PNG (j/p): " answer1

	case $answer1 in
	  "p")
		arg3=".png"
		;;
	  "j")
		arg3=".jpg"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac

# ...
	
	echo -e "\n\nScale and correct aspect ratio of images?"
	echo -e "    [0] none, keep video aspect and resolution"
	echo -e "    [1] 1.361/576p (Double 8mm original)"
	echo -e "    [2] 1.441/576p (Super 8mm original)"
	echo -e "    [3] HD/720p"
	echo -e "    [4] FullHD/1080p"
	echo -e "    [5] UHD/2160p"
	read -p "(0-5): " answer1


	case $answer1 in
	  0)
		arg2=""
		;;
	  1)
		arg2="scale=784x576,setdar=dar=1.361"
		;;
	  2)
		arg2="scale=830x576,setdar=dar=1.441"
		;;
	  3)
		arg2="scale=1280x720,setdar=dar=1.778"
		;;
	  4)
		arg2="scale=1920x1080,setdar=dar=1.778"
		;;
	  5)
		arg2="scale=3840x2160,setdar=dar=1.778"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 4
		;;
	esac

# ...

	read -p "Deinterlace? (y/n): " answer1

	case $answer1 in
	  "y")
		arg1="yadif"
	  	if [[ $arg2 != "" ]]
		  then
			arg1="${arg1},"
		fi
		;;
	  "n")
		arg1=""
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac

# ...

	arg1="${arg1}${arg2}"

	if [[ $arg1 != "" ]]
	  then
	  	arg1="-vf ${arg1}"
	fi

# ...

	read -p "Extract audio to FLAC or ORIGINAL (f/o): " answer1

	case $answer1 in
	  "f")
		arg4="-vn -acodec flac ${out_a}${1}.flac"
		;;
	  "o")
		arg4="-vn -acodec copy ${out_a}${1}.mka"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 6
		;;
	esac

# ...


	echo -e "\n\nCreating logfile (${base1}${log1})\n\n"
	echo "Batch Image Extraction script - output"  > "${base1}${log1}"
	date  >> "${base1}${log1}"
	echo -e "+++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> "${base1}${log1}"
	

# ...

		echo -e "\n\n    Extracting metadata from ${1}..."
		echo -e "\n\n  ⟹  PROCESSING METADATA ${1}:" >> "${base1}${log1}"
		ffprobe -i "${1}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format flat > "${out_m}${1}.flat"
		ffprobe -i "${1}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format json > "${out_m}${1}.json"
		ffprobe -i "${1}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format ini > "${out_m}${1}.ini"
#-loglevel repeat+level+verbose -i

		echo -e "\n\n    Extracting audio from ${1}..."
		echo -e "\n\n  ⟹  PROCESSING AUDIO ${1}:" >> "${base1}${log1}"
		ffmpeg -i ${1} ${arg4} 2>> "${base1}${log1}"
		
		echo -e "\n\n    Extracting video from ${1}..."
		echo -e "\n\n  ⟹  PROCESSING VIDEO ${1}:" >> "${base1}${log1}"
		echo "ffmpeg -i ${1} ${arg1} -qscale:v 3 ${out_i}${1}_%04d${arg3}"


# ...

	echo -e "\n\n\n+++++++++++++++++++++++++++++++++++++++++++" >> "${base1}${log1}"
	echo "   BATCH FINISHED"  >> "${base1}${log1}"
	date  >> "${base1}${log1}"

echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n"
