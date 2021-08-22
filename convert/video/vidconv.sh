#!/bin/bash


# User information to inject in metadata
m_composer='Richard van den Boogaardt  (richard@pinkpearl.eu)'
m_copyright='©2021 Pink Pearl®'
m_comment='VIDEOTOOL: Blackmagic Design DaVinci Resolve & AUDIOTOOL: Izotope RX8'


clear

# Define constants
scriptv="v1.0"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"vidconv.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "       Batch convert old video's, deinterlacing + deblocking + scaling, RickOrchard 2020, no copyright"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"
echo -e "\n ${sYe}  NOTE: metadata will be injected, to change it edit this scriptheader!  ${sNo} \n\n"

# Test nr. of arguments
if [ $# -eq 0 ]
  then
    echo "        No source files specified."
	exit 2
fi

echo -e "    INPUT FILES:"
for f in $@
do
	echo -n "    ✻ ${f}  ➢➢  "
	ffprobe -i ${f} -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio,avg_frame_rate -of csv=s=,:p=0:nk=0
done


echo -e "  =======================================================================================================" > $logfile
echo -e "  -------------------------------------vidconv.sh $scriptv logfile---------------------------------------\n" >> $logfile

	base1="./"

	# ... select source format
	echo -e "\n"
	echo -e "     (a) Preprocess (sar 1/1), original ratio, no crop"
	echo -e "     (b) Preprocess to 4/3 (sar 1/1), no crop"
	echo -e "     (c) Preprocess to 16/9 (sar 1/1), no crop"
	echo -e "     (d) Preprocess to 16/9 (sar 1/1), crop to (3/2)"
	echo -e "     (1) Postprocess/finalize (AV1)"
	echo -e "     (9) Postprocess/finalize (VP9)"
	echo -e "     (4) Postprocess/finalize (H264)"
	echo -e "     (m) Change container to mp4"
	echo -e ""
	read -p "      Select profile: " answer1
	echo -e ""

	case $answer1 in
	  "a")
        echo -e "  -----------------Preprocess (sar 1/1), original ratio, no crop \n" >> $logfile
        arg0="-vf format=yuv420p"
#		arg1=",setsar=sar=1/1 -c:v libx264 -preset:v slow -profile:v high -crf 14 -c:a aac -b:a 256k"
		arg1=",setsar=sar=1/1 -c:v libx264 ${metadata_inject} -intra -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k"
		arg2="[ori]"
		arg3=".h264"
        arg10=".m4v"
 
		;;
	  "b")
        echo -e "  -----------------Preprocess to 4/3 (sar 1/1), no crop \n" >> $logfile
        arg0="-vf format=yuv420p"
		arg1=",scale=ih*(4/3):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -intra -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k"
		arg2="[4.3]"
		arg3=".h264"
        arg10=".m4v"
		;;
	  "c")
        echo -e "  -----------------Preprocess to 16/9 (sar 1/1), no crop \n" >> $logfile
        arg0="-vf format=yuv420p"
		arg1=",scale=ih*(16/9):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -intra -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k"
		arg2="[16.9]"
		arg3=".h264"
        arg10=".m4v"
		;;
	  "d")
        echo -e "  -----------------Preprocess to 16/9 (sar 1/1), crop to (3/2) \n" >> $logfile
        arg0="-vf format=yuv420p"
		arg1=",scale=ih*(16/9):ih:sws_flags=lanczos,setsar=sar=1/1,crop=ih*(3/2):ih -c:v libx264 -intra -preset:v slow -profile:v high -crf 17 -c:a aac -b:a 256k"
		arg2="[3.2]"
		arg3=".h264"
        arg10=".m4v"
		;;
	  "1")
        echo -e "  -----------------Postprocess/finalize (AV1) \n" >> $logfile
        arg0="-vf format=yuv420p"
#		arg1=",setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.2 -af crystalizer -c:v libaom-av1 -cpu-used 7 -crf 30 -c:a libopus -b:a 128k"
		arg1=",setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.2 -c:v libaom-av1 -cpu-used 7 -crf 30 -c:a libopus -b:a 128k"
		arg2=""
		arg3=".av1"
        arg10=".mp4"
		;;
	  "9")
        echo -e "  -----------------Postprocess/finalize (VP9) \n" >> $logfile
        arg0="-vf format=yuv420p"
#		arg1=",setsar=sar=1/1,unsharp=3:3:0.5,unsharp=5:5:0.2 -af crystalizer -c:v libvpx-vp9 -cpu-used 2 -crf 35 -c:a libopus -b:a 128k"
		arg1=",setsar=sar=1/1,unsharp=3:3:0.5,unsharp=5:5:0.2 -c:v libvpx-vp9 -cpu-used 2 -crf 35 -c:a libopus -b:a 128k"
		arg2=""
		arg3=".vp9"
        arg10=".webm"
		;;
	  "4")
        echo -e "  -----------------Postprocess/finalize (H264) \n" >> $logfile
        arg0="-vf format=yuv420p"
		arg1=",setsar=sar=1/1,unsharp=3:3:0.4,unsharp=5:5:0.1 -c:v libx264 -preset:v slow -profile:v high -crf 22 -c:a aac -b:a 192k"
		arg2=""
		arg3=".h264"
        arg10=".mp4"
		;;
	  "m")
        echo -e "  -----------------Change container to mp4 \n" >> $logfile
        arg0=""
		arg1=" -c copy "
		arg2=""
		arg3=""
        arg10=".mp4"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac


    if [ $answer1 != "m" ]; then
	    # ... select deinterlacing
	    echo -e "\n"
	    echo -e "Note: in order for deinterlacing to work properly, the footage should be thouroughly deblocked"
	    echo -e ""
	    read -p "       Deïnterlace? (y/n)" answer1
	    echo -e ""

	    case $answer1 in
	      "y")
        echo -e "  -----------------Deinterlacing with bwdif \n" >> $logfile
		    arg4=",bwdif"
		    arg9="[bwd]"
		    ;;
	      "n")
		    arg4=""
		    arg9=""
		    ;;
	      *)
		    echo "Unknown option, exiting..."
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
            echo -e "  -----------------Low strength deblocking/denoising \n" >> $logfile
		    arg5=",uspp=2:1"
		    arg8="[2_1]"
		    ;;
		    "m")
            echo -e "  -----------------Medium strength deblocking/denoising \n" >> $logfile
		    arg5=",uspp=3:2,bm3d=sigma=2"
		    arg8="[3_2b2]"
		    ;;
		    "h")
            echo -e "  -----------------High strength deblocking/denoising \n" >> $logfile
		    arg5=",uspp=3:4,bm3d=sigma=4"
		    arg8="[3_4b4]"
		    ;;
		    "v")
            echo -e "  -----------------Very high strength deblocking/denoising \n" >> $logfile
		    arg5=",uspp=4:5,bm3d=sigma=5"
		    arg8="[4_5b5]"
		    ;;
	      *)
		    echo "Unknown option, exiting..."
		    exit 3
		    ;;
	    esac	
    fi


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
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac




# LET'S GET TO WORK

for f in $@
do
	echo -e " "
	echo -e "........................Processing ${f}......................"
	echo -e ".\n.\n.\n." >> $logfile
    time ffmpeg -hide_banner -nostats $arg6 -i ${f} $arg0$arg5$arg4$arg1 -metadata composer="$m_composer" -metadata copyright="$m_copyright" -metadata comment="$m_comment" $base1${f}$arg2$arg8$arg9$arg7$arg3$arg10 -y &>> $logfile
done


echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
