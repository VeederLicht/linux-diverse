#!/bin/bash

clear
echo -e "\e[2m  ======================================================================================================="
echo -e "\e[2m      Batch convert old video's, deinterlacing + deblocking + scaling, RickOrchard 2020, no copyright"
echo -e "\e[2m  --------------------------------------------v0.43------------------------------------------------------"
echo -e "\n\n"

	base1="./"
	

	for f in $@
	do

        clear
		echo "........................Processing ${f}......................"

    echo "....VHS 576@PAL to 4/3, light deblocking (slow!!)  crop=768:576"
    ffmpeg -i ${f} -vf "format=yuv420p,bwdif,scale=ih/3*4:ih:flags=lanczos,setsar=sar=1/1,uspp=2:2" -af crystalizer -c:v libx264 -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k ${base1}${f}.mp4 -y


#    echo "....Super8 576@4/3  to 3/2, strong deblocking (slow!!)  crop=828:552"
#    ffmpeg -i ${f} -vf "format=yuv420p,bwdif,scale=ih/45*64:ih,crop=816:544,setdar=dar=3/2,setsar=sar=1/1,uspp=3:8,deband" -af crystalizer -c:v libx264 -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k ${base1}${f}.mp4 -y


#   echo "....Super8 576@16/9  to 3/2, medium deblocking (slow!!)  crop=828:552"
#   ffmpeg -i ${f} -vf "format=yuv420p,bwdif,scale=ih/9*16:ih,crop=828:552,setdar=dar=3/2,setsar=sar=1/1,uspp=3:2,deband" -af crystalizer -c:v libx264 -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k ${base1}${f}.mp4 -y

		
#   echo "....Finalize, H265"
#   ffmpeg -hwaccel cuda -i ${f} -init_hw_device cuda=gtx:0 -filter_hw_device gtx -vf hwupload_cuda,scale_cuda=-2:720,hwdownload,setsar=sar=1/1,unsharp=3:3:1 -c:v hevc_nvenc -preset slow -rc vbr_hq -c:a aac -b:a 196k ${base1}${f}.mp4 -y

	done



echo -e "\n\n\n  \e[4mFinished.\e[0m \n\n\n"
