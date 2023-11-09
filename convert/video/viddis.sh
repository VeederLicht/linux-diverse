#!/bin/bash
# !!!! ARGUMENTS IN DOUBLE QOUTES TO AVOID PROBLEMS WITH SPACES IN FILENAMES!!! https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
clear

# Define constants
scriptv="v2.8.0-beta"
sYe="\e[93m"
sNo="\033[1;35m"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ========================================================VIDDIS==========================================================="
echo -e "	 A video conversion and dissection batch script using ffmpeg, RickOrchard 2020, no copyright"
echo -e "       -----------------------------------------------${sYe} $scriptv ${sNo}-------------------------------------------------"


################ CHECK RUNCONDITIONS ###################################
if [ $# -eq 0 ]	# Test nr. of arguments
then
	echo "	  No source files specified."
	exit 2
fi

# List files selected for input
echo -e "\n\n   INPUT FILES:\n"
nFiles=0
for f in "$@"; do
	echo -e "	✻ ${f}"
	((nFiles++))
done
echo -e "\n   TOTAL COUNT: ${nFiles}\n\n"



################ FUNCTION DEFINITIONS ###################################
selection=""
function ask_convert_quality {		# ... picture quality
	clear
	echo -e "\n\n"
	echo -e "Convert video to:"
	echo -e "	[0]	H264 Editing Quality		(m4v, high bitrate)"
	echo -e "	[1]	H264 Good Quality		(mp4)"
	echo -e "	[2]	H264 Low Quality		(mp4)"
	echo -e "	[3]	AV1 Good Quality		(mp4)"
	echo -e "	[4]	AV1 Low Quality			(mp4)"
	echo -e "	[5]	H264 Good Quality (NVENC)	(mp4)"
	echo -e "	[6]	H265 Good Quality (NVENC)	(mp4)"
	read -p "Your selection: " answer1

	case $answer1 in
		"0")
			selection+="    -H264 Editing Quality \n"
			outvid="-c:v libx264 -preset:v slow -profile:v high -tune grain -crf 18 -forced-idr true -c:a aac -b:a 384k"
			outext="h264.m4v"
			o_fl="-movflags frag_keyframe+empty_moov"
			;;
		"1")
			selection+="   -H264 Good Quality \n"
			outvid="-c:v libx264 -preset:v slow -profile:v high -crf 26 -c:a aac -b:a 256k"
			outext="h264.mp4"
			o_fl="-movflags +faststart"
			;;
		"2")
			selection+="   -H264 Low Quality \n"
			outvid="-c:v libx264 -preset:v medium -crf 32 -c:a aac -b:a 128k"
			outext="h264.mp4"
			o_fl="-movflags +faststart"
			;;
		"3")
			selection+="   -AV1 Good Quality \n"
			outvid="-c:v libsvtav1 -b:v 0 -qp 32 -preset 7 -c:a libopus -b:a 96k"
			outext="av1.mp4"
			o_fl=""
			;;
		"4")
			selection+="   -AV1 Low Quality \n"
			outvid="-c:v libsvtav1 -qp 37 -preset 7 -c:a libopus -b:a 64k"
			outext="av1.mp4"
			o_fl=""
			;;
		"5")
			selection+="   -H264 Good Quality (NVENC)\n"
			outvid="-gpu 0 -c:v h264_nvenc -preset slow -profile:v high -cq 25 -c:a aac -b:a 192k"
			outext="h264.mp4"
			o_fl="-movflags +faststart"
			;;
		"6")
			selection+="   -H265 Good Quality (NVENC)\n"
			outvid="-gpu 0 -c:v hevc_nvenc -preset slow -tier high -cq 27 -c:a aac -b:a 192k"
			outext="h265.mp4"
			o_fl="-movflags +faststart"
			;;
		*)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac
}

function ask_meta_comment {		# ... metadata
	clear
	echo -e "\n\n"
	echo -e "Insert metadata comment?  (optional, may be left blank)"
	read -p "» " m_comment
	if [ -z "$m_comment" ]
		then
			m_comment='Converted with viddis.sh (RickOrchard@Github)'
	fi
}

function ask_file_append {		# append slug to filename
		clear
	echo -e "\n\n"
	echo -e "Append text to converted filenames?  (optional, may be left blank)"
	read -p "» " f_slug
	if [ -z "$f_slug" ]
		then
			f_slug='viddis'
	fi
}


function ask_extract_video {	  # ... picture quality
	clear
	echo -e "Extract video stream to:"
		echo -e "	[0] JGP	(normal quality)"
		echo -e "	[1] JGP	(high quality)"
		echo -e "	[2] MKV	(original, no audio)"
		read -p "(Your selection: " answer1

		case $answer1 in
		"0")
			f_img="-an -q:v 5"
		outext="jpg"
		o_fl=""
			;;
		"1")
			f_img="-an -q:v 2"
		outext="jpg"
		o_fl=""
			;;
		"2")
			f_img="-an -c:v copy"
		outext="mkv"
		o_fl=""
			;;
		*)
			echo "Invalid answer, exiting..."
			exit 3
			;;
		esac
}

function ask_aspect_ratio { 		# ... aspect ratio
	clear
	echo -e "\n\n"
	echo -e "Current pixel resolution and display aspect ratio are:${sYe}"
	ffprobe -i "$1" -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio -of csv=s=,:p=0:nk=0
	echo -e "${sNo}Stretch / Resize video:"
	echo -e "	[0] none		(pixel-AR may not equal display-AR)"
	echo -e "	[1] stretch 4:3			(old TV)"
	echo -e "	[2] stretch 11:8		(8mm film)"
	echo -e "	[3] stretch 3:2			(Super8 film)"
	echo -e "	[4] stretch 16:9		(HD)"
	echo -e "	[5] stretch 18:9		(Univisium)"
	echo -e "	[6] Resize 270p			(no aspect change)"
	echo -e "	[7] Resize 540p			(no aspect change)"
	echo -e "	[8] fixed 1080p 16:9	(HD)"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	  ""|0)
		f_ar=""
		;;
	  1)
		f_ar="scale=ih*(4/3):ih,"
		;;
	  2)
		f_ar="scale=ih*(11/8):ih,"
		;;
	  3)
		f_ar="scale=ih*(3/2):ih,"
		;;
	  4)
		f_ar="scale=ih*(16/9):ih,"
		;;
	  5)
		f_ar="scale=ih*(18/9):ih,"
		;;
	  6)
		f_ar="scale=-2:270,"
		;;
	  7)
		f_ar="scale=-2:540,"
		;;
	  8)
		f_ar="scale=1920:1080,"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 4
		;;
	esac
}

function ask_resolution {		# ... Resolution
	clear
	echo -e "\n\n"
	echo -e "Superscale resolution (2x):"
	echo -e "	[0] no"
	echo -e "	[1] super2xsai"
	echo -e "	[2] xbr"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	  ""|0)
		f_ss=""
		;;
	  "1")
		f_ss="super2xsai,"
		;;
	  "2")
		f_ss="xbr=n=2,"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac
}

function ask_framerate {		# ... Framerate
	clear
	echo -e "\n\n"
	echo -e "Interpolate to desired framerate:"
	echo -e "	[0] no"
	echo -e "	[1] 50 fps"
	echo -e "	[2] 60 fps"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	""|0)
		f_fr=""
		;;
	"1")
		f_fr="minterpolate=fps=50:mi_mode=mci:me_mode=bidir:mc_mode=aobmc:me=umh,"
		;;
	"2")
		f_fr="minterpolate=fps=60:mi_mode=mci:me_mode=bidir:mc_mode=aobmc:me=umh,"
		;;
	*)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac
}

function ask_deinterlace { 		# ... deinterlace
	clear
	echo -e "\n\n"
	echo -e "Deinterlace input video:"
	echo -e "	[0] no"
	echo -e "	[1] yadif  (frame per FRAME, default)"
	echo -e "	[2] yadif  (frame per FIELD)"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	""|0)
		f_di=""
		;;
	"1")
		f_di="yadif=mode=0,"
		;;
	"2")
		f_di="yadif=mode=1,"
		;;
	*)
		echo "Invalid answer, exiting..."
		exit 5
		;;
	esac
}

function ask_deblock {		# ... select deblocking
	clear
	echo -e "\n\n"
	echo -e "Select deblocking/denoising of the input video:"
	echo -e "(Note: in order for deinterlacing to work properly on very compressed footage, deblocking might help)"
	echo -e ""
	echo -e "	[0) None"
	echo -e "	[1) Light\t   (fast)"
	echo -e "	[2) Medium"
	echo -e "	[3) Strong"
	echo -e "	[4) Very strong   (slow)"
	echo -e ""
	read -p "Your selection: " deblock
	echo -e ""

	case $deblock in
	""|0)
		f_db=""
		;;
	"1")
		f_db="pp=default/tmpnoise|1|2|3,"
		;;
	"2")
		f_db="spp=2:1:mode=soft,"
		;;
	"3")
		f_db="spp=3:2:mode=soft,"
		;;
	"4")
		f_db="spp=5:4:mode=soft,"
		;;
	*)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
}

function ask_enhance_image {		# ... select sharpening/contrast
	clear
	echo -e "\n\n"
	echo -e "Select sharpening/contrast of the input video:"
	echo -e ""
	echo -e "	[0) None"
	echo -e "	[1) Light"
	echo -e "	[2) Medium"
	echo -e "	[3) Strong"
	echo -e "	[4) Very strong"
	echo -e ""
	read -p "Your selection: " deblock
	echo -e ""

	case $deblock in
	""|0)
		f_sh=""
		;;
	"1")
		f_sh="unsharp=3:3:0.1,"
		;;
	"2")
		f_sh="unsharp=3:3:0.3,unsharp=5:5:0.1,"
		;;
	"3")
		f_sh="unsharp=3:3:0.3,unsharp=5:5:0.1,eq=contrast=1.01,"
		;;
	"4")
		f_sh="unsharp=3:3:0.5,unsharp=5:5:0.3,eq=contrast=1.01,"
		;;
	*)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
}

function ask_enhance_audio {		# ... enhance audio
	clear
	echo -e "\n\n"
	echo -e "Apply audio crystalizer:"
	echo -e "	[0] no"
	echo -e "	[1] yes"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	""|0)
		f_cr=""
		;;
	"1")
		f_cr="-af crystalizer"
		;;
	*)
		echo "Invalid answer, exiting..."
		exit 6
		;;
	esac
}

function ask_stabilize {			# ... select length
	clear
	echo -e "\n\n"
	echo -e "Stabilize the footage:"
	echo -e "	[0] No"
	echo -e "	[1] Yes"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	""|0)
			f_st=""
		;;
	"1")
			f_st="vidstabtransform,"
		;;
	*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
}

function ask_length {			# ... select length
	clear
	echo -e "\n\n"
	echo -e "Select processing length:"
	echo -e "	[0] Full video length"
	echo -e "	[1] Short preview   (10s)"
	echo -e "	[2] Long preview   (2m)"
	echo -e ""
	read -p "Your selection: " answer1

	case $answer1 in
	""|0)
		o_ln=""
		;;
	"1")
		o_ln="-ss 00:15 -t 10"
		;;
	"2")
		o_ln="-t 120"
		;;
	*)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
}

################## RUN PROGRAM #####################
# ... convert or dissect?
	echo -e "\n\n"
	echo -e "Convert or dissect video's:"
	echo -e "	[0] convert"
	echo -e "	[1] dissect"
	echo -e ""
	read -p "Your selection: " convdiss

	case $convdiss in
	# CONVERT SPECIFIC OPTIONS
	"0")
		ask_convert_quality
		ask_meta_comment
		ask_file_append
		ask_resolution
		ask_aspect_ratio
		ask_framerate
		ask_deinterlace
		ask_deblock
		ask_enhance_image
		ask_enhance_audio
		ask_stabilize
		ask_length
		;;

	# DISSECT SPECIFIC OPTIONS
	  "1")
		ask_extract_video
		ask_resolution
		ask_aspect_ratio
		ask_framerate
		ask_deinterlace
		ask_deblock
		ask_enhance_image
		ask_enhance_audio
		ask_length
		;;
	*)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac


# ... RUN!
	# Runtime variables
	startTime=$(date)
	fCount=0
	basedir="./viddis_out"
	rm -Rf "${basedir}"
	mkdir -p "${basedir}"

	case $convdiss in

	# CONVERT-RUN
	"0")
	for f in "$@"
	do
		clear
		((fCount++))
		outbase="${basedir}/${f}»${f_slug}"
		outfile="${outbase}.${outext}"
		logfile="${outfile}.log"
		echo "Viddis.sh - Extraction & Conversion script (${scriptv})" | tee "${logfile}"
		date   | tee -a "${logfile}"
		echo -e "Processing files (${fCount} of ${nFiles}):  ${outfile}" | tee -a "${logfile}"
		echo -e "\n\n\n+++++++++++++++++SELECTED OPTIONS:\n" | tee -a "${logfile}"
		echo -e ${selection} | tee -a "${logfile}"
		echo -e "\n\n\n+++++++++++++++++SOURCE FILE INFO:\n" >> "${logfile}"
			ffprobe -i "${f}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format flat  >> "${logfile}"
		echo -e "\n\n\n++++++++++++++++++++++++++RUNNING:\n\n" | tee -a "${logfile}"
#		time ffmpeg -hide_banner $o_ln -i "$f" -map 0 -vf "${f_db}${f_di}${f_ss}${f_ar}${f_fr}${f_sh}setsar=sar=1/1,format=yuv420p" $o_fl $outvid -map_metadata 0 -metadata comment="${m_comment}" ${f_cr} -c:s copy "${outfile}" -y &>> "${logfile}"
		time ffmpeg -hide_banner $o_ln -i "$f" -vf "${f_db}${f_di}${f_ss}${f_ar}${f_fr}${f_sh}setsar=sar=1/1,format=yuv420p" $o_fl $outvid -map_metadata 0 -metadata comment="${m_comment}" ${f_cr} "${outfile}" -y &>> "${logfile}"
		#-c:s copy
			if [ ! -z "$f_st" ]; then
				ffmpeg -hide_banner -i "${outfile}" -vf vidstabdetect=shakiness=4:accuracy=15:result="transforms.trf" dummy.mp4 -y &>> "${logfile}"
				ffmpeg -hide_banner -i "${outfile}" -vf vidstabtransform $o_fl $outvid -map_metadata 0 "${outbase}_stab.${outext}" -y &>> "${logfile}"
				rm -f dummy.mp4 transforms.trf "${outfile}"
				mv "${outbase}_stab.${outext}" "${outfile}"
			fi
		   touch -r "$f" "${outfile}"
		echo -e "\n\n\n+++++++++++++++BATCH FINISHED++++++++++++" >> "${logfile}"
		date >> "${logfile}"
	done
		;;

	# DISSECT-RUN
	"1")
		for f in "$@"
		do
			clear
			((fCount++))
			outdir="$basedir/${f}.d"
			mkdir -p "${outdir}"
			logfile="${outdir}/${f}.log"
			out_i="${outdir}/x_images"
			mkdir -p "${out_i}"
			out_a="${outdir}/x_audio"
			mkdir -p "${out_a}"
			out_m="${outdir}/x_metadata"
			mkdir -p "${out_m}"

			echo "Viddis.sh - Extraction & Conversion script (${scriptv})" | tee "${logfile}"
			date   | tee -a "${logfile}"
			echo -e "Processing files (${fCount} of ${nFiles}):  ${f}" | tee -a "${logfile}"
			echo -e "\n\n\n+++++++++++++++++SELECTED OPTIONS:\n" | tee -a "${logfile}"


			# .................... metadata
			echo -e "\n\n\n++++++++++++++EXTRACTING METADATA:\n\n" | tee -a "${logfile}"
			ffprobe -i "${f}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format flat > "${out_m}/${f}.flat"
			ffprobe -i "${f}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format json > "${out_m}/${f}.json"
			ffprobe -i "${f}" -hide_banner -loglevel fatal -show_error -show_format -show_streams -show_programs -show_chapters -show_private_data -print_format ini > "${out_m}/${f}.ini"


			# .................... audio
			echo -e "\n\n\n+++++++++++++++++EXTRACTING AUDIO:\n\n" | tee -a "${logfile}"
				ffmpeg -y -hide_banner -loglevel repeat+level+verbose -i ${f} -vn -acodec copy ${out_a}/${f}.mka | tee "${logfile}"


			# .................... images
			echo -e "\n\n\n+++++++++++++++++EXTRACTING VIDEO:\n\n" | tee -a "${logfile}"
			fcount1=`ffprobe -v fatal -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 ${f}`
			echo -e "\n Number of frames to be extracted: ${fcount1}"
			outfile=${out_i}/${f}_%05d.${outext}
			echo $outfile
			ffmpeg -y -hide_banner -i ${f} -vf "${f_db}${f_di}${f_ss}${f_ar}${f_fr}${f_sh}setsar=sar=1/1,format=yuv420p" ${f_img} ${outfile} | tee "${logfile}"

			# .................... subtitles
			# NOG TOEVOEGEN!!

			echo -e "\n\n\n+++++++++++++++BATCH FINISHED++++++++++++" >> "${logfile}"
			date >> "${logfile}"
		done
		;;
	*)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac


# ... finish up

# clear
echo -e "\n\n\n ${sYe} Finished. ${sNo} \n\n"
echo -e "Start time:  ${startTime} \n\n"
echo -e "Start time:  $(date) \n\n"
echo -e "Output files and logs are placed in:  ${basedir}\n\n\n"
