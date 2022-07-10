#!/bin/bash



# Define constants
scriptv="v1.1.0"
sYe="\e[93m"
sNo="\033[1;35m"
t1="\t"
t2="\t\t"
t3="\t\t\t"
tp="                --» "

########### PRERUN TESTS ######################
## Test if run as root/sudo
# if (( $EUID != 0 )); then
#     echo "...............Please run as root"
#     exit
# fi
#
## Test nr. of arguments
# if [ $# -eq 0 ]; then
#     echo "...............No source files specified."
#     exit 2
# fi
#
# # Test file exists
# if test ! -f "$1"; then
#     echo "...............File $1 does not exist."
#     exit 3
# fi



########### FUNCTION DEFINITIONS ######################
function show_banner {
        clear
        echo -e "\n ${sNo}"
        echo -e "${t1}======================================================================================================="
        echo -e "${t3}Batch change mimetype associations, RickOrchard 2022, copyleft"
        echo -e "${t1}--------------------------------------------${sYe} $scriptv ${sNo}----------------------------------------------------\n\n"
}

function ask_category {
	    echo -e "${t2}Change program associations for what filetype?\n"
	    echo -e "${t3}[0] Audio"
	    echo -e "${t3}[1] Image"
	    echo -e "${t3}[2] Video"
	    echo -e "${t3}[3] Text"
        read -p "${tp}" answer1

	    case $answer1 in
	      "0")
		    category="audio/"
		    ;;
	      "1")
		    category="image/"
		    ;;
	      "2")
		    category="video/"
		    ;;
	      "3")
		    category="text/"
		    ;;
	      *)
		    echo "Invalid answer, exiting..."
		    exit 6
		    ;;
	    esac
}

function select_candidate {
        appsdir="/usr/share/applications/"
        mimedir="/usr/share/mime/"
        aCandidates=()

        for filename in ${appsdir}*.desktop; do     # grab all .desktop apps that support the selected mimetype
            grepresult=$(cat $filename  | grep MimeType= | grep $category)
            if [ $? == 0 ]; then  # if previous exit code is ok
                aCandidates+=($filename)
            fi
        done

        echo -e "${t2}Select which program to use to open all (supported) ${sYe} $category ${sNo} mimetypes:\n"
        n=0
        for c in ${aCandidates[@]}; do      # list all candidates, showing only the basename
            echo -e "${t3}[$n]\t$(basename $c)"
            ((n++))
        done
        read -p "${tp}"  selection

        #aCandidates+=($(basename $filename))
        #openWith=${aCandidates[selection]}
}

function change_mime {
        echo -e "${t2}Associating all supported types with selected application:\n"

        aSupportedTypes=(`grep -Po 'MimeType=\K.*' ${aCandidates[$selection]} | tr ';' ' '`)
        sSelectedApp=$(basename ${aCandidates[$selection]})
        for c in ${aSupportedTypes[@]}; do      # list all supported filetypes
            echo -e "${t3}${sYe} $c » ${sNo}"
            `xdg-mime default $sSelectedApp $c`
        done
}

# Reading line-by-line from a file
# n=1
# while read line; do
#     echo "Line No. $n : $line"
#     ((n++))
# done < $1


###################### RUN! ######################
show_banner
ask_category
show_banner
select_candidate
show_banner
change_mime
echo -e "\n${t1}DONE\n"
