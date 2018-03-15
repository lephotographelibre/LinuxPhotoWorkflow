#!/usr/bin/env bash

# AUTHOR:   Andreas Betschart. https://github.com/Kakupakat/fotoprep
#           Adapting and further developing some code by Pat David from:
#           https://discuss.pixls.us/t/annotation-with-imagemagick-watermark-ish
# DATE:     23.01.2018.
# PROGRAM:  fotoprep
  VERSION=0.9.9
# USAGE:    Start the program from the command line and add all the images you want to edit as arguments.
# PURPOSE:  Prepare photos for use on the Internet, tablets, phones, etc.
#           1. Convert and resize images (even XCF and RAW files).
#           2. Remove tags, add copyright tags.
#           3. Add a watermark or an annotation.
# REASON:   Digikam's batch tool can't convert XCF or RAW files. So you will have to do that separately anyway.
# FILES:    fotoprep, the watermark file and the logo(s) for the annotation.
#           "$CONFIG" will be created by running the fotoprep setup (fotoprep -s).

##############################################################################
# WARNING: ONLY TOUCH STUFF BELOW THIS POINT IF YOU KNOW WHAT YOU ARE DOING. #
##############################################################################

#---------------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------------

directory=fotoprep_
workingDirectory=$$
theDate=$(date +%Y:%m:%d)
theYear=${theDate:0:4}
config="fotoprep.cfg"
sharpeningAmount=1
sharpeningThreshold=0.065
colorRegex='^#(([0-9a-fA-F]{2}){3}|([0-9a-fA-F]){3})$'
rawFormats=(\
'.nef','.NEF' \
'.raf','.RAF' \
'.arw','.ARW' \
'.orf','.ORF' \
'.dng','.DNG' \
'.crw','.CRW' \
'.cr2','.CR2' \
'.raw','.RAW' \
'.nrw','.NRW' \
'.pef','.PEF' \
'.srw','.SRW' \
'.iiq','.IIQ' \
'.3fr','.3FR' \
'.dcr','.DCR' \
'.fff','.FFF' \
'.kdc','.KDC' \
'.mef','.MEF' \
'.mos','.MOS' \
'.mrw','.MRW' \
'.rw2','.RW2' \
'.rwl','.RWL' \
'.rwz','.RWZ' \
'.sr2','.SR2' \
'.srf','.SRF' \
'.x3f','.X3F' \
)
# Padding for the menu
padding=$(printf '%0.1s' "."{1..60})
paddingLength=60

#---------------------------------------------------------------------------
# Define colors
#---------------------------------------------------------------------------
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
# printf "Some ${red}colored${noColor} text here\n"

red='\033[0;31m'
cyan='\033[0;36m'
lightCyan='\033[1;36m'
orange='\033[0;33m'
green='\033[0;32m'
lightPurple='\033[1;35m'
yellow='\033[1;33m'
noColor='\033[0m'
darkGray='\033[1;30m'

#---------------------------------------------------------------------------
# Functions.
#---------------------------------------------------------------------------

spinner()
{
    tput civis

        while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do

            for x in '|' '/' '-' '\'; do

                printf "${yellow}\b$x \b"

                sleep 0.1

            done

        done

        printf "${noColor}\n"

    tput cnorm
}

usage()
{
    printf " ${yellow}fotoprep Usage:${noColor}\n"
    printf " fotoprep filename(s) ${lightCyan}->${noColor} Prepare photos for use on the Internet,\n"
    printf "                         tablets, phones, etc.\n"
    printf " fotoprep -s          ${lightCyan}->${noColor} Run the setup program to set and/or\n"
    printf "                         change options.\n"
    printf " fotoprep -v          ${lightCyan}->${noColor} Print the version number of fotoprep.\n"
    printf " fotoprep             ${lightCyan}->${noColor} Print this help.\n"
    exit 0
}


#---------------------------------------------------------------------------
# Check if the necessary programs are installed.
#---------------------------------------------------------------------------

command -v convert >/dev/null 2>&1 || { echo >&2 "It seems ImageMagick is not installed, please install it in order to proceed."; exit 1;}
command -v gimp >/dev/null 2>&1 || { echo >&2 "It seems GIMP is not installed, please install it in order to proceed."; exit 1;}
command -v exiftool >/dev/null 2>&1 || { echo >&2 "It seems Exiftool is not installed, please install it in order to proceed."; exit 1;}
command -v rawtherapee >/dev/null 2>&1 || { echo >&2 "It seems RawTherapee is not installed, please install it in order to proceed."; exit 1;}

#---------------------------------------------------------------------------
# Were any parameters given?
#---------------------------------------------------------------------------

if [[ $# -eq 0 ]]; then

    usage

fi

# Print the version of fotoprep
if [[ $@ == "-v" ]]; then echo " fotoprep version: "$VERSION"" && exit 0 ; fi


#---------------------------------------------------------------------------
# Find out where the configuration file is.
#---------------------------------------------------------------------------

mySource="${BASH_SOURCE[0]}"
while [ -h "$mySource" ]; do # resolve $mySource until the file is no longer a symlink.
  myPath="$( cd -P "$( dirname "$mySource" )" && pwd )"
  mySource="$(readlink "$mySource")"
  [[ $mySource != /* ]] && mySource="$myPath/$mySource" # if $mySource was a relative symlink, we need to resolve it relative to the path where the symlink file was located.
done
myPath="$( cd -P "$( dirname "$mySource" )" && pwd )"

#---------------------------------------------------------------------------
# Run the setup?
#---------------------------------------------------------------------------

if [[ $@ == "-s" ]]; then

    # Some sensible default values
    landscape=0.20
    portrait=0.35
    position=southeast
    horizontalOffset=0.0075
    verticalOffset=0.0075
    multiplier=0.05
    maxWatermarkHeight=0.20
    logoMultiplier=0.04
    pointSizeMultiplier=0.020
    fontDark="#191919"
    fontBright="#E6E6E6"
    defaultFill="#232323"
    defaultFontColor="#ffff00"
    offset=0.005
    widthPreset1=960
    heightPreset1=720
    widthPreset2=1080
    heightPreset2=608
    widthPreset3=1080
    heightPreset3=566
    widthPreset4=1152
    heightPreset4=768
    widthPreset5=1280
    heightPreset5=800
    widthPreset6=1200
    heightPreset6=780
    preset1="Facebook"
    preset2="Google Plus"
    preset3="Instagram"
    preset4="my own website"
    preset5="tablets and telephones"
    preset6="Pixls.us"

    clear
    printf "${red}----------------------------------------------------------------------${noColor}\n"
    printf " ${darkGray}Here we will determine the standart settings for fotoprep.${noColor}\n"
    printf " ${darkGray}Run this before using fotoprep or whenever you want to change ${noColor}\n"
    printf " ${darkGray}any of the standard settings. The predifined values will appear${noColor}\n"
    printf " ${darkGray}in ${green}(green)${darkGray}.${noColor}\n"
    printf "${red}----------------------------------------------------------------------${noColor}\n"
    printf "\n"
    printf " [01/16] ${yellow}Watermark File${noColor}\n"
    printf " The absolute path to the watermark file.\n"
    printf " For reasons of quality, and because it allows transparency, the\n"
    printf " watermark should be a png file.\n"

    printf " Enter the desired ${orange}path${noColor}"
    while read -e -p ": " choice; do

        if [[ ! ${choice:0:1} == '/' ]] || [[ ! -f ${choice} ]]; then

            printf " Please enter the full path"

        else

            watermark="$choice"; break

        fi

    done

    clear
    printf " [02/16] ${yellow}Watermark Landscape${noColor}\n"
    printf " The width of the watermark for an image in landscape orientation.\n"
    printf " A value between 0.01 and 1.\n"
    printf " 1 corresponds to the full width of the image.\n"
    printf " Enter the desired ${orange}width${noColor} ${green}($landscape)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            landscape=$landscape; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0.01 && $choice <=1" | bc -l | grep -q 1; then

            landscape="$choice"; break


        else

            printf " Please enter a value between 0.01 and 1 ${green}($landscape)${noColor}"


        fi

    done

    clear
    printf " [03/16] ${yellow}Watermark Portrait${noColor}\n"
    printf " The width of the watermark for an image in portrait orientation.\n"
    printf " A value between 0.01 and 1.\n"
    printf " 1 corresponds to the full width of the image.\n"
    printf " Enter the desired ${orange}width${noColor} ${green}($portrait)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            portrait=$portrait; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0.01 && $choice <=1" | bc -l | grep -q 1; then

            portrait="$choice"; break


        else

            printf " Please enter a value between 0.01 and 1 ${green}($portrait)${noColor}"


        fi

    done

    clear
    printf " [04/16] ${yellow}Watermark Maximum Height${noColor}\n"
    printf " The maximum height of the watermark. This is comes into play when an\n"
    printf " image is extremely wide.\n"
    printf " A value between 0.01 and 1.\n"
    printf " 1 corresponds to the full height of the image.\n"
    printf " Enter the desired ${orange}maximum height${noColor} ${green}($maxWatermarkHeight)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            maxWatermarkHeight=$maxWatermarkHeight; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0.01 && $choice <=1" | bc -l | grep -q 1; then

            maxWatermarkHeight="$choice"; break


        else

            printf " Please enter a value between 0.01 and 1 ${green}($maxWatermarkHeight)${noColor}"


        fi

    done

    clear
    printf " [05/16] ${yellow}Watermark Position${noColor}\n"
    printf " ${cyan}(a)${noColor} Center\n"
    printf " ${cyan}(b)${noColor} East\n"
    printf " ${cyan}(c)${noColor} Northeast\n"
    printf " ${cyan}(d)${noColor} North\n"
    printf " ${cyan}(e)${noColor} Northwest\n"
    printf " ${cyan}(f)${noColor} Southeast\n"
    printf " ${cyan}(g)${noColor} South\n"
    printf " ${cyan}(h)${noColor} Southwest\n"
    printf " ${cyan}(i)${noColor} West\n"
    printf " The position of the watermark on the image.\n"
    printf " Enter the desired ${orange}position${noColor} ${green}(f)${noColor}: "
    while read choice; do
        case "$choice" in
            "") position=$position; break ;;
            [aA]) position=center; break ;;
            [bB]) position=east; break ;;
            [cC]) position=northeast; break ;;
            [dD]) position=north; break ;;
            [eE]) position=northwest; break ;;
            [fF]) position=southeast; break ;;
            [gG]) position=south; break ;;
            [hH]) position=southwest; break ;;
            [iI]) position=west; break ;;
            *) printf " Please enter a letter from a to i ${green}(f)${noColor}: " ;;
        esac
    done

    clear
    printf " [06/16] ${yellow}Watermark Offset${noColor}\n"
    printf " A positive offset always moves the watermark towards the center of\n"
    printf " the image. If the watermark is already centered, the horizontal\n"
    printf " offset will move it to the right and the vertical offset will move\n"
    printf " it down.\n"
    printf " The offset in pixels will be calculated as offset x width or height\n"
    printf " of the image. Values range from -0.9999 to 0.9999.\n"
    printf " Please enter negative numbers with a minus sign; positive numbers\n"
    printf " without a plus sign.\n"
    printf " Enter the desired ${orange}horizontal offset${noColor} ${green}($horizontalOffset)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            horizontalOffset=$horizontalOffset; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=-0.9999 && $choice <=0.9999" | bc -l | grep -q 1; then

            horizontalOffset="$choice"; break

        else

            printf " Please enter a value between -0.9999 and 0.9999 ${green}($horizontalOffset)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}vertikal offset${noColor} ${green}($verticalOffset)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            verticalOffset=$verticalOffset; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=-0.9999 && $choice <=0.9999" | bc -l | grep -q 1; then

            verticalOffset="$choice"; break

        else

            printf " Please enter a value between -0.9999 and 0.9999 ${green}($verticalOffset)${noColor}"

        fi

    done

    clear
    printf " [07/16] ${yellow}Annotation Paths${noColor}\n"
    printf " Absolute paths to the logos for the annotation bar.\n"
    printf " When the color of the annotation footer is calculated as an average\n"
    printf " of the colors of the image, for very bright images we will need a\n"
    printf " dark logo and vice versa.\n"
    printf " For reasons of quality, and because it allows transparency,\n"
    printf " the logo should be a png file.\n"
    printf " Enter the desired ${orange}path for the dark logo${noColor}"
    while read -e -p ": " choice; do

        if [[ ! ${choice:0:1} == '/' ]] || [[ ! -f ${choice} ]]; then

            printf " Please enter the full path"

        else

            logoDark="$choice"; break

        fi

    done

    printf " Enter the desired ${orange}path for the bright logo${noColor}"

    while read -e -p ": " choice; do

        if [[ ! ${choice:0:1} == '/' ]] || [[ ! -f ${choice} ]]; then

            printf " Please enter the full path"

        else

            logoBright="$choice"; break

        fi

    done

    clear
    printf " [08/16] ${yellow}Annotation Font Colors${noColor}\n"
    printf " The color of the annotation background is calculated as an average of\n"
    printf " the colors of the image. For very bright images we will need a dark\n"
    printf " font and vice versa, all in hex (#......) notation.\n"
    printf " Enter the desired ${orange}dark font color${noColor} ${green}("$fontDark")${noColor}"

    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            fontDark=$fontDark; break

        elif [[ ! $choice =~ $colorRegex ]]; then

            printf " ${red}This is not a proper hex color code.${noColor} Please try again ${green}("$fontDark")${noColor}"

        else

            fontDark="$choice"; break

        fi

    done

    printf " Enter the desired ${orange}bright font color${noColor} ${green}("$fontBright")${noColor}"

    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            fontBright=$fontBright; break

        elif [[ ! $choice =~ $colorRegex ]]; then

            printf " ${red}This is not a proper hex color code.${noColor} Please try again ${green}("$fontBright")${noColor}"

        else

            fontBright="$choice"; break
        fi

    done

    clear
    printf " [09/16] ${yellow}Annotation Background Color, Logo and Font Color${noColor}\n"
    printf " Above you chose logos and font colors that will be applied depending\n"
    printf " on the brightness of the annotation background color which was\n"
    printf " calculated as an average of the colors of the image. Here you can\n"
    printf " choose a fixed background color, a fixed logo and a fixed font color.\n"
    printf " Colors are to be entered in hex (#......) notation.\n"
    printf " Enter the desired ${orange}fixed background color${noColor} ${green}($defaultFill)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            defaultFill=$defaultFill; break

        elif [[ ! $choice =~ $colorRegex ]]; then

            printf " ${red}This is not a proper hex color code.${noColor} Please try again ${green}("$defaultFill")${noColor}"

        else

            defaultFill="$choice"; break

        fi

    done

    printf " Enter the desired ${orange}fixed font color${noColor} ${green}("$defaultFontColor")${noColor}"

    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            defaultFontColor=$defaultFontColor; break

        elif [[ ! $choice =~ $colorRegex ]]; then

            printf " ${red}This is not a proper hex color code.${noColor} Please try again ${green}("$defaultFontColor")${noColor}"

        else

            defaultFontColor="$choice"; break

        fi

    done

    printf " Enter the desired ${orange}path for the fixed logo${noColor}"

    while read -e -p ": " choice; do

        if [[ ! ${choice:0:1} == '/' ]] || [[ ! -f ${choice} ]]; then

            printf " Please enter the full path"

        else

            defaultLogo="$choice"; break

        fi

    done

    clear
    printf " [10/16] ${yellow}Annotation Font${noColor}\n"
    printf " Which font should appear in the annotations?\n"
    printf " If you choose to see a list of fonts, it will open in the pager\n"
    printf " 'less', to close it type a 'q'.\n"
    printf " Would you like to see the list of fonts on your system ${orange}[y/n]${green}(n)${noColor}" ; read -e -p "? " fontChoice

    if [[ ${fontChoice} = [yY]* ]]; then

        convert -list font | grep "Font:" | less

    fi

    printf " Enter the name of the ${orange}font${noColor}" ; read -e -p ": " textFont

    clear
    printf " [11/16] ${yellow}Annotation Footer Size${noColor}\n"
    printf " The percentage of the image height the footer height will be.\n"
    printf " Values range from 0.001 to 0.999.\n"
    printf " Enter the desired ${orange}footer size${noColor} ${green}($multiplier)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            multiplier=$multiplier; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0.001 && $choice <=0.999" | bc -l | grep -q 1; then

            multiplier=$choice; break

        else

            printf " Please enter a value between 0.001 and 0.999 ${green}($multiplier)${noColor}"

        fi

    done

    clear
    printf " [12/16] ${yellow}Annotation Logo Size${noColor}\n"
    printf " The percentage of the image height the logo height will be.\n"
    printf " This should not be bigger than the footer size.\n"
    printf " Values range from 0.001 to 0.999.\n"
    printf " Enter the desired ${orange}annotation logo size${noColor} ${green}($logoMultiplier)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            logoMultiplier=$logoMultiplier; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0.001 && $choice <=0.999" | bc -l | grep -q 1; then

            logoMultiplier="$choice"; break

        else

            printf " Please enter a value between 0.001 and 0.999 ${green}($logoMultiplier)${noColor}"

        fi

    done

    clear
    printf " [13/16] ${yellow}Annotation Point Size${noColor}\n"
    printf " The size of the font in relation to the image size.\n"
    printf " Values range from 0.001 to 0.999.\n"
    printf " Enter the desired ${orange}annotation point size${noColor} ${green}($pointSizeMultiplier)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            pointSizeMultiplier=$pointSizeMultiplier; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0.001 && $choice <=0.999" | bc -l | grep -q 1; then

            pointSizeMultiplier="$choice"; break

        else

            printf " Please enter a value between 0.001 and 0.999 ${green}($pointSizeMultiplier)${noColor}"

        fi

    done

    clear
    printf " [14/16] ${yellow}Annotation Offset${noColor}\n"
    printf " How far to indent the logo and text relative to the image width.\n"
    printf " Values range from 0.001 to 0.999.\n"
    printf " Enter the desired ${orange}annotation offset${noColor} ${green}($offset)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            offset=$offset; break

        elif [[ "$choice" =~ ^[[:digit:].e+-]+$ ]] && echo "$choice>=0 && $choice <=0.999" | bc -l | grep -q 1; then

            offset="$choice"; break

        else

            printf " Please enter a value between 0 and 0.999 ${green}($offset)${noColor}"

        fi

    done

    clear
    printf " [15/16] ${yellow}Definition of Presets${noColor}\n"

    printf " Enter the desired ${orange}Name of Preset 1${noColor} ${green}(${preset1})${noColor}"
    read -e -p ": " choice
    if [[ $choice = "" ]]; then

        preset[1]=$preset1

    else

        preset[1]=$choice

    fi

    printf " Enter the desired ${orange}width in pixels${noColor} ${green}($widthPreset1)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            widthPreset1=$widthPreset1; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            widthPreset1="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($widthPreset1)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}height in pixels${noColor} ${green}($heightPreset1)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            heightPreset1=$heightPreset1; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            heightPreset1="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($heightPreset1)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}Name of Preset 2${noColor} ${green}(${preset2})${noColor}"
    read -e -p ": " choice
    if [[ $choice = "" ]]; then

        preset[2]=$preset2

    else

        preset[2]=$choice

    fi

    printf " Enter the desired ${orange}width in pixels${noColor} ${green}($widthPreset2)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            widthPreset2=$widthPreset2; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            widthPreset2="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($widthPreset2)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}height in pixels${noColor} ${green}($heightPreset2)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            heightPreset2=$heightPreset2; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            heightPreset2="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($heightPreset2)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}Name of Preset 3${noColor} ${green}(${preset3})${noColor}"
    read -e -p ": " choice
    if [[ $choice = "" ]]; then

        preset[3]=$preset3

    else

        preset[3]=$choice

    fi

    printf " Enter the desired ${orange}width in pixels${noColor} ${green}($widthPreset3)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            widthPreset3=$widthPreset3; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            widthPreset3="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($widthPreset3)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}height in pixels${noColor} ${green}($heightPreset3)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            heightPreset3=$heightPreset3; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            heightPreset3="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($heightPreset3)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}Name of Preset 4${noColor} ${green}(${preset4})${noColor}"
    read -e -p ": " choice
    if [[ $choice = "" ]]; then

        preset[4]=$preset4

    else

        preset[4]=$choice

    fi

    printf " Enter the desired ${orange}width in pixels${noColor} ${green}($widthPreset4)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            widthPreset4=$widthPreset4; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            widthPreset4="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($widthPreset4)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}height in pixels${noColor} ${green}($heightPreset4)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            heightPreset4=$heightPreset4; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            heightPreset4="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($heightPreset4)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}Name of Preset 5${noColor} ${green}(${preset5})${noColor}"
    read -e -p ": " choice
    if [[ $choice = "" ]]; then

        preset[5]=$preset5

    else

        preset[5]=$choice

    fi

    printf " Enter the desired ${orange}width in pixels${noColor} ${green}($widthPreset5)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            widthPreset5=$widthPreset5; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            widthPreset5="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($widthPreset5)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}height in pixels${noColor} ${green}($heightPreset5)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            heightPreset5=$heightPreset5; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            heightPreset5="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($heightPreset5)${noColor}"

        fi

    done


    printf " Enter the desired ${orange}Name of Preset 6${noColor} ${green}(${preset6})${noColor}"
    read -e -p ": " choice
    if [[ $choice = "" ]]; then

        preset[6]=$preset6

    else

        preset[6]=$choice

    fi

    printf " Enter the desired ${orange}width in pixels${noColor} ${green}($widthPreset6)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            widthPreset6=$widthPreset6; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            widthPreset6="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($widthPreset6)${noColor}"

        fi

    done

    printf " Enter the desired ${orange}height in pixels${noColor} ${green}($heightPreset6)${noColor}"
    while read -e -p ": " choice; do

        if [[ $choice = "" ]]; then

            heightPreset6=$heightPreset6; break

        elif [[ "$choice" =~ ^[[:digit:]]+$ ]] && echo "$choice>=1" | bc -l | grep -q 1; then

            heightPreset6="$choice"; break

        else

            printf " Please enter a positive integer value ${green}($heightPreset6)${noColor}"

        fi

    done

    clear
    printf " [16/16] ${yellow}Copyright${noColor}\n"
    printf " Enter the name of the ${orange}author${noColor}" ; read -e -p ": " author



    configuration="    # AUTHOR:   Andreas Betschart.
    # DATE:     23.01.2018.
    # PROGRAM:  fotoprep.
    # VERSION:  0.9.9
    # PURPOSE:  A central place for storing variables used in fotoprep.
    # WARNING:  Do not change this file. It will be overwritten by running the fotoprep setup (fotoprep -s).

    # Full path to your watermark file.
    # Preferably a PNG file, because of the quality and transparency.
    watermark=\"$watermark\"

    # Watermark width for landscape orientation. 1 would be the full image width.
    landscape=$landscape

    # Watermark width for portrait orientation. 1 would be the full image width.
    portrait=$portrait

    # Maximum height of the watermark. For very wide images.
    maxWatermarkHeight=$maxWatermarkHeight

    # Position of the watermark.
    # One of: Center, East, NorthEast, North, NorthWest, SouthEast, South, SouthWest, West.
    position=$position

    # Horizontal offset of the watermark.
    horizontalOffset=$horizontalOffset

    # Vertical offset of the watermark.
    verticalOffset=$verticalOffset

    # Dark logo for annotations.
    logoDark=\"$logoDark\"

    # Bright logo for annotations.
    logoBright=\"$logoBright\"

    # Annotation default background color.
    defaultFill=$defaultFill

    # Annotation default font color.
    defaultFontColor=$defaultFontColor

    # Annotation default logo.
    defaultLogo=\"$defaultLogo\"

    # Footer size of the annotation.
    multiplier=$multiplier

    # Logo size for annotations.
    logoMultiplier=$logoMultiplier

    # Point size for annotations.
    pointSizeMultiplier=$pointSizeMultiplier

    # Horizontal offset for annotations.
    offset=$offset

    # Color of the dark font for annotations.
    fontDark=$fontDark

    # Color of the bright font for annotations.
    fontBright=$fontBright

    # Font for the annotations.
    textFont=\"$textFont\"

    # Name for Preset 1.
    preset[1]=\"${preset[1]}\"

    # Width of images for Preset 1.
    widthPreset1=$widthPreset1

    # Height of images for Preset 1.
    heightPreset1=$heightPreset1

    # Name for Preset 2.
    preset[2]=\"${preset[2]}\"

    # Width of images for Preset 2.
    widthPreset2=$widthPreset2

    # Height of images for Preset 2.
    heightPreset2=$heightPreset2

    # Name for Preset 3.
    preset[3]=\"${preset[3]}\"

    # Width of images for Preset 3.
    widthPreset3=$widthPreset3

    # Height of images for Preset 3.
    heightPreset3=$heightPreset3

    # Name for Preset 4.
    preset[4]=\"${preset[4]}\"

    # Width of images for Preset 4.
    widthPreset4=$widthPreset4

    # Height of images for Preset 4.
    heightPreset4=$heightPreset4

    # Name for Preset 5.
    preset[5]=\"${preset[5]}\"

    # Width of images for Preset 5.
    widthPreset5=$widthPreset5

    # Height of images for Preset 5.
    heightPreset5=$heightPreset5

    # Name for Preset 6.
    preset[6]=\"${preset[6]}\"

    # Width of images for Preset 6.
    widthPreset6=$widthPreset6

    # Height of images for Preset 6.
    heightPreset6=$heightPreset6

    # Author for the image.
    author=\"${author}\""

    echo "$configuration" > "$myPath"/"$config"

    exit 0

fi

#---------------------------------------------------------------------------
# Check if the given parameters are images
#---------------------------------------------------------------------------

for i do # in "$@";

    if file "$i" 2> /dev/null | grep -qE 'image|bitmap'; then

        continue

    else

        printf " ${red}One or more of the given arguments are either not an image file or\n"
        printf " not a valid option.${noColor}\n"

        usage

        exit 1

    fi

done


# Check if there is a configuration file
if [ ! -f ""$myPath"/"$config"" ]; then

    printf " There is no configuration file for fotoprep.\n"
    printf " Please run ${lightPurple}fotoprep -s${noColor} first.\n"

    exit 1

fi

source "$myPath"/"$config"

directory=$directory$$


#---------------------------------------------------------------------------
# Here we go.
#---------------------------------------------------------------------------

# Ask some questions in order to know what to do.
clear
printf " ${yellow}Format${noColor}\n"
printf " In what format should the images be output? ${orange}[jpg/png/tif]${green}(jpg)${noColor}" ; read -e -p ": " formatChoice

case $formatChoice in

    [Pp]* )  # png.
        format=png
    ;;

    [Tt]* )  # tif.
        format=tif
    ;;

    * )      # jpg.
        format=jpg
    ;;
esac


# Cut the preset name strings after a certain length.
for p in {1..6}; do

    if [[ "${#preset[p]}" -gt 35 ]]; then

        preset[p]="${preset[p]1:0:35}... "

    fi

done


# Print the size menu
printf " ${yellow}Size${noColor}\n"

for p in {1..6}; do

    w="widthPreset$p"
    h="heightPreset$p"

    widthPreset=${!w}
    heightPreset=${!h}

    printf ${cyan}
    printf "%s" " ($p)"
    printf ${noColor}
    string1=" For ${preset[p]}"
    string2="[${widthPreset} x ${heightPreset}]"
    printf '%s' "$string1"
    printf ${darkGray}
    printf '%*.*s' 0 $((paddingLength - ${#string1} - ${#string2} )) "$padding"
    printf ${orange}
    printf '%s\n' "$string2"

done

printf " ${cyan}(7)${noColor} Custom dimensions\n"

printf " Enter choice${green}(7)${noColor}" ; read -e -p ": " choice


# Ask for the custom size or asign a preset size.
if [[ $choice == 7 ]] || [[ $choice == "" ]]; then

        printf " Enter the desired ${orange}width${noColor}" ; read -e -p ": " width
        printf " Enter the desired ${orange}height${noColor}" ; read -e -p ": " height
        targetWidth=$width
        targetHeight=$height

    else # Asign the preset size.

        w="widthPreset$choice"
        h="heightPreset$choice"

        targetWidth=${!w}
        targetHeight=${!h}
fi

printf " ${yellow}Watermark or Annotation${noColor}\n"
printf " Should a watermark, annotation or nothing be added? ${orange}[w/a/n]${green}(n)${noColor}" ; read -e -p ": " watermarkChoice

case $watermarkChoice in

    [Ww]* ) # Watermark.
        watermarkChoice=w

        if [ ! -f ${watermark} ]; then

            printf " ${red}Cannot find the watermark file.${noColor} Did you move it?\n"
            exit 66

        fi
    ;;

    [Aa]* ) # Annotate.
        watermarkChoice=a

        if [ ! -f ${logoDark} ] || [ ! -f ${logoBright} ]; then

            printf " ${red}At least one of the Logos cannot be found.${noColor} Did you move them?\n"
            exit 66

        fi

        printf " ${yellow}Annotaion Background Color${noColor}\n"
        printf " Use the average of the image or the predifined color? ${orange}[a/p]${green}(a)${noColor}" ; read -e -p ": " backgroundChoice

        printf " ${yellow}Description${noColor}\n"
        printf " Add the description from the metadata of the image? ${orange}[y/n]${green}(n)${noColor}" ; read -e -p ": " descriptionChoice
    ;;

    * ) # Nothing.
        watermarkChoice=n
    ;;

esac

printf " ${yellow}Sharpening${noColor}\n"
printf " ${cyan}(0)${noColor} None\n"
printf " ${cyan}(1)${noColor} Very little\n"
printf " ${cyan}(2)${noColor} A bit more\n"
printf " ${cyan}(3)${noColor} Default\n"
printf " ${cyan}(4)${noColor} Strong\n"
printf " ${cyan}(5)${noColor} Stronger\n"
printf " ${cyan}(6)${noColor} Very Strong\n"
printf " ${cyan}(7)${noColor} Insane\n"
printf " Enter choice${green}(3)${noColor}" ; read -e -p ": " sharpeningChoice



case $sharpeningChoice in

    0 ) # None
        sharpeningRadius=0
        sharpeningAmount=0
    ;;
    1 ) # Very little
        sharpeningRadius=0.5
    ;;
    2 ) # A bit more
        sharpeningRadius=1.0
    ;;
    4 ) # Strong
        sharpeningRadius=2.5
    ;;
    5 ) # Stronger
        sharpeningRadius=3.0
    ;;
    6 ) # Very Strong
        sharpeningRadius=4.5
    ;;
    7 ) # Insane
        sharpeningRadius=6.0
    ;;
    * ) # Default
        sharpeningRadius=1.5
    ;;

esac


# NOTE:     Sharpening is done following the advice from:
#           https://redskiesatnight.com/2005/04/06/sharpening-using-image-magick/
#           if radius < 1, then sigma = radius
#           else sigma = sqrt(radius)

if (( $(echo "$sharpeningRadius < 1" | bc -l) )); then

    sharpeningSigma=$sharpeningRadius

else

    sharpeningSigma=$(echo "scale=2; sqrt($sharpeningRadius)" | bc -l)

fi


# Here we create a directory, move all the images there and go there.
if [ ! -d "./$directory" ]; then

    mkdir "./$directory"

fi

mkdir "$directory"/"$workingDirectory"


# Copy the files to the $directory. Add some safety checks.
num=1
for i do # in "$@";

    extension="${i##*.}"           # get the extension
    basename="$(basename "$i")"    # get the filename without path
    filename="${basename%.*}"      # get the filename without extension
    lsArray=($(ls "${directory}")) # put ls $directory into an lsArray

        if [[ ! "${lsArray[@]}" =~ "${filename}" ]]; then

            cp "$i" "$directory"

            # Also copy the pp3 sidecar files for raw files
            if [ -f "$i".pp3 ]; then

                cp "$i".pp3 "$directory"

            fi

        else

            # Copy the files but add a string and a running number before
            # the extension, in order to avoid problems if we have files
            # with the same name but different extension (eg.: aaa.xcf and aaa.nef).
            cp "$i" "$directory"/"${filename}"_ftprp${workingDirectory}_${num}."${extension}"

            # Also copy the pp3 sidecar files for raw files
            if [ -f "$i".pp3 ]; then

                cp "$i".pp3 "$directory"/"${filename}"_ftprp${workingDirectory}_${num}."${extension}.pp3"

            fi

            ((num++))

        fi

done


cd "$directory"


#---------------------------------------------------------------------------
# Here we start working on the images.
#---------------------------------------------------------------------------

printf " Converting the images${darkGray}........................................${noColor}  "

for i in *.*; do

    # Ignore pp3 files.
    if [ ${i: -4} == ".pp3" ]; then

        continue

    fi


    # If it is a tif, only move it to the workingDirectory.
    if [ ${i: -4} == ".tif" ]; then

        mv "$i" "$workingDirectory"

    # If it is an xcf, convert and move it to the workingDirectory.
    elif [ ${i: -4} == ".xcf" ]; then
{
        gimp -n -i -b - <<EOF
        (let* ( (file's (cadr (file-glob "*.xcf" 1))) (filename "") (image 0) (layer 0) )
        (while (pair? file's)
        (set! image (car (gimp-file-load RUN-NONINTERACTIVE (car file's) (car file's))))
        (set! layer (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
        (set! filename (string-append (substring (car file's) 0 (- (string-length (car file's)) 4)) ".tif"))
        (gimp-file-save RUN-NONINTERACTIVE image layer filename filename)
        (gimp-image-delete image)
        (set! file's (cdr file's))
                )
               (gimp-quit 0)
               )
EOF
} &> /dev/null

        # Delete the xcf file.
        rm "$i"

        # Change the extension for i in order to process the new file, not the original.
        s="$i"; s=${s##*/}; i=${s%.*}.tif
        mv "$i" "$workingDirectory"

    # Use RawTherapee to convert RAW files.

    elif [[ " ${rawFormats[*]} " == *"${i: -4}"* ]]; then

        rawtherapee-cli -S -t -c "$i" &>/dev/null

        # Delete the RAW file and the pp3.
        rm "$i"
        rm "$i".pp3

        # Change the extension for i in order to process the new file, not the original.
        s="$i"; s=${s##*/}; i=${s%.*}.tif
        mv "$i" "$workingDirectory"

    else

        mogrify -path "$workingDirectory" -compress none -format tif "$i" 2>/dev/null

        # Mogrifying to tif deletes the exift tags. Copy the tags.
        exiftool -m -q -q -TagsFromFile "$i" -x Orientation "$workingDirectory"/"${i%.*}".tif

        # Remove the original file and the _original file.
        rm "$i"
        rm "$workingDirectory"/"${i%.*}".tif_original 2>/dev/null

    fi

done & spinner


#---------------------------------------------------------------------------
# Watermarking and annotating.
#---------------------------------------------------------------------------

cd "$workingDirectory"

printf " Resizing, adding the watermark or annotation${darkGray}.................${noColor}  "

for i in *.tif; do

    # Nothing. ####################################
    if [ "$watermarkChoice" == "n" ]; then

        convert -quiet "$i" -colorspace RGB -resize "$targetWidth"x"$targetHeight"\> -colorspace sRGB -unsharp ${sharpeningRadius}x${sharpeningSigma}+${sharpeningAmount}+${sharpeningThreshold} "${i%.*}"."$format"

        if [ "$format" == "tif" ]; then

            continue

        else

            rm "$i"

        fi

    # Annotate. ####################################
    elif [ "$watermarkChoice" == "a" ]; then

        # Extract height and width of the image.
        width=$(identify -quiet -format "%w" "$i")
        height=$(identify -quiet -format "%h" "$i")


        # Calculate footer height (footerHeight)

        # Calculate logo height (LH).

        # Calculate horizontal logo offset (LO).

        # Calculate horizontal comment offset (HO).

        # Calculate the vertical comment offset (VCO).
        # ImageMagick does not center the text vertically properly.

        # Calculate the pointsize (PS).

        if (( $(echo "$height <= $targetHeight" | bc -l) )); then

            footerHeight="$(echo "$height*$multiplier" | bc)"
            LH="$(echo "$height*$logoMultiplier" | bc)"
            HO="$(echo "$targetWidth*$offset" | bc)"
            VCO="$(echo "$height*0.0005" | bc -l)"
            LO="$(echo "$width*$offset*0.75" | bc)"
            PS="$(echo "$height*$pointSizeMultiplier" | bc)"

        else

            footerHeight="$(echo "$targetHeight*$multiplier" | bc)"
            LH="$(echo "$targetHeight*$logoMultiplier" | bc)"
            HO="$(echo "$targetWidth*$offset" | bc)"
            VCO="$(echo "$targetHeight*0.001" | bc -l)"
            LO="$(echo "$targetWidth*$offset*0.75" | bc)"
            PS="$(echo "$targetHeight*$pointSizeMultiplier" | bc)"

        fi

        # Fill the $description if comment/title is desired.
        case $descriptionChoice in
            [Yy]* )

                # Extract the values of the title and usercomment tags.
                imageDescription=$(exiftool -s -s -s -m -q -q -ImageDescription "$i")
                description=$(exiftool -s -s -s -m -q -q -Description "$i")
                userComment=$(exiftool -s -s -s -m -q -q -UserComment "$i")

                if [ "$imageDescription" != "" ]; then

                    descriptionTag="$imageDescription"

                elif [ "$description" != "" ]; then

                    descriptionTag="$description"

                else

                    descriptionTag="$userComment"

                fi
            ;;
        esac

        # Which fill?
        case $backgroundChoice in

            [pP]*)

                fill=$defaultFill
                textColor=$defaultFontColor
                logo="$defaultLogo"

            ;;

            *)  # Extract the average color of the image to use as fill.
                fill=$(convert "$i" -quiet -scale 1x1\! -format '%[pixel:s]' info:-)

                # Extract the average brightness to define the text color.
                bright=$(convert "$i" -quiet -colorspace Gray -format "%[fx:image.mean]" info:)

                # If the brightness is more than 0.65, make the text and logo dark.
                if (( $(echo "$bright > 0.65" | bc -l) )); then

                    logo="$logoDark"
                    textColor="$fontDark"

                else

                    logo="$logoBright"
                    textColor="$fontBright"

                fi
            ;;

        esac


        # Get the year for the copyright notice.
        modifyDate=$(exiftool -s -s -s -m -q -q -ModifyDate "$i")

        if [ "$modifyDate" == "" ]; then
            theYear=${theDate:0:4}
        else
            theYear=$(exiftool -s -s -s -m -q -q -ModifyDate "$i")
            theYear=${theYear:0:4}
        fi

        # Calculate horizontal copyright offset (CO)
        logoWidth=$(identify -quiet -format "%w" "$logo")
        logoHeight=$(identify -quiet -format "%h" "$logo")
        ratio="$(echo "$logoHeight/$LH" | bc -l)"
        LW="$(echo "$logoWidth/$ratio" | bc)"
        CO="$(echo "($LO*2)+($LW*1.05)" | bc)"

        # Since the footer will be added to the image,
        # reduce the targetHeight by the footerHeight.
        targetHeight="$(echo "$targetHeight-$footerHeight" | bc)"

        # Do the magick on the image.
        convert "$i" -colorspace RGB -resize "${targetWidth}"x"${targetHeight}"\> -colorspace sRGB -unsharp ${sharpeningRadius}x${sharpeningSigma}+${sharpeningAmount}+${sharpeningThreshold} \
            \( +clone \
                -quiet \
                -fill "$fill" \
                -draw 'color 0,0 reset' \
                -resize x$footerHeight! \
                -fill "$textColor" \
                -font "$textFont" \
                -pointsize "$PS" \
                -gravity east \
                -annotate +$HO+$VCO "$descriptionTag" \
                -gravity west \
                -annotate +$CO+$VCO "© $theYear $author" \
                -gravity west \
                    \( "$logo" -resize x$LH \) \
                -geometry +$LO+0 -composite \) \
            -append "${i%.*}"."$format"

        # Reset the targetHeight.
        targetHeight="$(echo "$targetHeight+$footerHeight" | bc)"

        if [ "$format" == "tif" ]; then

            continue

        else

            rm "$i"

        fi


    # Watermark. ####################################
    elif [ "$watermarkChoice" == "w" ]; then

        width=$(identify -quiet -format "%w" "$i")
        height=$(identify -quiet -format "%h" "$i")

        if [ "$width" -gt "$height" ]; then

            multiplier=$landscape # Width of the watermark for images in landscape orientation.

        else

            multiplier=$portrait # Width of the watermark for images in portrait orientation.

        fi

        # Get the new width of the image after resizing in order to calculate the width of the watermark.
        # Get the new height in oder to place the watermark properly.
        newWidth=$(convert "$i" -resize ${targetWidth}x${targetHeight}\> -format "%[w]" info: 2> /dev/null)
        newHeight=$(convert "$i" -resize ${targetWidth}x${targetHeight}\> -format "%[h]" info: 2> /dev/null)

        # Calculate watermark width (WW)
        WW="$(echo "$newWidth*$multiplier" | bc -l)"

        # Calculate watermark height (WH)
        WH=$(convert "$watermark" -resize ${WW} -format "%[h]" info: 2> /dev/null)

        # If the watermark is higher than $maxWatermarkHeight,
        # the watermark height is $maxWatermarkHeight.
        if (( $(echo "$WH > ($newHeight*$maxWatermarkHeight)" | bc -l) )); then
            WH="$(echo $newHeight*$maxWatermarkHeight | bc -l) "
        fi

        # Calculate watermark horizontal offset (HO) and vertical offset (VO).
        HO="$(echo "$newWidth*$horizontalOffset" | bc -l)"
        VO="$(echo "$newHeight*$verticalOffset" | bc -l)"

        # If HO or VO are smaller than 1, make them 1.
        if (( $(echo "$HO < 1" | bc -l) )); then HO=1; fi
        if (( $(echo "$VO < 1" | bc -l) )); then VO=1; fi

        # Resize the image.
        convert -quiet "$i" -colorspace RGB -resize "$targetWidth"x"$targetHeight"\> -colorspace sRGB -unsharp ${sharpeningRadius}x${sharpeningSigma}+${sharpeningAmount}+${sharpeningThreshold} "$i" 2> /dev/null

        # Add the watermark.
        composite -quiet -gravity "$position" -geometry +"$HO"+"$VO" \( $watermark -resize ${WW}x${WH} \) "$i" "${i%.*}"."$format"

        if [ "$format" == "tif" ]; then

            continue

        else

            rm "$i"

        fi

    fi

done & spinner

#---------------------------------------------------------------------------
# Editing the metadata
#---------------------------------------------------------------------------

printf " Adding the copyright to the metadata${darkGray}.........................${noColor}  "

for i in *.*; do

        # Get the year for the copyright notice.

        # PNG does not have the DateTimeOriginal tag.
        if [ "$format" == "png" ]; then

            modifyDate=$(exiftool -s -s -s -m -q -q -tiffDateTime "$i")

        else

            modifyDate=$(exiftool -s -s -s -m -q -q -DateTimeOriginal "$i")

        fi

        # If the year is empty, use the current year.
        if [ "$modifyDate" == "" ]; then
            theYear=${theDate:0:4}

        else

            if [ "$format" == "png" ]; then

                theYear=$(exiftool -s -s -s -m -q -q -tiffDateTime "$i")

            else

                theYear=$(exiftool -s -s -s -m -q -q -DateTimeOriginal "$i")

            fi

            # If the year is empty, use the current year.
            theYear=${theYear:0:4}
        fi

        exiftool -all= \
            -P \
            -m \
            -q \
            -q \
            -overwrite_original \
            -tagsfromfile @ \
            -ICC_Profile \
            -EXIF:ColorSpace= \
            -CommonIFD0= \
            -UniqueCameraModel= \
            -ProcessingSoftware= \
            -DocumentName= \
            -LocalizedCameraModel= \
            -CameraSerialNumber= \
            -PrimaryChromaticities= \
            -WhitePoint= \
            -EXIF:Artist="$author" \
            -EXIF:Copyright="Copyright © $theYear $author. All rights reserved." \
            -EXIF:ModifyDate \
            -XMP:Creator="$author" \
            -XMP:Rights="Copyright © $theYear $author. All rights reserved." \
            -XMP:Artist="$author" \
            -XMP:Copyright="Copyright © $theYear $author. All rights reserved." \
            -IPTC:By-line="$author" \
            -IPTC:CopyrightNotice="Copyright (C) $theYear $author. All rights reserved." \
        "$i" -o ..

done & spinner


#---------------------------------------------------------------------------
# Cleaning up
#---------------------------------------------------------------------------

cd ..
rmdir "$workingDirectory"
rm *.pp3 2>/dev/null
cd ..

printf " Ready, your images can be found under "$PWD"/${lightPurple}"$directory"${noColor}.\n"
