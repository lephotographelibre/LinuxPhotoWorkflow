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
echo "*** Running make_contactsheet_bw_v1.0 *******************"
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
            echo "*** Creating contact sheet $DEST/$FN"
            FILES=""
            REMOVELIST=""
            for F in $X; do
								 
                case $F in
                    *JPG|*jpg)
						BW=$( basename "$F" )
						echo "."
						#	convert .jpg to .JPG
						cp $F  "/tmp/${BW}.cv.JPG"
						REMOVELIST="$REMOVELIST /tmp/${BW}.cv.JPG"
						#convert to Greyscale
						convert -type Grayscale "/tmp/${BW}.cv.JPG" "/tmp/${BW}.bw.JPG"
						#rm "${BW}.cv.JPG"
                        FILES="$FILES /tmp/${BW}.bw.JPG"
						REMOVELIST="$REMOVELIST  /tmp/${BW}.bw.JPG"
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

            montage -verbose -label '%f' -font Ubuntu -pointsize ${FONTSIZE} \
                -background '#000000' -fill 'gray' -define jpeg:size=${SIZE}x${SIZE} \
                -geometry ${SIZE}x${SIZE}+2+2 -auto-orient $FILES "$DEST/$FN"
						echo "*** Contact Sheet created ---> $DEST/$FN"
            echo "Cleaning up"
            rm 	 $REMOVELIST
        else
            echo "*** Skipping existing contact sheet $FN"
			echo "*** Please remove it before running this script"
        fi
    done
done
