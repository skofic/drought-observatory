#!/bin/sh

###
# Convert TIF files and place them in CSV folder.
#
# $1: Local home path.
###

###
# Check parameters.
###
if [ "$#" -ne 1 ]
then
	echo "Usage: expand_downloads.sh <home path>"
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
prefix="cdinx_m_euu_"
epoc="${path}/DroughtObservatory/CDI"

echo "--------------------------------------------------"
echo "- CONVERT FILES"
echo "--------------------------------------------------"
start=$(date +%s)

###
# Iterate TIF files.
###

echo "--------------------------------------------------"
echo "- CONVERT CDI FILES: $elapsed seconds"
echo "--------------------------------------------------"
echo ""