#!/bin/sh

###
# Download Fraction of Absorbed Photosynthetically Active Radiation (FAPAN) Anomaly
#
# $1: Start date (numeric).
# $2: End date (numeric).
# $3: Local home path.
#
# The script will download the zip file in the data download directory.
###

###
# Check parameters.
###
if [ "$#" -ne 3 ]
then
	echo "Usage: download_fapan.sh <start date> <end date> <home path>"
	exit 1
fi

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

###
# Globals.
###
folder="${3}/data/download"

echo "--------------------------------------------------"
echo "- DOWNLOAD FAPAN FILES"
echo "--------------------------------------------------"
start=$(date +%s)

###
# Iterate years.
###
for year in $(seq ${1} 1 ${2})
do

	###
	# Set URL.
	###
	name="fpanv_m_euu_${year}0101_${year}0121_t.zip"
	url="https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/DROUGHTOBS/Drought_Observatories_datasets/EDO_Fraction_of_Absorbed_Photosynthetically_Active_Radiation_Anomalies_fAPAR_VIIRS/ver1-0-0/${name}"

	echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
	echo "< DOWNLOAD ${name}"
	echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

	###
	# Download file.
	###
	wget --continue "$url" --output-document="${folder}/${name}"
 	if [ $? -ne 0 ]
 	then
 		echo "*************"
 		echo "*** ERROR ***"
 		echo "*************"
 		exit 1
 	fi

done

echo "--------------------------------------------------"
echo "- DOWNLOADED FAPAN FILES"
echo "--------------------------------------------------"
echo ""
