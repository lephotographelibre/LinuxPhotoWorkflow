#!/bin/bash
#
# make_contactsheet_bw_v1.0.sh
#
#
# Create 7x6 contact sheets
# @jbuchbinder
#
# Dependencies:
# - dcraw
# - imagemagick
# usage  ./make_contactsheet_bw_V1.0.sh ~/Bureau/Esnandes
echo "** make_contactsheet_bw_v1.0 "
SIZE=500
ROWS=6
FONTSIZE=32
# A CUSTOMISER
DEST=~/Images

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
						touch a
						REMOVELIST="$REMOVELIST ./a"
						#echo $REMOVELIST
            for F in $X; do
                case $F in
                    *JPG|*jpg)
                        FILES="$FILES $F"
                        ;;

                    *CR2)
                        BN=$( basename "$F" )
                        dcraw -e $F
                        mv ${F//.CR2}.thumb.jpg /tmp/${BN//.CR2}.thumb.jpg
                        REMOVELIST="$REMOVELIST /tmp/${BN//.CR2}.thumb.jpg"
                        FILES="$FILES /tmp/${BN//.CR2}.thumb.jpg"
                        ;;
                esac
            done
# "$DEST/$FN"
            montage -verbose -label '%f' -font Ubuntu -pointsize ${FONTSIZE} \
                -background '#000000' -fill 'gray' -define jpeg:size=${SIZE}x${SIZE} \
                -geometry ${SIZE}x${SIZE}+2+2 -auto-orient $FILES "$DEST/$FN"
            echo "Cleaning up"
            rm 	 $REMOVELIST
        else
            echo "Skipping existing contact sheet $FN"
        fi
    done
done
