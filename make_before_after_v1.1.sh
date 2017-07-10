#!/bin/bash
#
# make_before_after.sh
#
# v0.8 - Release initiale
# v0.9 - Lecture nom des fichiers avant apres en entrée
# v1.0 - Tag Images Avant Après
# v1.1 - Avec fondu entre les deux images
#
echo "*** Before/After Animated GIF creation ***"
# Usage
display_usage() {
  echo " "
  echo "Ce script doit avoir au moins 2 arguments "
  echo "1- nom fichier avant modification"
  echo "2- nom fichier après modification"
  echo "3- optionel 1 si fondu entre les images de départ"  
  echo " "
  echo "Le GIF animé before_after_anim.gif sera créé dans le répertoire dans lequel se trouve le fichier passé en premier paramètre "
  echo " "
  echo "\nUsage:\n$0 [arguments] \n"
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

# Ajour tags Avant Apres dasn les images initiale et finale
convert /tmp/thumbs/$avant  -fill red -stroke black   -pointsize 30            -gravity south   -annotate 0 'Avant'    /tmp/thumbs/09.jpg
convert /tmp/thumbs/$apres  -fill red -stroke black   -pointsize 30            -gravity south   -annotate 0 'Après'    /tmp/thumbs/99.jpg

# 2- boucle de génération d'un blend progressif
i=10
j=100
while [ $i -ne 100 ] ; do
  composite -blend $ix$j% /tmp/thumbs/$avant /tmp/thumbs/$apres  /tmp/thumbs/$jx$i.jpg
  i=$(($i + 6))
  j=$(($j - 6))
done
rm /tmp/thumbs/$avant
rm /tmp/thumbs/$apres

# 3-Assemblage GIF Animé (si $3 est non null alors fondu)

if [ "$3" == "" ]; then
  echo "** Pas Fondu entre les images avant apres"
  convert -loop 0 -delay 300 /tmp/thumbs/09.jpg   -delay 300 /tmp/thumbs/99.jpg $dir/before_after_anim.gif

else
  echo "** Fondu entre les images avant apres"
  convert -loop 0 -delay 300 /tmp/thumbs/09.jpg -delay 25  /tmp/thumbs/*.jpg -delay 300 /tmp/thumbs/99.jpg $dir/before_after_anim.gif
fi

echo "* Fichier GIF Animé créé "
ls -al $dir/before_after_anim.gif

# 4- Nettoyage

rm /tmp/thumbs/*.jpg
rmdir /tmp/thumbs

# Fin
exit 0
