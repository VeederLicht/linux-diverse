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


# Define constants
scriptv="v2.0.0"



clear
echo -e "\e[2m  =============================================================================================="
echo -e "\e[2m      A video dismembering batch script using ffmpeg, RickOrchard 2020, no copyright"
echo -e "\e[2m  -----------------------------------------$scriptv-------------------------------------------------"
echo -e "\n\n"
	

# ... paths definition

	logfile="viddis.rep"

	base1="./${1}.dir/"
	rm -Rf "${base1}"
	mkdir -p "${base1}"
	
	out_i="${base1}extract_i/"
	mkdir -p "${out_i}"
	
	out_a="${base1}extract_a/"
	mkdir -p "${out_a}"
	
	out_m="${base1}extract_m/"
	mkdir -p "${out_m}"
	
	

# ... picture quality
  

	echo -e "Extract images to normal or high quality:"
	echo -e "    [0] normal"
	echo -e "    [1] high"
	read -p "(0-1): " answer1

	case $answer1 in
	  "0")
		arg3="-q:v 5 ${out_i}${1}_%05d.jpg"
		;;
	  "1")
		arg3="-q:v 2 ${out_i}${1}_%05d.jpg"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac


# ... aspect ratio
    
    clear
    echo -e "\n\n"

	echo -e "Current pixel resolution and display aspect ratio are:"
	ffprobe -i "$1" -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio -of csv=s=,:p=0:nk=0

	echo -e "Set visual aspect ratio for this video:"
	echo -e "    [0] raw output (might not be the correct display-aspect-ratio)"
	echo -e "    [1] 4:3    (old TV)"
	echo -e "    [2] 11:8   (8mm film)"
	echo -e "    [3] 3:2    (Super8 film)"
	echo -e "    [4] 16:9   (HD)"
	echo -e "    [5] 18:9   (Univisium)"
	read -p "(0-5): " answer1


	case $answer1 in
	  0)
		arg2=""
		;;
	  1)
		arg2="scale=ih*(4/3):ih:sws_flags=lanczos,"
		;;
	  2)
		arg2="scale=ih*(11/8):ih:sws_flags=lanczos,"
		;;
	  3)
		arg2="scale=ih*(3/2):ih:sws_flags=lanczos,"
		;;
	  4)
		arg2="scale=ih*(16/9):ih:sws_flags=lanczos,"
		;;
	  5)
		arg2="scale=ih*(18/9):ih:sws_flags=lanczos,"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 4
		;;
	esac



# ... Superscale images

    clear
    echo -e "\n\n"
	echo -e "Superscale images (2x):"
	echo -e "    [0] no"
	echo -e "    [1] Super2xsai"
	echo -e "    [2] xbr"
	read -p "(0-2): " answer1

	case $answer1 in
	  "0")
		arg6=""
		;;
	  "1")
		arg6="super2xsai,"
		;;
	  "2")
		arg6="xbr=n=2,"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac




# ... Interpolate framerate

    clear
    echo -e "\n\n"

	echo -e "Current video framerate is:"
	ffprobe -i "$1" -v fatal -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=s=,:p=0:nk=0

	echo -e "Interpolate to desired framerate:"
	echo -e "    [0] no"
	echo -e "    [1] 50 fps"
	echo -e "    [2] 60 fps"
	read -p "(0-2): " answer1

	case $answer1 in
	  "0")
		arg7=""
		;;
	  "1")
		arg7="minterpolate=fps=50:mi_mode=mci:me_mode=bidir:mc_mode=aobmc:me=umh,"
		;;
	  "2")
		arg7="minterpolate=fps=60:mi_mode=mci:me_mode=bidir:mc_mode=aobmc:me=umh,"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac


# ... deinterlace
    
    clear
    echo -e "\n\n"
	echo -e "Deinterlace:"
	echo -e "    [0] no"
	echo -e "    [1] yadif"
	echo -e "    [2] bwdif"
	read -p "(0-2): " answer1

	case $answer1 in
	  "0")
		arg1=""
		;;
	  "1")
		arg1="yadif,"
		;;
	  "2")
		arg1="bwdif,"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac



# ... select deblocking
    
    clear
    echo -e "\n\n"
    echo -e "Note: in order for deinterlacing to work properly on very grainy footage, it might help to deblock the footage."
    echo -e ""
    echo -e "     (0) None"
    echo -e "     (1) Low (high quality, slow)"
    echo -e "     (2) Medium (fast)"
    echo -e "     (3) High"
    echo -e "     (4) Extreme (very slow)"
    echo -e ""
    read -p "       Select deblocking/denoising level: " deblock
    echo -e ""

    case $deblock in
      "0")
	    arg5=""
	    ;;
      "1")
        echo -e "  -----------------Low strength deblocking \n" >> $logfile
	    arg5="bm3d=sigma=3,"
	    ;;
	    "2")
        echo -e "  -----------------Medium strength deblocking/denoising \n" >> $logfile
	    arg5="spp=2:1:mode=soft,"
	    ;;
	    "3")
        echo -e "  -----------------High strength deblocking/denoising \n" >> $logfile
	    arg5="spp=3:2:mode=soft,"
	    ;;
	    "4")
        echo -e "  -----------------Extreme strength deblocking/denoising \n" >> $logfile
	    arg5="spp=4:3:mode=soft,"
	    ;;
      *)
	    echo "Unknown option, exiting..."
	    exit 3
	    ;;
    esac



# ... extract audio

    clear
    echo -e "\n\n"
	echo -e "Extract audio:"
	echo -e "    [0] original"
	echo -e "    [1] FLAC"
	read -p "(0-1): " answer1

	case $answer1 in
	  "0")
		arg4="-vn -acodec copy ${out_a}${1}.mka"
		;;
	  "1")
		arg4="-vn -acodec flac -compression_level 3 ${out_a}${1}.flac"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 6
		;;
	esac


# ... RUN!

	echo -e "\n\nCreating logfile (${base1}${logfile})\n\n"
	echo "Batch Image Extraction script - output"  > "${base1}${logfile}"
	date  >> "${base1}${logfile}"
	echo -e "+++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> "${base1}${logfile}"
	

# ... metadata

		echo -e "\n\n    Extracting metadata from ${1}..."
		echo -e "\n\n  ⟹  PROCESSING METADATA ${1}:" >> "${base1}${logfile}"
		ffprobe -i "${1}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format flat > "${out_m}${1}.flat"
		ffprobe -i "${1}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format json > "${out_m}${1}.json"
		ffprobe -i "${1}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format ini > "${out_m}${1}.ini"


# ... audio

		echo -e "\n\n    Extracting audio from ${1}..."
		echo -e "\n\n  ⟹  PROCESSING AUDIO ${1}:" >> "${base1}${logfile}"
		ffmpeg -y -hide_banner -loglevel repeat+level+verbose -i ${1} ${arg4} 2>> "${base1}${logfile}"


# ... images		
		
		echo -e "\n\n    Extracting video from ${1}..."
		fcount1=`ffprobe -v fatal -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 ${1}`
		echo -e "\n\n  ⟹  PROCESSING VIDEO ${1} (${fcount1} frames):" >> "${base1}${logfile}"
		echo -e "\n Number of frames to be extracted: ${fcount1}"
		ffmpeg -y -hide_banner -i ${1} -vf ${arg5}${arg1}${arg7}${arg2}${arg6}setsar=sar=1/1 ${arg3}

# ... finish up

	echo -e "\n\n\n+++++++++++++++++++++++++++++++++++++++++++" >> "${base1}${logfile}"
	echo "   BATCH FINISHED"  >> "${base1}${logfile}"
	date  >> "${base1}${logfile}"

echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n"
