#!/bin/bash

clear

# Define text styles
sYe="\e[93m"
sNo="\033[1;35m"


# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "       Batch convert old video's, deinterlacing + deblocking + scaling, RickOrchard 2020, no copyright"
echo -e "  --------------------------------------------${sYe} v0.97b ${sNo}----------------------------------------------------"
echo -e ""

# Test nr. of arguments
if [ $# -eq 0 ]
  then
    echo "        No source files specified."
	exit 2
fi

echo -e "   SELECTED INPUT FILES:"
for f in $@
do
	echo -n "    ✻ ${f}   ❭ "
	ffprobe -i ${f} -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio,avg_frame_rate -of csv=s=,:p=0:nk=0
done


	base1="./"

	# ... select source format
	echo -e "\n"
	echo -e "     (a) Preprocess to 4/3 (sar 1/1), no crop"
	echo -e "     (e) Preprocess to 16/9 (sar 1/1), no crop"
	echo -e "     (i) Preprocess to 16/9 (sar 1/1), crop to (3/2)"
	echo -e "     (z) Postprocess/finalize (AV1)"
	echo -e ""
	read -p "      Select profile: " answer1
	echo -e ""

	case $answer1 in
	  "a")
		arg1=",scale=ih*(4/3):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -preset:v slow -profile:v high -crf 14 -c:a aac -b:a 256k"
		arg2="[4.3]"
		arg3=""
        arg10="mp4"
		;;
	  "e")
		arg1=",scale=ih*(16/9):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -preset:v slow -profile:v high -crf 14 -c:a aac -b:a 256k"
		arg2="[16.9]"
		arg3=""
        arg10="mp4"
		;;
	  "i")
		arg1=",scale=ih*(16/9):ih:sws_flags=lanczos,setsar=sar=1/1,crop=ih*(3/2):ih -c:v libx264 -preset:v slow -profile:v high -crf 14 -c:a aac -b:a 256k"
		arg2="[3.2]"
		arg3=""
        arg10="mp4"
		;;
	  "z")
#		arg1=",setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.2 -af crystalizer -c:v hevc_nvenc -preset slow -rc vbr_hq -c:a aac -b:a 192k"
		arg1=",setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.2 -af crystalizer -c:v libaom-av1 -crf 30 -cpu-used 8 -c:a libopus -b:a 128k"
		arg2=""
		arg3="[av1]"
        arg10="mkv"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac


	# ... select deblocking
	echo -e "\n"
	echo -e "     (n) None"
	echo -e "     (l) Low  [2:1]"
	echo -e "     (m) Medium  [3:2b2]"
	echo -e "     (h) High  [3:4b4]"
	echo -e "     (v) Very high  [4:5b5]"
	echo -e ""
	read -p "       Select deblocking/denoising level: " answer1
	echo -e ""

	case $answer1 in
	  "n")
		arg5=""
		arg8=""
		;;
	  "l")
		arg5=",uspp=2:1"
		arg8="[2_1]"
		;;
		"m")
		arg5=",uspp=3:2,bm3d=sigma=2"
		arg8="[3_2b2]"
		;;
		"h")
		arg5=",uspp=3:4,bm3d=sigma=4"
		arg8="[3_4b4]"
		;;
		"v")
		arg5=",uspp=4:5,bm3d=sigma=5"
		arg8="[4_5b5]"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac



	# ... select deinterlacing
	echo -e "\n"
	echo -e "Note: in order for deinterlacing to work properly, the footage should be thouroughly deblocked"
	echo -e ""
	read -p "       Deïnterlace? (y/n)" answer1
	echo -e ""

	case $answer1 in
	  "y")
		arg4=",bwdif"
		arg9="[bd]"
		;;
	  "n")
		arg4=""
		arg9=""
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac

	

		# ... select length
		echo -e "\n"
		echo -e "     (f) Full video length"
		echo -e "     (s) Short preview  [3s]"
		echo -e "     (m) Medium preview  [6s]"
		echo -e "     (l) Long preview  [12s]"
		echo -e ""
		read -p "       Select processing length: " answer1

		case $answer1 in
		  "f")
			arg6=""
			arg7=""
			;;
		  "s")
			arg6="-ss 00:15 -t 3"
			arg7="[03s]"
			;;
		  "m")
			arg6="-ss 00:15 -t 6"
			arg7="[06s]"
			;;
		  "l")
			arg6="-ss 00:15 -t 12"
			arg7="[12s]"
			;;
		  *)
			echo "Invalid answer, exiting..."
			exit 3
			;;
		esac



# LET'S GET TO WORK

for f in $@
do
	echo -e " "
	echo -e "........................Processing ${f}......................"
		ffmpeg ${arg6} -i ${f} -vf format=yuv420p${arg5}${arg4}${arg1} ${base1}${arg2}${arg8}${arg9}${arg7}${f}${arg3}.${arg10} -y
done

echo -e "\n\n\n  ${sYe} Finished. ${sNo} \n\n\n"
