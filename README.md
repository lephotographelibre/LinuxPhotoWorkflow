LinuxPhotoWorkflow
==================

Bash script oour batir mon workflow photo sous Linux

# workflow.sh v1.0.2 Déchargement et pré-classement lot de photos
#
# History

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
