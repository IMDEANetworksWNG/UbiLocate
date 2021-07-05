#!/bin/bash
folder=$1

if [ "$folder" = "" ]; then
  echo "Missing the folder"
  exit 1
fi



cd "$(dirname "$0")"


ASUS="3 4"


mkdir traces

for each in $ASUS ; do
   
done

