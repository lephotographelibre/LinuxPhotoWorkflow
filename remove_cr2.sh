#!/bin/bash
#
# remove_cr2.sh v1.0.0 Suppression des fichiers CR2 RAW orphelins (qui n'ont plus de correspondants JPG)
# A executer à la racine du dossiers d'images (ex: ~/Images/2015_07_24_Fuveau)
# Répertoire des JPG 0.JPG
# Répertoire des RAW 0.RAW

# Affiche nombre de JPG au départ
NBFILEJPG=$(ls -l  0.JPG/*.jpg | wc -l)
echo "* Nombre de fichiers JPG au départ = $NBFILEJPG"
# Affiche Nombre de RAW au départ
NBFILEJRAW=$(ls -l  0.RAW/*.cr2 | wc -l)
echo "* Nombre de fichiers RAW au départ = $NBFILEJRAW"

cd 0.RAW

for fichier in *.cr2
do
  if [ -a ../0.JPG/$(basename $fichier .${fichier##*.}).jpg ]
    then
        echo $(basename $fichier .${fichier##*.})
    else
        rm -v $fichier
  fi
done

cd ..

# Affiche nombre de jpg  après traitement
NBFILEJPG=$(ls -l  0.JPG/*.jpg | wc -l)
echo "* Nombre de fichiers JPG au départ = $NBFILEJPG"
# Affiche Nombre de cr2  au départ
NBFILEJRAW=$(ls -l  0.RAW/*.cr2 | wc -l)
echo "* Nombre de fichiers RAW au départ = $NBFILEJRAW"

# Fin
exit 0
