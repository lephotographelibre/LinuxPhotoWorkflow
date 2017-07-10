#!/bin/bash
#
# make_contactsheet_bw_v1.0.sh
# Panche contact NB des photos d'un répertoire passé en paramètre
#
# History
# 2017_06_25 v1.0. - création
#
# Paramètres
# $1 = Répertoire de travail de départ où les images ont été déchargées
#
# Infos
# $1/BW = Répertoire temporaires des images converties NB
# contactsheet.JPG = Nom de la planche contact

#
# REM ***********************************************************************
#
echo "*** Planche Contact Noir&Blanc / BW Contact Sheet ***"
# Usage
display_usage() {
	echo " "
	echo "Au moins 1 Argument"
	echo "Répertoire de travail de départ où ont été déchargées les images"
	echo " "
	echo "\nUsage:\n$0 [arguments] \n"
	}

# T
	if [  $# -le 0 ]
	then
		display_usage
		exit 1
	fi

# 00 - Lancement

echo "* Repertoire de travail = $1"

# 1- Création des répertoires de travail temporaires
mkdir $1/BW

# 2 - Conversion en Greyscale --> copie des images grayscale dans dossier $1/BW

cd $1
# Nomalisation des nom de fichiers fichier .jpg en .JPG
rename -v 's/\.jpg\.*$/.JPG/' *.jpg*
for i in *.JPG; do convert -type Grayscale "$i" "$(echo $1/BW/$i)" ; done

# 3 - Traitement
cd $1/BW

SIZE=500
ROWS=6
FONTSIZE=32
# -auto-orient  : Supprimet ou Ajouter tag pour avoir une rotation automatique
# des vignettes

montage -verbose -label '%f' -font Ubuntu -pointsize ${FONTSIZE} -tile 7x5  \
		-background '#000000' -fill 'gray' -define jpeg:size=${SIZE}x${SIZE} \
		-title $(echo $1) -auto-orient \
		-geometry ${SIZE}x${SIZE}+2+2   *.JPG    contactsheet.JPG
cp  contactsheet.JPG ..

# 4 - Ménage
cd $1/BW
rm *.JPG
cd ..
rmdir $1/BW
cd $PWD

# Fin
exit 0
