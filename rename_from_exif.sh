#!/bin/bash
#
# rename_from_exif.sh v0.1 Liste les photos d'un répertoire puis normaliser le nom des fichiers basé sur le champ date/heure + variables
#
# History 
#   
#   v0.2 2015_05_05  Ajout 3eme Paramètre pour label image
#   v0.1 2015_05_04 creation
#
echo "*** Normaliser les noms de fichiers basés sur la data de prise de vue ***"
# Usage
display_usage() {
	echo " "
	echo "Ce script doit avoir moins 2 arguments "
	echo "Répertoire de travail de départ où ont été déchargées les images"
	echo "Répertoire de destination  "
	echo "Label (Lieu, Sujet) sans blanc "
	echo " "
	echo "\nUsage:\n$0 [arguments] \n"
	}
# if less than 3  arguments supplied, display usage
	if [  $# -le 1 ]
	then
		display_usage
		exit 1
	fi
#
#
# 00 - Lancement
MYPWD=`pwd`
echo "* Repertoire de travail de départ = $1"
cd $1
echo "* Repertoire de travail de destimation = $2"
mkdir $2
echo "* Label = $3"


# 0 - Contient la date pour préfixer les images
JOUR=`date +%Y_%m_%d_`
echo $JOUR
#
# 1 - liste des fichiers à traiter
# 
# Renomme fichier .jpg en .JPG
cp -v $1/* $2 
cd $2
rename -v 's/\.jpg\.*$/.JPG/' *.jpg*
# Affiche nombre de JPG au départ
NBFILEJPG=$(ls -l  $2/*.JPG | wc -l)
echo "* Nombre de fichiers JPG au départ = $NBFILEJPG"

# Normalise Nom du fichier en fonction de la date de prise de vue
exiftool '-filename<CreateDate' -d %Y_%m_%d_%H%M%S_$3%%-c.%%le -r -ext JPG $2

# 
# Vérifier le contenu du répertoire de destination
echo "*******************************************"
echo "* Repertoire de travail de destimation = $2"
cd $2
ls -alR *


# Retour à mon répertoire de départ
cd $MYPWD
#
# Remove directory
#
# Fin
exit 0
