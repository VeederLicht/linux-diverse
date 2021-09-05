#!/bin/bash


# User information to inject in metadata
m_composer='Pink Pearl® Digital Media'
m_copyright=''
m_comment=''


clear

# Define constants
scriptv="v0.98"
sYe="\e[93m"
sNo="\033[1;35m"
logfile=$(date +%Y%m%d_%H.%M_)"imgconv.rep"

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
	echo -e "     (a) Convert to avif (av1, no support for metadata)"
	echo -e "     (w) Convert to webp"
	echo -e "     (j) Convert to jpg"
	echo -e ""
	read -p "      --> " answer_format
	echo -e ""
	

	# ... select quality
	echo -e "      SELECT QUALITY: "
	echo -e "     (l) low quality"
	echo -e "     (m) medium quality"
	echo -e "     (h) high quality"
	echo -e ""
	read -p "      --> " answer_quality
	echo -e ""

	case $answer_format in
	  "a")
        arg0="avif"
        case $answer_quality in
          "l")
                arg9="-quality 45"
            ;;

          "m")
                arg9="-quality 80"
            ;;

          "h")
                arg9="-quality 100"
            ;;
        esac
		;;
	  "w")
        arg0="webp"
        case $answer_quality in
          "l")
                arg9="-quality 50"
            ;;

          "m")
                arg9="-quality 90"
            ;;

          "h")
                arg9="-quality 100"
            ;;
        esac
		;;
	  "j")
        arg0="jpg"
        case $answer_quality in
          "l")
                arg9="-quality 55"
            ;;

          "m")
                arg9="-quality 95"
            ;;

          "h")
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






	# ... rename output
	echo -e "      RENAME OUTPUT FILES?: "
	echo -e "     (n) no"
	echo -e "     (c) custom text"
	echo -e ""
	read -p "      --> " answer_rename
	echo -e ""


	case $answer_rename in
	  "n")
            fname=""
		;;
	  "c")
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
	echo -e "     (n) none"
	echo -e "     (l) light"
	echo -e "     (m) medium"
	echo -e "     (s) strong"
	echo -e "     (v) very strong"
	echo -e "     (c) cartoonize"
	echo -e ""
	read -p "      --> " answer_noise
	echo -e ""

	case $answer_noise in
	  "n")
        echo -e "  -----------------No noise reduction \n" >> $logfile
        arg1=""
		;;
	  "l")
        arg1="-bilateral-blur 3"
		;;
	  "m")
        arg1="-wavelet-denoise 1%"
		;;
	  "s")
        arg1="-enhance"
		;;
	  "v")
        arg1="-despeckle"
		;;
	  "c")
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
	echo -e "     (n) none"
	echo -e "     (l) light"
	echo -e "     (m) medium"
	echo -e "     (s) strong"
	echo -e ""
	read -p "      --> " answer_sharpen
	echo -e ""

	case $answer_sharpen in
	  "n")
        arg2=""
		;;
	  "l")
        arg2="-adaptive-sharpen 1"
		;;
	  "m")
        arg2="-adaptive-sharpen 2"
		;;
	  "s")
        arg2="-unsharp 1"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg2 ]  \n" >> $logfile





	# ... select resize
	echo -e "      SELECT RESIZING: "
	echo -e "     (n) no, keep original"
	echo -e "     (s) small, max 640p"
	echo -e "     (h) HD, max 1280p"
	echo -e "     (2) 2K, max 2560p"
	echo -e "     (4) 4K, max 3840p"
	echo -e ""
	read -p "      --> " answer_size
	echo -e ""

	case $answer_size in
	  "n")
        arg3=""
		;;
	  "s")
        arg3="-resize 640x640 -filter Lanczos"
		;;
	  "h")
        arg3="-resize 1280x1280 -filter Lanczos"
		;;
	  "2")
        arg3="-resize 2560x2560 -filter Lanczos"
		;;
	  "4")
        arg3="-resize 3840x3840 -filter Lanczos"
		;;
	  *)
		echo "Unknown option, exiting..."
		exit 3
		;;
	esac
    echo -e "  ----------------[ $arg3 ]  \n" >> $logfile





	# ... select contrast
	echo -e "      SELECT CONTRAST NORMALIZATION"
	echo -e "     (n) none, keep original"
	echo -e "     (N) natural"
	echo -e "     (M) mathematic"
	echo -e ""
	read -p "      --> " answer_contrast
	echo -e ""

	case $answer_contrast in
	  "n")
        arg4=""
		;;
	  "N")
        arg4="-normalize"
		;;
	  "M")
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
    if [ $fname = "" ]; then outfile="$f".$arg0; else outfile="$fname"[$counter].$arg0; fi
    counter=$((counter+1))
	echo -e " "
	echo -e "........................Processing "$f"...to...$outfile................"
	echo -e ".\n.\n.\n." >> $logfile
    magick "$f" -auto-orient $arg1 $arg2 $arg3 $arg4 $arg9 -verbose "$outfile"
    if [ $include_meta = "y" ]; then
        exiv2 -ea- "$f" | exiv2 -ia- "$outfile" &>> $logfile
    fi
done



echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
