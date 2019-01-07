#!/bin/bash
#
# exiftool_tests.sh
# 2019_01_07 jmdigne
#
# -1- Initialisation
imagetest="image_test.jpg"

# Création répertoire ./exiftool_tests_dir s'il n'existe pas
if [ ! -d "./exiftool_tests_dir" ];then
  echo "--- Création du dosser1 !";
  mkdir ./exiftool_tests_dir
fi
cd ./exiftool_tests_dir

# test si server disponible (ne télécharge rien) -q = quiet
wget -q --spider http://www.kazamarie.info/
if [ $? -ne 0 ]; then
    echo "kazamarie.info is not reachable. Check your Internet connection."
    exit 1
fi

# Suppression de l'image de test si elle existe
if [ -f $imagetest ];then
echo "Le fichier de image de test existe déja !";
rm $imagetest 
fi

# Récupérer image test (.JPG)
echo "--- Image de test"

wget -v http://www.kazamarie.info/$imagetest
exiftool $imagetest |grep File

# -2- Extraction info Exif de l'image

echo "--- Paramètres de l'image"
fnumber=$(exiftool -s3 -exif:fnumber $imagetest)
echo $fnumber
focal1=$(exiftool -s3 -exif:focallength  $imagetest)
echo $focal1
focal2=$(echo "${focal1// /}")
exposuretime=$(exiftool -s3 -exif:exposuretime $imagetest)
echo $exposuretime
iso=$(exiftool -s3  -exif:iso $imagetest)
echo $iso

# -- Cleanup
echo "--- Fin"
cd ..
exit 0
