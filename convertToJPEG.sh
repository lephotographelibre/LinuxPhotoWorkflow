#!/bin/sh
# from: aurelien pierre https://dev.aurelienpierre.com/wordpress-pour-le-photographe/
# Modifie pour le web toutes les images d'une extension donnée
# Parcourt les dossiers et sous-dossiers récursivement
# Compresse en JPEG optimisé et accentue la netteté
# Appel : sh crop.sh EXTENSION

FILES=$(ls -R *.$1)

for FILE in $FILES
	do
	convert $FILE -resize 2048x1600 -unsharp 2x0.5+0.5+0 "${FILE%%.*}"-web.jpg
	jpegoptim --all-progressive "${FILE%%.*}"-web.jpg
done
