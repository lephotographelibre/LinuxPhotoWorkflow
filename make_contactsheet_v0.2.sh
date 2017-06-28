#!/bin/bash

# Create 7x6 contact sheets
# @jbuchbinder
#
# Dependencies:
# - dcraw
# - imagemagick

# History
# v0.2 - Creation
# usage  contactsheet.sh ~/Bureau/2017_05_21_MLF_Tests_EF1.4
# Ref: http://jbuchbinder.com/2016/02/08/opensource-contact-sheets-for-photographers/

SIZE=500
ROWS=6
FONTSIZE=32
# By default the contactsheet is created in the directory $1 (passed as the 1st paraùeter)
DEST=$1
#hack to avoid errot if files JPG only
touch a
REMOVELIST="a"

#--------------------------------------------------------------------------------------------------------
# remove blank
#for D in "$@"; do
#  a=`echo $D | tr "[:blank:]"
#  mv "$D" "$a"
#done
#--------------------------------------------------------------------------------------------------------

BATCH=$(( $ROWS * 7 ))

for D in "$@"; do
    ITER=0
    ls "$D"/*.??? | xargs -n $BATCH | while read X; do
        ITER=$(( $ITER + 1 ))
        FN=$( basename "$D" )-$( printf '%03d' $ITER ).jpg
        if [ ! -f "$DEST/$FN" ]; then
            echo "Creating contact sheet $FN"
            FILES=""
            REMOVELIST=""
            for F in $X; do
                case $F in
                    *JPG|*jpg)
                        echo "** Working on JPG files ************************** "
                        FILES="$FILES $F"
                        ;;

                    *CR2)
                        echo "** Working on CR2 files ************************** "
                        BN=$( basename "$F" )
                        dcraw -e $F
                        mv ${F//.CR2}.thumb.jpg /tmp/${BN//.CR2}.thumb.jpg
                        REMOVELIST="$REMOVELIST /tmp/${BN//.CR2}.thumb.jpg"
                        FILES="$FILES /tmp/${BN//.CR2}.thumb.jpg"
                        ;;
                esac
            done

            montage -verbose -label '%f' -font Ubuntu -pointsize ${FONTSIZE} \
                -background '#000000' -fill 'gray' -define jpeg:size=${SIZE}x${SIZE} \
                -geometry ${SIZE}x${SIZE}+2+2 -auto-orient $FILES "$DEST/$FN"
            echo "Cleaning up"
            rm -v $REMOVELIST
        else
            echo "Skipping existing contact sheet $FN"
        fi
    done
done
