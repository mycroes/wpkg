#!/bin/bash

app=$1

FLASH="http://www.adobe.com/go/full_flashplayer_win_msi http://www.adobe.com/go/full_flashplayer_win_pl_msi"
VJ="http://www.microsoft.com/downloads/info.aspx?na=41&SrcFamilyId=42C46554-5313-4348-BF81-9BB133518945&SrcDisplayLang=en&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2ff%2f1%2f7%2ff175de5b-e7af-4231-9a65-417611bbedfe%2fvjredist64.exe"

case "${app}" in
  flash)
    pkg=$FLASH
    ;;
  vj)
    pkg=$VJ
    ;;
  *)
    echo Error, you must specify a package
    exit 1
    ;;
esac

for p in $pkg ; do
  wget -c $p
done
