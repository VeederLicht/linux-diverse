#!/bin/bash

echo -e "\n\n"
echo -e "\e[2m  ======================================================================================================="
echo -e "\e[2m      Batch convert old video's, deinterlacing + deblocking + scaling, RickOrchard 2020, no copyright"
echo -e "\e[2m  -------------------------------------------- v0.75 ----------------------------------------------------"
echo -e "\n"

	base1="./"
	
	# ... select source format
	echo -e "\e     (a) Preprocess VHS:  720x576 to 768x576 (4/3)  [low noise"
	echo -e "\e     (e) Preprocess Super8: 720x576 (4/3) to 828x552 (3/2)  [medium noise]"
	echo -e "\e     (f) Preprocess Super8: 720x576 (16/9) to 810x540 (3/2)  [medium noise]"
	echo -e "\e     (i) Preprocess Double8: 720x576 (4/3) to 780x520 (3/2)  [interlaced, high noise]"
	echo -e "\e     (z) Postprocess/finalize (H265)"
    echo -e " "
	read -p "       Select profile: " answer1

	case $answer1 in
	  "a")
		arg1="-vf format=yuv420p,yadif,uspp=2:2,scale=768:576:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="(vhs)"
		arg3=""
		;;
	  "e")
		arg1="-vf format=yuv420p,uspp=3:4,scale=830:576:sws_flags=lanczos,setsar=sar=1/1,crop=828:552 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="(sup8)"
		arg3=""
		;;
	  "f")
		arg1="-vf format=yuv420p,uspp=3:3,scale=1024:576:sws_flags=lanczos,setsar=sar=1/1,crop=810:540 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="(dbl8)"
		arg3=""
		;;
	  "i")
		arg1="-vf format=yuv420p,yadif,uspp=3:6,scale=784:576:sws_flags=lanczos,setsar=sar=1/1,crop=780:520 -c:v libx264 -preset:v slow -profile:v high -crf 10 -c:a aac -b:a 256k"
		arg2="(dbl8)"
		arg3=""
		;;
	  "z")
		arg1="-init_hw_device cuda=gtx:0 -filter_hw_device gtx -vf setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.2 -af crystalizer -c:v hevc_nvenc -preset slow -rc vbr_hq -c:a aac -b:a 192k"
		arg2=""
		arg3="(h265)"
		;;
	  *)
		echo "Invalid answer, exiting..."
		exit 3
		;;
	esac

	for f in $@
	do
        echo -e " "
		echo -e "........................Processing ${f}......................"
#        ffmpeg -ss 01:00 -t 5 -i ${f} ${arg1} ${base1}${arg2}${f}${arg3}.mp4 -y
        ffmpeg -i ${f} ${arg1} ${base1}${arg2}${f}${arg3}.mp4 -y
	done



echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n" 
