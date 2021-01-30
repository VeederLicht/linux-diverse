#!/bin/bash

# Define text styles
sNo="\[\033[0m"
sBo="\033[1;30m"


# Show banner
echo -e "\n ${sBo}"
echo -e "  ======================================================================================================="
echo -e "       Batch convert old video's, deinterlacing + deblocking + scaling, RickOrchard 2020, no copyright"
echo -e "  -------------------------------------------- v0.80 ----------------------------------------------------"
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
	echo -e "     (a) Preprocess VHS:  720x576 to 768x576 (4/3)"
	echo -e "     (e) Preprocess Super8: 720x576 (4/3) to 828x552 (3/2)"
	echo -e "     (f) Preprocess Super8: 720x576 (16/9) to 810x540 (3/2)"
	echo -e "     (i) Preprocess Double8: 720x576 (4/3) to 780x520 (3/2)"
	echo -e "     (z) Postprocess/finalize (H265)"
	echo -e "\e[1m"
	read -p "      Select profile: " answer1
	echo -e "${sBo}"

	case $answer1 in
	  "a")
		arg1=",scale=768:576:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="[vhs]"
		arg3=""
		;;
	  "e")
		arg1=",scale=830:576:sws_flags=lanczos,setsar=sar=1/1,crop=828:552 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="[sup8]"
		arg3=""
		;;
	  "f")
		arg1=",scale=1024:576:sws_flags=lanczos,setsar=sar=1/1,crop=810:540 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="[dbl8]"
		arg3=""
		;;
	  "i")
		arg1=",scale=784:576:sws_flags=lanczos,setsar=sar=1/1,crop=780:520 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="[dbl8]"
		arg3=""
		;;
	  "z")
		arg1=",setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.2 -af crystalizer -c:v hevc_nvenc -preset slow -rc vbr_hq -c:a aac -b:a 192k"
		arg2=""
		arg3="[h265]"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac


	# ... select deinterlacing
	echo -e "\n"
	read -p "       Deïnterlace? (y/n)" answer1
	echo -e ""

	case $answer1 in
	  "y")
		arg4=",yadif"
		arg9="[y]"
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


	# ... select deblocking
	echo -e "\n"
	echo -e "     (n) None"
	echo -e "     (l) Low  [3:1]"
	echo -e "     (m) Medium  [3:3b3]"
	echo -e "     (h) High  [4:4b4]"
	echo -e "     (v) Very high  [4:7b7]"
	echo -e ""
	read -p "       Select deblocking/denoising level: " answer1
	echo -e ""

	case $answer1 in
	  "n")
		arg5=""
		arg8=""
		;;
	  "l")
		arg5=",uspp=3:1"
		arg8="[3_1]"
		;;
		"m")
		arg5=",uspp=3:3,bm3d=sigma=3"
		arg8="[3_3b3]"
		;;
		"h")
		arg5=",uspp=4:4,bm3d=sigma=4"
		arg8="[4_4b4]"
		;;
		"v")
		arg5=",uspp=4:7,bm3d=sigma=7"
		arg8="[4_7b7]"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac


		# ... select length
		echo -e "\n"
		echo -e "     (f) Full video length"
		echo -e "     (s) Short preview  [5s]"
		echo -e "     (m) Medium preview  [10s]"
		echo -e "     (l) Long preview  [15s]"
		echo -e ""
		read -p "       Select processing length: " answer1

		case $answer1 in
		  "f")
			arg6=""
			arg7=""
			;;
		  "s")
			arg6="-ss 00:15 -t 5"
			arg7="[05s]"
			;;
		  "m")
			arg6="-ss 00:15 -t 10"
			arg7="[10s]"
			;;
		  "l")
			arg6="-ss 00:15 -t 15"
			arg7="[15s]"
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
      ffmpeg ${arg6} -i ${f} -vf format=yuv420p${arg4}${arg5}${arg1} ${base1}${arg2}${arg8}${arg9}${arg7}${f}${arg3}.mp4 -y
done

echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n"
