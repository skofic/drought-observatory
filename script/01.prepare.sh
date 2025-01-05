#!/bin/sh

###
# Expand ZIP files and convert them to CSV format.
#
# Note that this script will iterate all years.
#
# $1: Local home path.
# $2: Start year.
# $3: End year.
###

###
# Check parameters.
###
if [ "$#" -ne 3 ]
then
	echo "Usage: 01.prepare.sh <home path> <start year> <end year>"
	exit 1
fi

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

###
# Globals.
###
config="${1}/config/prefixes.txt"

echo "--------------------------------------------------"
echo "- PREPARE FILES"
echo "--------------------------------------------------"
echo ""

###
# Iterate years.
###
for year in $(seq ${2} 1 ${3}); do

  echo "--------------------------------------------------"
  echo "- PROCESSING YEAR ${year}"
  echo "--------------------------------------------------"
  echo ""

  ###
  # Iterate prefixes.
  ###
  while IFS=' ' read -r symbol prefix variable radius
  do

    echo "--------------------------------------------------"
    echo "- Year:     ${year}"
    echo "- Symbol:   ${symbol}"
    echo "- Prefix:   ${prefix}"
    echo "- Variable: ${variable}"
    echo "- Radius:   ${radius}"
    echo "--------------------------------------------------"

    ###
    # Expand file.
    ###
    sh "${1}/script/workflow/expand.sh" "${1}" "${prefix}" ${year}

    ###
    # Convert file.
    ###
    sh "${1}/script/workflow/convert.sh" "${1}" "${symbol}" "${prefix}"

  done < "${config}"

  echo ""

done

echo "--------------------------------------------------"
echo "- PREPARED FILES"
echo "--------------------------------------------------"
echo ""
