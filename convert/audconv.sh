#!/bin/bash


# User information to inject in metadata
m_encoded_by='Pink Pearl® Digital Media'
m_copyright=''
m_encoder='ffmpeg'


clear

# Define constants
scriptv="v0.97b"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"audconv.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "       Batch convert audio, with options.  RickOrchard 2021, no copyright"
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
echo -e "  -------------------------------------audconv.sh $scriptv logfile---------------------------------------\n" >> $logfile

	base1="./"

	# ... select output format.........................................................................................
	echo -e "\n\n"
	echo -e "      SELECT OUTPUT FORMAT: "
	echo -e "     (o) Convert to OGG (OPUS)"
#	echo -e "     (a) Convert to M4A (AAC)"
	echo -e "     (m) Convert to MP3  [less efficient]"
	echo -e ""
	read -p "      --> " answer_format
	echo -e ""


	# ... select quality.........................................................................................
	echo -e "      SELECT OUTPUT QUALITY: "
	echo -e "     (l) low quality (mono/24kHz)"
	echo -e "     (m) medium quality"
	echo -e "     (h) high quality"
	echo -e ""
	read -p "      --> " answer_quality
	echo -e ""





	case $answer_format in
	
	  "a")
        case $answer_quality in
          "l")
                arg0b="[lq-"
                arg1="-c:a aac -b:a 48k  -ar 24000 -ac 1"
            ;;

          "m")
                arg0b="[mq-"
                arg1="-c:a aac -b:a 96k  -ar 48000"
            ;;

          "h")
                arg0b="[hq-"
                arg1="-c:a aac -b:a 192k -ar 48000"
            ;;
        esac
        arg0a="m4a"
        arg0b=$arg0b"aac-EBU_R128]"
		;;
		
	  "o")
        arg0="ogg"
        case $answer_quality in
          "l")
                arg0b="[lq-"
                arg1="-c:a libopus -b:a 40k -ar 24000 -ac 1 -vbr on -compression_level 10 -frame_duration 40"
            ;;

          "m")
                arg0b="[mq-"
                arg1="-c:a libopus -b:a 80k -ar 48000 -vbr on -compression_level 10"
            ;;

          "h")
                arg0b="[hq-"
                arg1="-c:a libopus -b:a 160k -ar 48000 -vbr on -compression_level 10"
            ;;
        esac
        arg0a="ogg"
        arg0b=$arg0b"opus-EBU_R128]"
		;;
		
		"m")
        arg0="mp3"
        case $answer_quality in
        
          "l")
                arg0b="[lq-"
                arg1="-c:a libmp3lame -q:a 8 -compression_level 0 -ar 24000 -ac 1"
            ;;

          "m")
                arg0b="[mq-"
                arg1="-c:a libmp3lame -q:a 5 -compression_level 0 -ar 48000"
            ;;

          "h")
                arg0b="[hq-"
                arg1="-c:a libmp3lame -q:a 0 -compression_level 0 -ar 48000"
            ;;
            
        esac
        arg0a="mp3"
        arg0b=$arg0b"lame-EBU_R128]"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  -----------------Convert to [ $arg0a ] with [ $arg1 ] \n" >> $logfile





	# ... select noise reduction.........................................................................................
	echo -e "      SELECT NOISE CONTROL "
	echo -e "     (n) none"
	echo -e "     (l) low (soft noise gate)"
	echo -e "     (m) medium (ng+afftdn)"
	echo -e "     (s) strong (ng+afftdn+lp+hp)"
	echo -e ""
	read -p "      --> " answer_noise
	echo -e ""

	EBU_R128="-af loudnorm=I=-16:LRA=11:TP=-1.5"

	case $answer_noise in
	  "n")
        afilt=$EBU_R128""
		;;
	  "l")
        afilt=$EBU_R128",compand=attacks=.01=decays=.01:points=-60/-200|-40/-70|-30/-27|-20/-20|20/20"
		;;
	  "m")
        afilt=$EBU_R128",compand=attacks=.01=decays=.01:points=-60/-200|-40/-70|-30/-27|-20/-20|20/20,afftdn=nf=-35:nr=10"
		;;
	  "s")
        afilt=$EBU_R128",compand=attacks=.01=decays=.01:points=-60/-200|-40/-70|-30/-27|-20/-20|20/20,afftdn=nf=-25:nr=15,highpass=f=150,lowpass=f=3500"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac



	# ... select crystalizer .........................................................................................
	echo -e "\n"
	read -p "      Enhance audio? (y/n): " answer_crystalizer
	echo -e "\n"

    if [ $answer_crystalizer = "y" ]; then
        afilt=$afilt",crystalizer"
    fi

    echo -e "  ----------------[ $afilt ] \n" >> $logfile




	# ... select audio type.........................................................................................
	
	echo -e "      SELECT AUDIO TYPE:"
	echo -e "\n"
	echo -e "     (m) music"
	echo -e "     (v) voice"
	echo -e ""
	read -p "      --> " answer_type
	echo -e ""

	case $answer_type in
	  "m")
        arg2="-application audio"
		;;
	  "v")
        arg2="-application voip"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg2 ] \n" >> $logfile





	# ... select METADATA.........................................................................................
	echo -e "\n"
	read -p "      Copy METADATA? (y/n): " include_meta
	echo -e "\n"

    arg3=""
    if [ $include_meta = "y" ]; then
        arg3="-map_metadata 0 -id3v2_version 3"
    fi
    echo -e "  ----------------[ $arg3 ] \n" >> $logfile




    	# ... select length.........................................................................................
	echo -e "      SELECT LENGTH: "
	echo -e "     (f) Full video length"
	echo -e "     (s) Short preview  [15s]"
	echo -e "     (l) Long preview  [60s]"
	echo -e ""
	read -p "       Select processing length: " answer1

	case $answer1 in
	  "f")
		arg4=""
		arg5=""
		;;
	  "s")
		arg4="-ss 00:45 -t 15"
		arg5="[15s]"
		;;
	  "l")
		arg4="-ss 00:45 -t 60"
		arg5="[60s]"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac




# LET'S GET TO WORK

for f in "$@"
do
    outfile="$f".$arg0b$arg5.$arg0a
	echo -e " "
	echo -e "........................Processing "$f" ...to... $outfile" | tee -a $logfile
	echo -e ".\n.\n.\n." >> $logfile
    ffmpeg -y -hide_banner  -i "$f"  $arg4 $arg1 $afilt $arg2 $arg3 -metadata encoded_by=$m_encoded_by -metadata copyright=$m_copyright -metadata encoder=$m_encoder "$outfile"
done



echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
