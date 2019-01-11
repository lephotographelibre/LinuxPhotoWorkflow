#!/usr/bin/env bash
#
# From: Linux Photography 19.01.01 - Dmitri Popov
#       V0.1 JMD -c Convert file from png to jpg
#
while getopts "h?c" opt; do
  case $opt in
    c) echo "*** Conversion de "${2%.*}.png "--->" ${2%.*}.jpg
    convert ${2%.*}.png  -quality 90 ${2%.*}.jpg
    ls -al ${2%.*}.*
      ;;
    h|\?)
      echo "USAGE: -c Convert file from png to jpg (Quality 90%)"
      exit 2
      ;;
  esac
done
