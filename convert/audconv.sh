#!/bin/bash

# User information to inject in metadata
m_encoded_by=''
m_copyright=''
m_encoder='ffmpeg'

clear

# Define constants
scriptv="v1.30"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"audconv.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "       Batch convert audio, with options. Copyleft 2023 VeederLicht@Github"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------\n\n"

# Test nr. of arguments
if [ $# -eq 0 ]; then
    echo "      ERROR:  No source files specified."
    exit 2
fi
if ! command -v jq &>/dev/null; then
    echo "      ERROR: This script relies on the program 'jq' (Command-line JSON processor). It could not be found, exiting..."
    exit 2
fi

# !!!! ARGUMENTS IN DOUBLE QOUTES TO AVOID PROBLEMS WITH SPACES IN FILENAMES!!! https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
echo -e "  FILES TO BE PROCESSED:"
for f in "$@"; do
    echo -e "    ➢➢  $f"
    #fprobe -i "$f" -v fatal -select_streams v:0 -show_entries format=bit_rate,duration -of csv=s=,:p=0:nk=0
done

echo -e ""
echo -e "  IS THIS CORRECT?"
echo -e "   (0) no"
echo -e "   (1) yes"
echo -e ""
read -p "      --> " iscorrect
echo -e ""

case $iscorrect in
"0") exit 9 ;;
"1") ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac

echo -e "  =======================================================================================================" >$logfile
echo -e "  -------------------------------------audconv.sh $scriptv logfile---------------------------------------\n" >>$logfile

base1="./"


echo -e "\n ${sYe}  NOTE:"
echo -e "       - metadata will be injected, to change it edit this scriptheader"
echo -e "       - all output files will be loudness-normalized according to EBU R128  ${sNo} \n"


# ... select output format.........................................................................................
echo -e ""
echo -e "  SELECT OUTPUT FORMAT: "
echo -e "   (0)   Convert to OPUS"
echo -e "   (1)   Convert to AAC"
echo -e "   (2)   Convert to MP3"
echo -e ""
read -p "      --> " answer_format
echo -e ""

# ... select quality.........................................................................................
echo -e "  SELECT OUTPUT QUALITY: "
echo -e "   (0)   low quality (mono/24kHz)"
echo -e "   (1)   medium quality"
echo -e "   (2)   high quality"
echo -e ""
read -p "      --> " answer_quality
echo -e ""

case $answer_format in

"0")
    case $answer_quality in
    "0")
        arg0b="[lq-"
        arg1="-c:a libopus -b:a 40k -ar 24000 -ac 1"
        ;;

    "1")
        arg0b="[mq-"
        arg1="-c:a libopus -b:a 80k -ar 48000"
        ;;

    "2")
        arg0b="[hq-"
        arg1="-c:a libopus -b:a 160k -ar 48000"
        ;;
    esac
    arg0a="opus"
    arg0b=$arg0b"opus]"
    ;;

"1")
    case $answer_quality in
    "0")
        arg0b="[lq-"
        arg1="-c:a aac -b:a 48k  -ar 24000 -ac 1"
        ;;

    "1")
        arg0b="[mq-"
        arg1="-c:a aac -b:a 96k  -ar 48000"
        ;;

    "2")
        arg0b="[hq-"
        arg1="-c:a aac -b:a 192k -ar 48000"
        ;;
    esac
    arg0a="m4a"
    arg0b=$arg0b"aac]"
    ;;

"2")
    case $answer_quality in
    "0")
        arg0b="[lq-"
        arg1="-c:a libmp3lame -q:a 8 -compression_level 0 -ar 24000 -ac 1"
        ;;

    "1")
        arg0b="[mq-"
        arg1="-c:a libmp3lame -q:a 5 -compression_level 0 -ar 48000"
        ;;

    "2")
        arg0b="[hq-"
        arg1="-c:a libmp3lame -q:a 0 -compression_level 0 -ar 48000"
        ;;

    esac
    arg0a="mp3"
    arg0b=$arg0b"lame]"
    ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac
echo -e "  -----------------Convert to [ $arg0a ] with [ $arg1 ] \n" >>$logfile

# ... select noise reduction.........................................................................................
echo -e "  SELECT NOISE SUPPRESSION "
echo -e "   (0) none"
echo -e "   (1) light (gate)"
echo -e "   (2) strong (gate+anlmdn, slow!)"
echo -e ""
read -p "      --> " answer_noise
echo -e ""

afilt=""

case $answer_noise in
"0") ;;
"1")
    afilt=",compand=attacks=.01=decays=.01:points=-65/-90|-30/-30|-20/-18|0/0"
    ;;
"2")
    afilt=",compand=attacks=.01=decays=.01:points=-45/-900|-25/-25|-15/-13|0/0,anlmdn=s=0.3:p=0.05:r=0.006"
    ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac

# ... select frequencies.........................................................................................
echo -e "  SELECT FREQUENCY CUTOUT:"
echo -e "   (0) none"
echo -e "   (1) low frequencies (<200Hz)"
echo -e "   (2) high frequencies (>3500Hz)"
echo -e "   (3) both (voice isolation)"
echo -e ""
read -p "      --> " answer_noise
echo -e ""

case $answer_noise in
"0") ;;
"1")
    afilt=",highpass=f=200"$afilt
    ;;
"2")
    afilt=",lowpass=f=3500"$afilt
    ;;
"3")
    afilt=",highpass=f=150,lowpass=f=3500"$afilt
    ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac

# ... select crystalizer .........................................................................................
echo -e "  ENHANCE AUDIO CLARITY?"
echo -e "     (0) no"
echo -e "     (1) yes"
echo -e ""
read -p "      --> " answer_crystalizer
echo -e ""

case $answer_crystalizer in
"0") ;;
"1")
    afilt=$afilt",crystalizer"
    ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac

echo -e "  ----------------[ $afilt ] \n" >>$logfile

# 	... select audio type.........................................................................................
#
# 	echo -e "      SELECT AUDIO TYPE:"
# 	echo -e "\n"
# 	echo -e "     (m) music"
# 	echo -e "     (v) voice"
# 	echo -e ""
# 	read -p "      --> " answer_type
# 	echo -e ""
#
# 	case $answer_type in
# 	  "m")
#         arg2="-application audio"
# 		;;
# 	  "v")
#         arg2="-application voip"
# 		;;
# 	  *)
# 		echo "Unknown option, exiting..."
# 		exit 3
# 		;;
# 	esac
#     echo -e "  ----------------[ $arg2 ] \n" >> $logfile

# ... select METADATA.........................................................................................
echo -e "  COPY METADATA?"
echo -e "   (0) no"
echo -e "   (1) yes"
echo -e ""
read -p "      --> " include_meta
echo -e ""

case $include_meta in
"0") ;;
"1")
    arg3="-map_metadata 0 -id3v2_version 3"
    ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac

echo -e "  ----------------[ $arg3 ] \n" >>$logfile

# ... select length.........................................................................................
echo -e "  SELECT LENGTH: "
echo -e "   (0) Full file length"
echo -e "   (1) Short preview  [15s]"
echo -e "   (2) Long preview  [60s]"
echo -e ""
read -p "       Select processing length: " answer1

case $answer1 in
"0")
    arg4=""
    arg5=""
    ;;
"1")
    arg4="-ss 00:45 -t 15"
    arg5="[15s]"
    ;;
"2")
    arg4="-ss 00:45 -t 60"
    arg5="[60s]"
    ;;
*)
    echo "Unknown option, exiting..."
    exit 3
    ;;
esac

# LET'S GET TO WORK

afilt_original=$afilt

for f in "$@"; do
    afilt=$afilt_original
    outfile="$f".$arg0b$arg5.$arg0a
    echo -e ""
    echo -e "\n\n........................Processing "$f" ...to... $outfile" | tee -a $logfile
    # first the file-analysis for double pass EBU R128, EXCLUDING SELECTED FILTERS  (in order to meet the exact EBU_R128 specs, the loudnorm should be again performed after applying the filters, but the audio also needs to be normalized before applying the compand filter in order to achieve predictable results....
    #    EBU_R128="loudnorm=I=-23:LRA=7:tp=-1"
    EBU_R128="loudnorm=I=-16:LRA=11:tp=-4"
    ffmpeg -hide_banner -nostats -i "$f" -af $EBU_R128:print_format=json -f null - 2>ffmpeg.log
    tail -n 12 ffmpeg.log >ffmpeg.json
    jq_i=$(jq '.input_i' ffmpeg.json | sed 's/\"//g')
    jq_tp=$(jq '.input_tp' ffmpeg.json | sed 's/\"//g')
    jq_lra=$(jq '.input_lra' ffmpeg.json | sed 's/\"//g')
    jq_thres=$(jq '.input_thresh' ffmpeg.json | sed 's/\"//g')
    jq_offs=$(jq '.target_offset' ffmpeg.json | sed 's/\"//g')
    EBU_R128=$EBU_R128":measured_I=$jq_i:measured_LRA=$jq_lra:measured_tp=$jq_tp:measured_thresh=$jq_thres:offset=$jq_offs"
    afilt=$EBU_R128$afilt
    echo -e "........................using filters: $afilt" | tee -a $logfile
    echo -e ".\n.\n.\n." >>$logfile
    ffmpeg -y -hide_banner -i "$f" $arg4 $arg1 -af $afilt $arg2 $arg3 -metadata encoded_by="$m_encoded_by" -metadata copyright="$m_copyright" -metadata encoder="$m_encoder" "$outfile"
done

echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >>$logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
