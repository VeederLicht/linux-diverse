#!/bin/bash


####################  CHECK RUNCONDITIONS  ###############################
if [[ $# -eq 0 ]]	# Test nr. of arguments
  then
    echo "        No source files specified."
	exit 1
fi

if ! command -v exiftool -ver &>/dev/null; then
    echo "      ERROR: This script relies on the program 'exiftool' (perl-image-exiftool). It could not be found, exiting..."
    exit 2
fi

if ! command -v exiv2 --version &>/dev/null; then
    echo "      ERROR: This script relies on the program 'exiv2'. It could not be found, exiting..."
    exit 2
fi


####################  INITIALISATION & DEFINITIONS  ############################
# Define constants
scriptv="v2.9.0"
sYe="\e[93m"
sNo="\033[1;35m"
basedir="./imgconv_"$(date "+%Y%m%d%H%S")
mkdir -p "${basedir}"
logfile="${basedir}"/$(date +%Y%m%d_%H.%M_)"imgconv.rep"

# User information to inject in metadata
m_comment='Converted with imgconv.sh (veederlicht@github)'


function show_banner {
	clear
	echo -e "\n ${sNo}"
	echo -e "  ===========================================IMGCONV================================================="
	echo -e "                Batch convert images using EXIF-data, Copyleft 2023 VeederLicht"
	echo -e "  --------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------"
	echo -e "\n ${sYe}  NOTE: metadata will be injected, to change it edit this scriptheader!  ${sNo} \n\n"
}

function select_output {
	echo -e "\n"
	echo -e "      SELECT OUTPUT FORMAT: "
	echo -e "     (1) Convert to AVIF"
	echo -e "     (2) Convert to WEBP"
	echo -e "     (3) Convert to HEIC"
	echo -e "     (4) Convert to PNG"
	echo -e "     (5) Convert to JPEG"
	echo -e ""
	read -p "      --> " answer_format
	echo -e ""
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
					append="q45"
				;;
				"2")
					arg9="-quality 60"
					append="q60"
				;;
				"3")
					arg9="-quality 90"
					append="q90"
				;;
			esac
		;;
		"2")
			arg0="webp"
			case $answer_quality in
				"1")
					arg9="-define webp:preset=photo -quality 45"
					append="q45"
				;;
				"2")
					arg9="-define webp:preset=photo -quality 80"
					append="q80"
				;;
				"3")
					arg9="-define webp:preset=photo -quality 95"
					append="q95"
				;;
			esac
		;;
		"3")
			arg0="heic"
			case $answer_quality in
				"1")
					arg9="-quality 25"
					append="q25"
				;;
				"2")
					arg9="-quality 55"
					append="q55"
				;;
				"3")
					arg9="-quality 90"
					append="q90"
				;;
			esac
		;;
		"4")
			arg0="png"
			case $answer_quality in
				"1")
					arg9="-quality 40"
					append="q40"
				;;
				"2")
					arg9="-quality 65"
					append="q65"
				;;
				"3")
					arg9="-quality 95"
					append="q95"
				;;
			esac
		;;
		"5")
			arg0="jpg"
			case $answer_quality in
				"1")
					arg9="-quality 55"
					append="q55"
				;;
				"2")
					arg9="-quality 80"
					append="q80"
				;;
				"3")
					arg9="-quality 95"
					append="q95"
				;;
			esac
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  -----------------Convert to [ $arg0 ] with [ $arg9 ] \n" >> $logfile
}

function prepend_text {
	echo -e "      PREPEND EXIF-DATE TO FILENAMES? "
	echo -e "     (0) no"
	echo -e "     (1) yes"
	echo -e ""
	read -p "      --> " answer_rename
	echo -e ""
	
	case $answer_rename in
		""|"0")
			prepend=false
		;;
		"1")
			prepend=true
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------prepend[ $prepend ]  \n" >> $logfile
}

function append_text {
	echo -e "      APPEND CONVERT-OPTIONS TO FILENAMES? "
	echo -e "     (0) no"
	echo -e "     (1) yes"
	echo -e ""
	read -p "      --> " answer_rename
	echo -e ""
	
	case $answer_rename in
		""|"0")
			append=""
		;;
		"1")
			append="--{${append}}"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------append[ $append ]  \n" >> $logfile
}

function select_denoising {
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
		""|"0")
			arg1=""
			echo -e "  -----------------No noise reduction \n" >> $logfile
			append=$append"n0"
		;;
		"1")
			arg1="-bilateral-blur 3"
			echo -e "  -----------------Noise Reduction: 1 \n" >> $logfile
			append=$append"n1"
		;;
		"2")
			arg1="-kuwahara 0.5 -wavelet-denoise 0.5%"
			echo -e "  -----------------Noise Reduction: 2 \n" >> $logfile
			append=$append"n2"
		;;
		"3")
			arg1="-despeckle"
			echo -e "  -----------------Noise Reduction: 3 \n" >> $logfile
			append=$append"n3"
		;;
		"4")
			arg1="-kuwahara 3"
			echo -e "  -----------------Noise Reduction: 4 \n" >> $logfile
			append=$append"n4"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------arg1[ $arg1 ]  \n" >> $logfile
}

function select_sharpen {
	echo -e "      SELECT SHARPENING LEVEL: "
	echo -e "     (0) none"
	echo -e "     (1) light"
	echo -e "     (2) medium"
	echo -e "     (3) strong"
	echo -e ""
	read -p "      --> " answer_sharpen
	echo -e ""

	case $answer_sharpen in
		""|"0")
			arg2=""
			echo -e "  -----------------Sharpen: 0 \n" >> $logfile
			append=$append"s0"
		;;
		"1")
			arg2="-adaptive-sharpen 0"
			echo -e "  -----------------Sharpen: 1 \n" >> $logfile
			append=$append"s1"
		;;
		"2")
			arg2="-sharpen 0"
			echo -e "  -----------------Sharpen: 2 \n" >> $logfile
			append=$append"s2"
		;;
		"3")
			arg2=" -adaptive-sharpen 0 -sharpen 0"
			echo -e "  -----------------Sharpen: 3 \n" >> $logfile
			append=$append"s3"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------arg2[ $arg2 ]  \n" >> $logfile
}

function select_resize {
	echo -e "      SELECT OUTPUT SIZE: "
	echo -e "     (0) keep original"
	echo -e "     (1) 240p (thumbnail)"
	echo -e "     (2) 480p (SD)"
	echo -e "     (3) 720p (HD)"
	echo -e "     (4) 1440p (QHD)"
	echo -e "     (5) 2160p (UHD)"
	echo -e ""
	read -p "      --> " answer_size
	echo -e ""

	case $answer_size in
		""|"0")
			arg3=""
			echo -e "  -----------------Resize: no \n" >> $logfile
			append=$append"r0"
		;;
		"1")
			arg3="-resize 240x240^ -filter Lanczos"
			echo -e "  -----------------Resize: 240 \n" >> $logfile
			append=$append"r240"
		;;
		"2")
			arg3="-resize 480x480^ -filter Lanczos"
			echo -e "  -----------------Resize: 480 \n" >> $logfile
			append=$append"r480"
		;;
		"3")
			arg3="-resize 720x720^ -filter Lanczos"
			echo -e "  -----------------Resize: 720 \n" >> $logfile
			append=$append"r720"
		;;
		"4")
			arg3="-resize 1440x1440^ -filter Lanczos"
			echo -e "  -----------------Resize: 1440 \n" >> $logfile
			append=$append"r1440"
		;;
		"5")
			arg3="-resize 2160x2160^ -filter Lanczos"
			echo -e "  -----------------Resize: 2160 \n" >> $logfile
			append=$append"r2160"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------arg3[ $arg3 ]  \n" >> $logfile
}

function select_contrast {
	echo -e "      SELECT CONTRAST ENHANCEMENT"
	echo -e "     (0) none, keep original"
	echo -e "     (1) normalize"
	echo -e "     (2) extra contrast"
	echo -e ""
	read -p "      --> " answer_contrast
	echo -e ""

	case $answer_contrast in
		""|"0")
			arg4=""
			echo -e "  -----------------Contrast: none \n" >> $logfile
			append=$append"c0"
		;;
		"1")
			arg4="-normalize"
			echo -e "  -----------------Contrast: 1 \n" >> $logfile
			append=$append"c1"
		;;
		"2")
			arg4="-sigmoidal-contrast 1x20% -sigmoidal-contrast 1x55% -modulate 100,85 -normalize"
			echo -e "  -----------------Contrast: 2 \n" >> $logfile
			append=$append"c2"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------arg4[ $arg4 ] \n" >> $logfile
}


function select_waifu2x {
	echo -e "     USE RESOLUTION ENHANCEMENT (WAIFU2X): "
	echo -e "     (0) no"
	echo -e "     (2) yes, 2X"
	echo -e "     (4) yes, 4X"
	echo -e ""
	read -p "      --> " answer_size
	echo -e ""

	case $answer_size in
		""|"0")
			arg5=""
			echo -e "  -----------------Waifu2x: none \n" >> $logfile
			append=$append"w0"
		;;
		"2")
			arg5=2
			echo -e "  -----------------Waifu2x: 2 \n" >> $logfile
			append=$append"w2"
		;;
		"4")
			arg5=4
			echo -e "  -----------------Waifu2x: 4 \n" >> $logfile
			append=$append"w4"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------arg5[ $arg5 ]  \n" >> $logfile
}

function preserve_meta {
	echo -e "      RETAIN FILE DATE AND METADATA?"
	echo -e "     (0) yes"
	echo -e "     (1) no, erase all tags"
	echo -e ""
	read -p "      --> " retain_meta
	echo -e ""


	if [[ $retain_meta = "0" ]] || [[ $retain_meta = "" ]]; then
		retain_meta=0
		echo -e "  ----------------Retaining file date and metadata \n" >> $logfile
	fi
}


function add_border {
	echo -e "     ADD BORDER (WHITE): "
	echo -e "     (0) no"
	echo -e "     (1) yes, 10px"
	echo -e "     (2) yes, 20px"
	echo -e ""
	read -p "      --> " answer_size
	echo -e ""

	case $answer_size in
		""|"0")
			arg6=""
		;;
		"1")
			arg6="-border 10x10 -bordercolor white"
		;;
		"2")
			arg6="-border 20x20 -bordercolor white"
		;;
		*)
			echo "Unknown option, exiting..."
			exit 3
		;;
	esac
	echo -e "  ----------------arg6[ $arg6 ]  \n" >> $logfile
}


#################### RUN PROGRAM #################################
echo -e "  =======================================================================================================" > "${logfile}"
echo -e "  -------------------------------------imgconv.sh $scriptv logfile---------------------------------------\n" >> "${logfile}"
show_banner
echo -e "\n\n   INPUT FILES:\n"
nFiles=0
for f in "$@"; do
	echo -e "    ✻ ${f}"
	((nFiles++))
done
echo -e "\n   TOTAL COUNT: ${nFiles}\n\n"
select_output
show_banner
prepend_text
show_banner
preserve_meta
show_banner
select_denoising
show_banner
select_sharpen
show_banner
select_contrast
show_banner
select_waifu2x
show_banner
select_resize
show_banner
add_border
show_banner
append_text
show_banner

fCount=0

for f in "$@"
do
	((fCount++))
	echo -e "\n......................Processing file (${fCount} of ${nFiles}):  ${outfile}" | tee -a "${logfile}"
	makeDate=$(exiv2 -Pv -K Exif.Photo.DateTimeDigitized "${f}" | sed 's/://g' | sed 's/ /_/g')
	camMake=$(exiv2 -Pv -K Exif.Image.Make "${f}" | sed 's/://g' | sed 's/ /_/g')
	camModel=$(exiv2 -Pv -K Exif.Image.Model "${f}"| sed 's/://g' | sed 's/ /_/g')
	fileName="${f%.*}"

	if [[ $prepend -eq true ]] && [[ $makeDate != "" ]]; then
		outfile="${basedir}/${makeDate}#${camMake}_${camModel}${append}.${arg0}"
		#if [[ ${makeDate} = "" ]]; then
		#	outfile="${basedir}/${fileName}${append}.${arg0}"
		#fi
	else
		outfile="${basedir}/${fileName}${append}.${arg0}"
	fi
	echo -e ".\n.\n.\n." >> $logfile
	if [[ $arg5 -gt 0 ]]; then
		waifu2x-ncnn-vulkan -i "$f" -o tmp.png -s $arg5
		infile="tmp.png"
	else
		infile="$f"
	fi
	
	convert "$infile" -auto-orient $arg1 $arg3 $arg4 $arg2 $arg6 $arg9 -verbose "$outfile" | tee -a "${logfile}"
	rm -f tmp.png

	if [[ $retain_meta -eq 0 ]]; then
		exiftool -Comment="${m_comment}" -tagsfromfile "$f" "$outfile" | tee -a "${logfile}"
#voor de zekerheid ook touch
		touch -r "$f" "${outfile}"
		exiftool "-FileCreateDate<CreateDate" "-FileModifyDate<CreateDate" "$outfile"
	else
		exiv2 -d a "$outfile" | tee -a "${logfile}"
	fi
done



echo -e "\n\n  ---------------------------------------------END-------------------------------------------------------\n" >> $logfile

echo -e "\n\n\n   Output has been written to: " $logfile
echo -e "\n ${sYe} Finished. ${sNo} \n\n\n"
