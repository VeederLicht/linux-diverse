#!/bin/bash


# User information to inject in metadata
m_composer=''
m_copyright=''
m_comment='Converted with imgconv.sh (RickOrchard@Github)'


clear

# Define constants
scriptv="v1.30"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"imgconv.rep"

# Show banner
echo -e "\n ${sNo}"
echo -e "  ======================================================================================================="
echo -e "                 Batch convert (old) video's, degraining  + scaling, RickOrchard 2021, no copyright"
echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"
echo -e "\n ${sYe}  NOTE: metadata will be injected, to change it edit this scriptheader!  ${sNo} \n\n"

# Test nr. of arguments
if [ $# -eq 0 ]
  then
    echo "        No source files specified."
	exit 2
fi

# !!!! ARGUMENTS IN DOUBLE QOUTES TO AVOID PROBLEMS WITH SPACES IN FILENAMES!!! https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
#for f in "$@"
#do
#	echo -n "    ✻ "$f"  ➢➢  "
#	ffprobe -i "$f" -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio,avg_frame_rate -of csv=s=,:p=0:nk=0
#done


echo -e "  =======================================================================================================" > $logfile
echo -e "  -------------------------------------imgconv.sh $scriptv logfile---------------------------------------\n" >> $logfile

	mkdir ./imgconv  2> /dev/null
	base1="./imgconv/"


	# ... select output format
	echo -e "\n"
	echo -e "      SELECT OUTPUT FORMAT: "
	echo -e "     (1) Convert to AVIF (av1, no support for metadata)"
	echo -e "     (2) Convert to WEBP"
	echo -e "     (3) Convert to HEIC"
	echo -e "     (4) Convert to PNG"
	echo -e ""
	read -p "      --> " answer_format
	echo -e ""
	

	clear
	# ... select quality
	echo -e "      SELECT QUALITY: "
	echo -e "     (1) low quality"
	echo -e "     (2) medium quality"
	echo -e "     (3) high quality"
	echo -e ""
	read -p "      --> " answer_quality
	echo -e ""

	case $answer_format in
	  "1")
        arg0="avif"
        case $answer_quality in
          "1")
                arg9="-quality 45"
            ;;

          "2")
                arg9="-quality 75"
            ;;

          "3")
                arg9="-quality 100"
            ;;
        esac
		;;
	  "2")
        arg0="webp"
        case $answer_quality in
          "1")
                arg9="-quality 50"
            ;;

          "2")
                arg9="-quality 90"
            ;;

          "3")
                arg9="-quality 100"
            ;;
        esac
		;;
	  "3")
        arg0="heic"
        case $answer_quality in
          "1")
                arg9="-quality 35"
            ;;

          "2")
                arg9="-quality 55"
            ;;

          "3")
                arg9="-quality 100"
            ;;
        esac
		;;
		"4")
        arg0="png"
        case $answer_quality in
          "1")
                arg9="-quality 40"
            ;;

          "2")
                arg9="-quality 65"
            ;;

          "3")
                arg9="-quality 100"
            ;;
        esac
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  -----------------Convert to [ $arg0 ] with [ $arg9 ] \n" >> $logfile





	clear
	# ... rename output
	echo -e "      APPEND CUSTOM TEXT TO FILENAMES? "
	echo -e "     (0) no"
	echo -e "     (1) yes"
	echo -e ""
	read -p "      --> " answer_rename
	echo -e ""


	case $answer_rename in
	  "0")
            fname=""
		;;
	  "1")
            read -p "      Type your custum filename: " fname
            echo -e ""
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg1 ]  \n" >> $logfile




	clear
	# ... select noise reduction
	echo -e "\n"
	echo -e "      SELECT DENOISING LEVEL: "
	echo -e "      (the smaller the image, the stronger the denoising effects)"
	echo -e "     (0) none"
	echo -e "     (1) low"
	echo -e "     (2) medium"
	echo -e "     (3) very high"
	echo -e "     (4) cartoonize"
	echo -e ""
	read -p "      --> " answer_noise
	echo -e ""

	case $answer_noise in
	  "0")
        echo -e "  -----------------No noise reduction \n" >> $logfile
        arg1=""
		;;
	  "1")
        arg1="-bilateral-blur 3"
		;;
	   "2")
        arg1="-kuwahara 0.5 -wavelet-denoise 0.5%"
		;;
	  "3")
        arg1="-despeckle"
		;;
	  "4")
        arg1="-kuwahara 3"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg1 ]  \n" >> $logfile




	clear
	# ... select sharpening
	echo -e "      SELECT SHARPENING LEVEL: "
	echo -e "     (0) none"
	echo -e "     (1) light"
	echo -e "     (2) medium"
	echo -e "     (3) strong"
	echo -e ""
	read -p "      --> " answer_sharpen
	echo -e ""

	case $answer_sharpen in
	  "0")
        arg2=""
		;;
	  "1")
        arg2="-adaptive-sharpen 0"
		;;
	  "2")
        arg2="-sharpen 0"
		;;
	  "3")
        arg2=" -adaptive-sharpen 0 -sharpen 0"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg2 ]  \n" >> $logfile



	clear
	# ... select resize
	echo -e "      SELECT RESIZING: "
	echo -e "     (0) no, keep original"
	echo -e "     (1) 320p (thumbnail)"
	echo -e "     (2) 720p (SD)"
	echo -e "     (3) 1280p (HD)"
	echo -e "     (4) 2560p (2K)"
	echo -e "     (5) 3840p (4K)"
	echo -e ""
	read -p "      --> " answer_size
	echo -e ""

	case $answer_size in
        "0")
        arg3=""
		;;
        "1")
        arg3="-resize 320x320 -filter Lanczos"
		;;
	   "2")
        arg3="-resize 720x720 -filter Lanczos"
		;;
	   "3")
        arg3="-resize 1280x1280 -filter Lanczos"
		;;
	   "4")
        arg3="-resize 2560x2560 -filter Lanczos"
		;;
	   "5")
        arg3="-resize 3840x3840 -filter Lanczos"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg3 ]  \n" >> $logfile



	clear
	# ... select contrast
	echo -e "      SELECT CONTRAST ENHANCEMENT"
	echo -e "     (0) none, keep original"
	echo -e "     (1) normalize"
	echo -e "     (2) extra contrast"
	echo -e ""
	read -p "      --> " answer_contrast
	echo -e ""

	case $answer_contrast in
	  "0")
        arg4=""
		;;
	  "1")
        arg4="-normalize"
		;;
	  "2")
        arg4="-sigmoidal-contrast 1x20% -sigmoidal-contrast 1x55% -modulate 100,85 -normalize"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg4 ] \n" >> $logfile



	clear
	# ... preserve METADATA, if no -> actively erases ALL metadata!
	echo -e "\n"
	echo -e ""
	echo -e "      Copy METADATA?"
	echo -e "     (0) no, clean all tags"
	echo -e "     (1) yes"
	echo -e ""
	read -p "      --> " include_meta
	echo -e ""

    if [ $include_meta = "1" ]; then
		echo -e "  ----------------Including metadata \n" >> $logfile
    fi





# LET'S GET TO WORK

counter=1

for f in "$@"
do
    if [[ $fname = "" ]]; then outfile="$base1""$f".$arg0; else outfile="$base1""$f""$fname".$arg0; fi
    counter=$((counter+1))
	echo -e " "
	echo -e "........................Processing "$f"...to...$outfile................"
	echo -e ".\n.\n.\n." >> $logfile
    convert "$f" -auto-orient $arg1 $arg3 $arg4 $arg2 $arg9 -verbose "$outfile"
    if [ $include_meta = "1" ]
    then
        exiv2 -ea- "$f" | exiv2 -ia- "$outfile" &>> $logfile
    else
    	exiv2 -d a "$outfile" &>> $logfile
    fi
done



echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
