#!/usr/bin/env bash
#
# From: Linux Photography 19.01.01 - Dmitri Popov
#       V1.1 JLM sorts photos into directories named by the original
#
while getopts "h?sdyare" opt; do
  case $opt in
    s) exiftool -directory=%e .
      ;;
    d) exiftool -d %Y%m%d-%H%M%S.%%e '-FileName<DateTimeOriginal' -r .
      ;;
    y) exiftool '-Directory<CreateDate' -d %Y-%m-%d -r .
      ;;
    a) exiftool -T -r -filename -make -model -fnumber -exposuretime -iso -r . > results.txt
      ;;
    r) exiftool -overwrite_original -all= -r .
      ;;
    e) exiftool -directory=%e DIR
      ;;
    h|\?)
      cat <<EOF
  USAGE:
    $0 [OPTIONS]
    $0 -s sort photos into folders by file extension
    $0 -d rename photos by date
    $0 -y sort photos into folders by year, month, and date
    $0 -a save key EXIF data in the results.txt file
    $0 -r remove all EXIF metadata from photos
    $0 -e sorts photos into directories named by the original extension
  EOF
      exit 2
      ;;
  esac
done
