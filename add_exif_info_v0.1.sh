#!/bin/bash
#
# add_exif_info.sh
# 2016_07_24 jmdigne - http://lephotographelibre.wordpress.com
#
# Ajoute dans l'image sous forme de texte les données principales Exif
# (ISO, Focale,Vitesse, Ouverture)
#
# v0.1 - 2016_07_24 -  Release initiale
# Todo
# -mise à l'échelle du texte en fonction de la largeur de l'image
# -variabiliser le choix de la couleur du texte
# -ecrire le texte dans un boite de couleur dégradé par rapport à la couleur du texte
#
echo "*** Add/Display Exif info Image ***"
# Usage
display_usage() {
  echo " "
  echo "Ce script doit avoir au moins 1 argument"
  echo "1- nom fichier avant modification"
  echo " "
  echo "Le fichier résultat nommé with_exif_xxx.jpg  sera créé dans le répertoire dans lequel se trouve le fichier passé en paramètre "
  echo " "
  echo "Usage:$0 [arguments] "
}

# if less than 3  arguments supplied, display usage
if [  $# -le 0 ]
  then
  display_usage
  exit 1
fi

# 1- Init

avantmodif=$(basename $1)
echo "* Fichier  avant modification = $avantmodif"
dir=$(dirname $1)


apres="with_exif_$avantmodif"
echo "* Fichier après modification = $apres"

mkdir /tmp/exiftmp
mogrify  -format jpg -path /tmp/exiftmp  -auto-orient -auto-level -quality 80 -thumbnail 1024x1024 $1

# 2- Extraction info Exif de l'image

fnumber=$(exiftool -s3 -exif:fnumber $1)
echo $fnumber
focal1=$(exiftool -s3 -exif:focallength  $1)
echo $focal1
focal2=$(echo "${focal1// /}")
exposuretime=$(exiftool -s3 -exif:exposuretime $1)
echo $exposuretime
iso=$(exiftool -s3  -exif:iso $1)
echo $iso
buffer="ISO:$iso:Focale:$focal2\nVitesse:$exposuretime:Ouverture-f/$fnumber"


#
convert /tmp/exiftmp/$avantmodif  -fill white -stroke black   -pointsize 20  -gravity north   -annotate 0 $buffer   /tmp/exiftmp/$apres
mv /tmp/exiftmp/$apres $dir/$apres


# 3 - Nettoyage

rm  /tmp/exiftmp/*.jpg
rmdir  /tmp/exiftmp

# Fin
exit 0
