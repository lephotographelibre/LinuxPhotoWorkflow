#!/bin/bash
#
# make_before_after.sh
#
# v1.1 - Release initiale
#
echo "*** Parallel Before/After Image ***"
# Usage
display_usage() {
  echo " "
  echo "Ce script doit avoir au moins 2 arguments "
  echo "1- nom fichier avant modification"
  echo "2- nom fichier après modification"
  echo " "
  echo "Le fichier avantapres.jpg  sera créé dans le répertoire dans lequel se trouve le fichier passé en premier paramètre "
  echo " "
  echo "Usage:$0 [arguments] "
}

# if less than 3  arguments supplied, display usage
if [  $# -le 1 ]
  then
  display_usage
  exit 1
fi

echo "* Fichier  avant modification = $1"
echo "* Fichier après modification = $2"



# 1- Mise au format 1024 des deux images

avant=$(basename $1)
apres=$(basename $2)
dir=$(dirname $1)

mkdir /tmp/thumbs

#mogrify  -format jpg -path thumbs  -auto-orient -auto-level -quality 80 -thumbnail 512x512 *.jpg
mogrify  -format jpg -path /tmp/thumbs  -auto-orient -auto-level -quality 80 -thumbnail 512x512 $1
mogrify  -format jpg -path /tmp/thumbs  -auto-orient -auto-level -quality 80 -thumbnail 512x512 $2

# Ajour tags Avant Apres dans les images initiale et finale
convert /tmp/thumbs/$avant  -fill red -stroke black   -pointsize 30            -gravity south   -annotate 0 'Avant'    /tmp/thumbs/avant_texte.jpg
convert /tmp/thumbs/$apres  -fill red -stroke black   -pointsize 30            -gravity south   -annotate 0 'Après'    /tmp/thumbs/apres_texte.jpg

# 2-traitement
montage -geometry 512 /tmp/thumbs/avant_texte.jpg /tmp/thumbs/apres_texte.jpg $dir/avantapres.jpg

# 3 - Nettoyage

rm /tmp/thumbs/*.jpg
rmdir /tmp/thumbs

# Fin
exit 0
