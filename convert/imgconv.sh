#!/bin/bash


# User information to inject in metadata
m_composer='Pink Pearl® Digital Media'
m_copyright=''
m_comment=''


clear

# Define constants
scriptv="v1.15"
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
for f in "$@"
do
	echo -n "    ✻ "$f"  ➢➢  "
	ffprobe -i "$f" -v fatal -select_streams v:0 -show_entries stream=height,width,sample_aspect_ratio,display_aspect_ratio,avg_frame_rate -of csv=s=,:p=0:nk=0
done


echo -e "  =======================================================================================================" > $logfile
echo -e "  -------------------------------------imgconv.sh $scriptv logfile---------------------------------------\n" >> $logfile

	base1="./"


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
        arg9=""
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  -----------------Convert to [ $arg0 ] with [ $arg9 ] \n" >> $logfile






	# ... rename output
	echo -e "      RENAME OUTPUT FILES?: "
	echo -e "     (1) no"
	echo -e "     (2) custom text"
	echo -e ""
	read -p "      --> " answer_rename
	echo -e ""


	case $answer_rename in
	  "1")
            fname=""
		;;
	  "2")
            read -p "      Type your custum filename: " fname
            echo -e ""
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg1 ]  \n" >> $logfile





	# ... select noise reduction
	echo -e "\n"
	echo -e "      SELECT DENOISING LEVEL: "
	echo -e "     (1) none"
	echo -e "     (2) light"
	echo -e "     (3) medium"
	echo -e "     (4) strong"
	echo -e "     (5) cartoonize"
	echo -e ""
	read -p "      --> " answer_noise
	echo -e ""

	case $answer_noise in
	  "1")
        echo -e "  -----------------No noise reduction \n" >> $logfile
        arg1=""
		;;
	  "2")
        arg1="-wavelet-denoise 1%"
		;;
	  "3")
        arg1="-enhance"
		;;
	  "4")
        arg1="-bilateral-blur 2 -despeckle"
		;;
	  "5")
        arg1="-kuwahara 4"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg1 ]  \n" >> $logfile




	# ... select sharpening
	echo -e "      SELECT SHARPENING LEVEL: "
	echo -e "     (1) none"
	echo -e "     (2) light"
	echo -e "     (3) medium"
	echo -e "     (4) strong"
	echo -e ""
	read -p "      --> " answer_sharpen
	echo -e ""

	case $answer_sharpen in
	  "1")
        arg2=""
		;;
	  "2")
        arg2="-adaptive-sharpen 2"
		;;
	  "3")
        arg2="-adaptive-sharpen 3"
		;;
	  "4")
        arg2="-unsharp 1 -adaptive-sharpen 2"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg2 ]  \n" >> $logfile





	# ... select resize
	echo -e "      SELECT RESIZING: "
	echo -e "     (1) no, keep original"
	echo -e "     (2) small, max 640p"
	echo -e "     (3) HD, max 1280p"
	echo -e "     (4) 2K, max 2560p"
	echo -e "     (5) 4K, max 3840p"
	echo -e ""
	read -p "      --> " answer_size
	echo -e ""

	case $answer_size in
	  "1")
        arg3=""
		;;
	  "2")
        arg3="-resize 640x640 -filter Point"
		;;
	  "3")
        arg3="-resize 1280x1280 -filter Point"
		;;
	  "4")
        arg3="-resize 2560x2560 -filter Point"
		;;
	  "5")
        arg3="-resize 3840x3840 -filter Point"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg3 ]  \n" >> $logfile





	# ... select contrast
	echo -e "      SELECT CONTRAST ENHANCEMENT"
	echo -e "     (1) none, keep original"
	echo -e "     (2) normalize"
	echo -e "     (3) normalize+"
	echo -e "     (4) mathematic (special)"
	echo -e ""
	read -p "      --> " answer_contrast
	echo -e ""

	case $answer_contrast in
	  "1")
        arg4=""
		;;
	  "2")
        arg4="-normalize"
		;;
	  "3")
        arg4="-sigmoidal-contrast 2x55% -modulate 100,90 -normalize"
		;;
	  "4")
        arg4="-auto-level"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg4 ] \n" >> $logfile





	# ... select METADATA
	echo -e "\n"
	echo -e ""
	read -p "      Copy METADATA? (y/n): " include_meta
	echo -e ""


# LET'S GET TO WORK

counter=1

for f in "$@"
do
    if [[ $fname = "" ]]; then outfile="$f".$arg0; else outfile="$fname"[$counter].$arg0; fi
    counter=$((counter+1))
	echo -e " "
	echo -e "........................Processing "$f"...to...$outfile................"
	echo -e ".\n.\n.\n." >> $logfile
    convert "$f" -auto-orient $arg1 $arg2 $arg3 $arg4 $arg9 -verbose "$outfile"
    if [ $include_meta = "y" ]; then
        exiv2 -ea- "$f" | exiv2 -ia- "$outfile" &>> $logfile
    fi
done



echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
