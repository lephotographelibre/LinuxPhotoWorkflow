#!/bin/bash
#
# Resize4Web -- Traite un répertoire d'images et insère un logo
#
# History
# 2018-03_03 - Création

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
echo "*** Resize4Web ***"
# Usage
display_usage() {
	echo " "
	echo "Ce script doit avoir moins 1 argument"
	echo "1 - Répertoire de travail de départ où ont été déchargée les images non traitées"
	echo "2 - largeur en pixels"
	echo "3 - chemin du fichier Logo à inserer (optionnel)"
	echo " "
	echo "\nUsage:\n$0 [arguments] \n"
	}

# if less than 1  arguments supplied, display usage
	if [  $# -le 1 ]
	then
		display_usage
		exit 1
	fi
# Tester si un logo a été passé en paramètre ($3)
if [ -n "$3" ]; then
    echo "*** Un logo passé en paramètre 3: "+$3
fi


# 00 - Lancement

echo "* Repertoire de travail de départ = $1"

cd $1

#
# 1- Création du repertoire de destination

mkdir web1024


# 2 - Boucle de traitement
# Pour chaque fichier jpg de moins d'une heure faire echo du nom
	for line in $(find  . -iname '*.jpg'); do 
		 echo "New file "
	     echo $line
	     convert -verbose -resize $2 $line  web1024/$line 
	done

# Insertion du logo

# Tester si le fichier logo existe
if [ -f "$3" ] 
then 
   echo "Le fichier "+$3+" existe"
else  
   echo "******* ATTENTION ********* Le fichier logo passé en paramètre n'exite pas"
   echo "*********** Les fichiers traités se trouvent dans le répertoire = "`pwd`
   exit 1
fi

if [ -n "$3" ]; then
    echo "*** Insertion Un logo passé en paramètre 3: "+$3
    for line in $(find  ./web1024 -iname '*.jpg'); do 
		 echo "New file "
	     echo $line
	     convert -verbose $line  $3 -gravity SouthEast  -composite $line 
	done	
fi

# Retour à mon répertoire racine
echo "*********** Les fichiers traités se trouvent dans le répertoire = "`pwd`
cd ~

# Fin
exit 0
