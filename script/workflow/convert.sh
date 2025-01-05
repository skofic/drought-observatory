#!/bin/sh

###
# Convert CDI TIF files and place them in CSV folder.
#
# $1: Local home path.
# $2: Symbol.
# $3: Prefix.
###

###
# Check parameters.
###
if [ "$#" -ne 3 ]
then
	echo "Usage: CDI_convert.sh <home path> <symbol> <prefix>"
	exit 1
fi

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

###
# Globals.
###
symbol="$2"
prefix="$3"
folder="${1}/data/download"
final="${1}/data/CSV"

echo "--------------------------------------------------"
echo "- CONVERT FILES"
echo "--------------------------------------------------"

###
# Iterate TIF files.
###
for file in "${folder}/${prefix}"*.tif
do

    ###
    # Get date from filename.
    ###
    len=${#prefix}
    name=$(basename -- "$file")
    date=${name:${len}:8}
    target="${symbol}${date}"

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>> CONVERT WGS84 FROM ${name} TO ${target}.tif"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    ###
    # Convert to WGS84 and geographic units.
    ###
    gdalwarp -overwrite -t_srs EPSG:4326 -dstnodata -9999 -r near -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 "$file" "${folder}/${target}.tif"
    if [ $? -ne 0 ]
    then
        echo "*************"
        echo "*** ERROR ***"
        echo "*************"
        exit 1
    fi

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>> CONVERT FROM ${target}.tif TO ${target}.csv"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    ###
    # Convert to CSV.
    ###
    gdal2xyz.py -skipnodata -csv "${folder}/${target}.tif" "${final}/${target}.csv"
    if [ $? -ne 0 ]
    then
        echo "*************"
        echo "*** ERROR ***"
        echo "*************"
        exit 1
    fi
    echo ""

done

echo "␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡"
echo "␡ DELETE TIFF files"
echo "␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡"

###
# Iterate TIF files.
###
for file in "${folder}/${prefix}"*.tif
do

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

done

echo "␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡"
echo "␡ DELETE converted TIFF files"
echo "␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡␡"

###
# Iterate converted TIF files.
###
for file in "${folder}/${symbol}"*.tif
do

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

done

echo "--------------------------------------------------"
echo "- CONVERTED FILES"
echo "--------------------------------------------------"
echo ""