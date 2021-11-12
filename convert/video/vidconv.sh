#!/bin/bash


# User information to inject in metadata
m_composer=''
m_copyright='©2021 Pink Pearl®'
m_comment='VIDEOTOOL: - & AUDIOTOOL: -'
m_title=''
m_year=''


clear

# Define constants
scriptv="v1.31"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"vidconv.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "       Batch process (old) video's, deinterlacing + deblocking + scaling. RickOrchard 2020, no copyright"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"
echo -e "\n ${sYe}  NOTE: metadata will be injected, to change it edit this scriptheader!  ${sNo} \n\n"

# Test nr. of arguments
if [ $# -eq 0 ]
  then
    echo "        No source files specified."
	exit 2
fi

# !!!! ARGUMENTS IN DOUBLE QOUTES TO AVOID PROBLEMS WITH SPACES IN FILENAMES!!! https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
for f in "$@"
do
	echo -n "    ✻ "$f"  ➢➢  "
	ffprobe -i "$f" -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio,avg_frame_rate -of csv=s=,:p=0:nk=0
done


echo -e "  =======================================================================================================" > $logfile
echo -e "  -------------------------------------vidconv.sh $scriptv logfile---------------------------------------\n" >> $logfile

	base1="./"

	# ... select source format
	echo -e "\n"
	echo -e "     (o) Preprocess, original ratio  (sar 1/1)"
	echo -e "     (v) Preprocess, VHS 4:3  (sar 1/1)"
	echo -e "     (d) Preprocess, Double8 11:8  (sar 1/1)"
	echo -e "     (s) Preprocess, Super8 13:9  (sar 1/1)"
	echo -e "     (1) Postprocess/finalize (AV1)"
	echo -e "     (4) Postprocess/finalize (H264)"
	echo -e "     (m) Change container to mp4"
	echo -e "     (a) Extract audio track"
	echo -e ""
	read -p "      Select profile: " answer1
	echo -e ""

	case $answer1 in
	  "o")
		echo -e "  -----------------Preprocess (sar 1/1), original ratio, no crop \n" >> $logfile
		arg0="-vf format=yuv420p"
#		arg1=",setsar=sar=1/1 -c:v libx264 -preset:v slow -profile:v high -crf 14 -c:a aac -b:a 256k"
		arg1=",setsar=sar=1/1 -c:v libx264 ${metadata_inject} -intra -preset:v slow -profile:v high -crf 17 -tune grain -c:a aac -b:a 256k"
		arg2="[ori]"
		arg3=".h264"
		arg10=".m4v"
		;;
	  "v")
		echo -e "  -----------------Preprocess, VHS 4:3  (sar 1/1) \n" >> $logfile
		arg0="-vf format=yuv420p"
		arg1=",scale=ih*(4/3):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -intra -preset:v slow -profile:v high -crf 17 -tune grain -c:a aac -b:a 256k"
		arg2=."[4x3]"
		arg3=".[h264]"
		arg10=".m4v"
		;;
	  "d")
		echo -e "  -----------------Preprocess, Double8 11:8  (sar 1/1) \n" >> $logfile
		arg0="-vf format=yuv420p"
		arg1=",scale=ih*(11/8):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -intra -preset:v slow -profile:v high -crf 17 -tune grain -c:a aac -b:a 256k"
		arg2=".[11x8]"
		arg3=".[h264]"
		arg10=".m4v"
		;;
	  "s")
		echo -e "  -----------------Preprocess, Super8 13:9 \n" >> $logfile
		arg0="-vf format=yuv420p"
		arg1=",scale=ih*(13/9):ih:sws_flags=lanczos,setsar=sar=1/1 -c:v libx264 -intra -preset:v slow -profile:v high -crf 17 -tune grain -c:a aac -b:a 256k"
		arg2=".[13x9]"
		arg3=".[h264]"
		arg10=".m4v"
		;;
	  "1")
		echo -e ""
		echo -e "     (s) libsvtav1"
		echo -e "     (a) libaom-av1"
		echo -e ""
		read -p "       Select encoder: " encoder
		echo -e ""

		if [ "$encoder" = "a" ]; then
			arg1=",setsar=sar=1/1,unsharp=3:3:0.5,unsharp=5:5:0.1,eq=contrast=1.01 -c:v libaom-av1 -c:a libopus -b:a 128k"
			encoder="libaom-av1"
		else
			arg1=",setsar=sar=1/1,unsharp=3:3:0.7,unsharp=5:5:0.1,eq=contrast=1.01 -c:v libsvtav1 -c:a libopus -b:a 128k"
			encoder="libsvtav1"
		fi
		echo -e "  -----------------Postprocess/finalize (AV1 / $encoder) \n" >> $logfile
		arg0="-vf format=yuv420p"
		arg2=""
		arg3="-av1]"
        arg10=".webm"
		;;
	  "4")
		echo -e "  -----------------Postprocess/finalize (H264) \n" >> $logfile
		arg0="-vf format=yuv420p"
		arg1=",setsar=sar=1/1,unsharp=3:3:0.3,unsharp=5:5:0.1,eq=contrast=1.01 -c:v libx264 -c:a aac -b:a 192k"
		arg2=""
		arg3="-h264]"
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
	  "a")
		echo -e "  -----------------Extract audio track \n" >> $logfile
		arg0=""
		arg1=" -vn "
		arg2=""
		arg3=""
		arg10=".wav"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac


	case $answer1 in

    # IN CASE OF PREPROCESSING...
	  "o"|"v"|"d"|"s")
	    # ... select deinterlacing
	    echo -e "\n"
	    echo -e "Deinterlace?"
	    echo -e ""
      	echo -e "     (0) None"
	    echo -e "     (1) 1 frame per FRAME"
	    echo -e "     (2) 1 frame per FIELD"
	    echo -e ""
	    read -p "       Select Deïnterlacing: " deint
	    echo -e ""

	    case $deint in
        "0")
        arg4=""
        arg9=""
        ;;
        "1")
        echo -e "  -----------------Deinterlacing with yadif-0 \n" >> $logfile
        arg4=",yadif=mode=0"
        arg9="[yad0]"
        ;;
	      "2")
        echo -e "  -----------------Deinterlacing with yadif-1 \n" >> $logfile
		    arg4=",yadif=mode=1"
		    arg9="[yad1]"
		    ;;
	    esac

	    # ... select deblocking
	    echo -e "\n"
	    echo -e "Note: in order for deinterlacing to work properly, it helps to deblock the footage."
	    echo -e ""
	    echo -e "     (0) None"
	    echo -e "     (1) Low (high quality)"
	    echo -e "     (2) Medium"
	    echo -e "     (3) High"
	    echo -e "     (4) Extreme"
	    echo -e ""
	    read -p "       Select deblocking/denoising level: " deblock
	    echo -e ""

	    case $deblock in
	      "0")
		    arg5=""
		    arg8=""
		    ;;
	      "1")
            echo -e "  -----------------Low strength deblocking \n" >> $logfile
		    arg5=",bm3d=sigma=3"
		    arg8="[bm2]"
		    ;;
		    "2")
            echo -e "  -----------------Medium strength deblocking/denoising \n" >> $logfile
		    arg5=",spp=2:1:mode=soft"
		    arg8="[2_1]"
		    ;;
		    "3")
            echo -e "  -----------------High strength deblocking/denoising \n" >> $logfile
		    arg5=",spp=3:2:mode=soft"
		    arg8="[3_2]"
		    ;;
		    "4")
            echo -e "  -----------------Extreme strength deblocking/denoising \n" >> $logfile
		    arg5=",spp=4:3:mode=soft"
		    arg8="[4_3]"
		    ;;
	      *)
		    echo "Unknown option, exiting..."
		    exit 3
		    ;;
	    esac
        ;;

    # IN CASE OF FINAL OUTPUT...
	  "1"|"4")
	    # ... select quality
	    echo -e "\n"
	    echo -e ""
	    read -p "       Select output quality high/medium/low (h/m/l): " qal
	    echo -e ""

	    case $qal in
	      "h")
            echo -e "  -----------------High quality output \n" >> $logfile
			case $encoder in
				"libsvtav1")
					arg12="-b:v 0 -qp 28 -preset 6"
					;;
				"libaom-av1")
					arg12="-crf 28 -cpu-used 7"
					;;
				*)
					arg12="-b:v 0 -crf 20 -preset:v slow -profile:v high"
					;;
			esac
            arg3=".[hq${arg3}"
		    ;;
	      "m")
            echo -e "  -----------------Medium quality output \n" >> $logfile
			case $encoder in
				"libsvtav1")
					arg12="-b:v 0 -qp 38 -preset 7"
					;;
				"libaom-av1")
					arg12="-crf 38 -cpu-used 7"
					;;
				*)
					arg12="-b:v 0 -crf 25 -preset:v slow -profile:v high"
					;;
			esac
            arg3=".[mq${arg3}"
		    ;;
	      *)
            echo -e "  -----------------Low quality output \n" >> $logfile
			case $encoder in
				"libsvtav1")
					arg12="-b:v 0 -qp 48 -preset 8"
					;;
				"libaom-av1")
					arg12="-crf 48 -cpu-used 7"
					;;
				*)
					arg12="-b:v 0 -crf 30 -preset:v fast -profile:v main"
					;;
			esac
             arg3=".[lq${arg3}"
		    ;;
	    esac

	    # ... select crystalizer
	    echo -e "\n"
	    echo -e ""
	    read -p "       Apply audio crystalizer? (y/n)" cryst
	    echo -e ""

	    case $cryst in
	      "y")
            echo -e "  -----------------Apply audio crystalizer \n" >> $logfile
		    arg11="-af crystalizer"
		    ;;
	      *)
		    arg11=""
		    ;;
	    esac
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
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac




# LET'S GET TO WORK

for f in "$@"
do
    outfile=$base1"$f"$arg2$arg8$arg9$arg7$arg3$arg10
	echo -e " "
	echo -e "........................Processing "$f"...to...$outfile................"
	echo -e ".\n.\n.\n." >> $logfile
    time ffmpeg -hide_banner -nostats $arg6 -i "$f" $arg0$arg5$arg4$arg1 $arg12 $arg11 -movflags +faststart -metadata composer="$m_composer" -metadata copyright="$m_copyright" -metadata comment="$m_comment" -metadata title="$m_title" -metadata year="$m_year" "$outfile" -y &>> $logfile
done


echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
