#!/bin/bash
#
# workflow.sh -- Déchargement et pré-classement lot de photos
#
# History

# 2018_04_21 - v1.0.3- Sony RX100 ARW support 
# 2018_03_05 - v1.0.4- Add JPG/RAW direcory name with Etiquette
# 2014_12_19 - v1.0.3- Normalise et renomme fichiers source .jpg en .JPG
# 2014_08_17 - v1.0.2- Ajout paramètres  -auto-orient -auto-level -quality 90  imagemagick pour thumbnails
# 2014_08_17 - v1.0.1- Ajout répertoire  $2/4.WORKRAW

# Format de nom des images YYYY_MM_DD_img_XXXX.jpg ou YYYY_MM_DD_IMG_img.cr2 (Minuscules/sans espaces)
#
# Paramètres
# $1 = Répertoire de travail de départ où ont été déchargée les images
# $2 = Répertoire de destination au format "YYYY_MM_DD_Etiquette" ~/Images/2014_08_16_Meudon
# $3 = Etiquette pour les images (Lieu / Thèmes)
#
# REM ***********************************************************************
# REM si besoin de renommer fichier de manière incrementale (camera upload)
# j=0;for i in *.jpg;do let j+=1;mv "$i" "img_$j.jpg";done
#
echo "*** Linux Workflow ***"
# Usage
display_usage() {
	echo " "
	echo "Ce script doit avoir moins 3 arguments "
	echo "1- Répertoire de travail de départ où ont été déchargée les images"
	echo "2- Répertoire de destination au format YYYY_MM_DD_Etiquette"
	echo "3 - Etiquette pour les images (Lieu / Thèmes)"
	echo " "
	echo "**** Usage: $0 [3 arguments] "
	}

# if less than 3  arguments supplied, display usage
	if [  $# -le 2 ]
	then
		display_usage
		exit 1
	fi



# 00 - Lancement

echo "* Repertoire de travail de départ = $1"
echo "* Repertoire de travail de destimation = $2"
echo "* Etiquette  = $3"
cd $1

#
# Contient la date pour préfixer les images
JOUR=`date +%Y_%m_%d_`
echo $JOUR
#
#Où je suis
PWD=`pwd`
echo "* Où je suis = $PWD"
#
#
# 1- Création des répertoires de travail

mkdir $2
mkdir $2/0.JPG 
mkdir $2/0.RAW 
#mkdir $2/1.THUMBNAIL
mkdir $2/2.HDR
mkdir $2/3.PANO
mkdir $2/4.WORKJPG
mkdir $2/4.WORKRAW
#mkdir $2/5.KEEPERS
#mkdir $2/6.THROWAWAY
mkdir $2/10.PORTFOLIO

# 2 - Copie des fichiers Images source .JPG et .CR2 --> Répertoires Destination

cd $1
# Renomme fichier .jpg en .JPG
rename -v 's/\.jpg\.*$/.JPG/' *.jpg*
# Affiche nombre de JPG au départ
NBFILEJPG=$(ls -l  $1/*.JPG | wc -l)
echo "* Nombre de fichiers JPG au départ = $NBFILEJPG"
# Affiche Nombre de RAW au départ
NBFILEJRAW=$(ls -l  $1/*.CR2 | wc -l)
echo "* Nombre de fichiers CR2 au départ = $NBFILEJRAW"
NBFILEJRAW=$(ls -l  $1/*.ARW | wc -l)
echo "* Nombre de fichiers ARW au départ = $NBFILEJRAW"

cp -v $1/*.JPG $2/0.JPG
cp -v $1/*.CR2 $2/0.RAW
cp -v $1/*.ARW $2/0.RAW
# pour copier des fichiers avec extension en majuscules ou minuscule, remplacer par
# for f in $(find . -iname "*.JPG"); do cp -v $1/$f $2/0.JPG; done
# for f in $(find . -iname "*.CR2"); do cp -v $1/$f $2/0.RAW; done

# 3 - Renommer les fichiers imgaes (minuscules/sans tiret) au format
# YYYY_MM_DD_img_XXXX.jpg ou YYYY_MM_DD_IMG_img.cr2

cd $2/0.JPG
for i in *; do mv "$i" "$(echo $i | tr A-Z a-z)"; done
for i in *; do mv "$i" "$(echo $i | tr " " "-")"; done
for i in *; do mv "$i" "$(echo $JOUR$i)"; done

cd $2/0.RAW
for i in *; do mv "$i" "$(echo $i | tr A-Z a-z)"; done
for i in *; do mv "$i" "$(echo $i | tr " " "-")"; done
for i in *; do mv "$i" "$(echo $JOUR$i)"; done

# 4 - Générer les vignettes 1024x1024 avec imagemagick ( thumb_YYYY_MM_DD_img_XXXX.jpg )

#echo "* Génération des vignettes 1024x"
#d $2/0.JPG
#mkdir thumbs
#mogrify  -format jpg -path thumbs  -auto-orient -auto-level -quality 90 -thumbnail 1024x1024 *.jpg
#cd thumbs
#for i in *; do mv "$i" "$(echo thumb_$i)"; done
#ls -al *
#mv *.jpg $2/1.THUMBNAIL
#cd ..
#rmdir thumbs

# Vérifier le contenu du répertoire de destination
cd $2
ls -alR *

JPG=$2/0.JPG
echo $2
echo $JPG
JPG_DEST=$JPG
JPG_DEST+="_"
JPG_DEST+=$3
echo $JPG_DEST
mv  $JPG $JPG_DEST

RAW=$2/0.RAW
echo $2
echo $RAW
RAW_DEST=$RAW
RAW_DEST+="_"
RAW_DEST+=$3
echo $RAW_DEST
mv  $RAW $RAW_DEST


# Suppression des répertoires (temporaires pour les tests)

#rm -rf $2/0.JPG/*
#rm -rf $2/0.RAW/*
#rm -rf $2/1.THUMBNAIL/*

#rmdir $2/0.JPG
#rmdir $2/0.RAW
#rmdir $2/1.THUMBNAIL
#rmdir $2/2.HDR
#rmdir $2/3.PANO
#rmdir $2/4.WORKJPG
#rmdir $2/4.WORKRAW
#rmdir $2/5.KEEPERS
#rmdir $2/6.THROWAWAY
#rmdir $2/10.PORTFOLIO
#rmdir $2

# Retour à mon répertoire racine
cd ~



# Fin
exit 0
