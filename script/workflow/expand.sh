#!/bin/sh

###
# Expand ZIP files and place them in download folder.
#
# $1: Local home path.
# $2: Prefix.
# $3: Year.
###

###
# Check parameters.
###
if [ "$#" -ne 3 ]
then
	echo "Usage: expand.sh <home path> <prefix> <year>"
	exit 1
fi

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

###
# Globals.
###
folder="${1}/data/download"
prefix="${2}${3}"

echo "--------------------------------------------------"
echo "- EXPAND FILES"
echo "--------------------------------------------------"

###
# Iterate zip files.
###
for file in "${folder}/${prefix}"*.zip
do

  ###
  # Check if there is a file.
  ###
  if [ -e "$file" ]; then

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "> EXPAND $(basename "${file}")"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    ###
    # Unzip file.
    ###
    unzip -o "$file" -d "${folder}/"
    if [ $? -ne 0 ]
    then
        echo "*************"
        echo "*** ERROR ***"
        echo "*************"
        exit 1
    fi

    ###
    # Delete file.
    ###
    rm -f "$file"
    if [ $? -ne 0 ]
    then
        echo "*************"
        echo "*** ERROR ***"
        echo "*************"
        exit 1
    fi

  else
    echo "No files found matching the pattern ${folder}/${prefix}."
    break
  fi

done

echo "--------------------------------------------------"
echo "- EXPANDED FILES"
echo "--------------------------------------------------"
echo ""
