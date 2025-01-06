#!/bin/sh

###
# Convert TIF files and place them in CSV folder.
#
# $1: Database.
# $2: Local home path.
# $3: Start year.
# $4: End year.
###

###
# Check parameters.
###
if [ "$#" -ne 4 ]
then
	echo "Usage: 02.process.sh <database> <home path> <start year> <end year>"
	exit 1
fi

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

###
# Globals.
###
first=1
head="${2}/config/header.csv"
config="${2}/config/prefixes.txt"
folder="${2}/data/CSV"

echo "--------------------------------------------------"
echo "- PROCESS FILES"
echo "--------------------------------------------------"
echo ""

###
# Iterate years.
###
for year in $(seq ${3} 1 ${4}); do

  echo "--------------------------------------------------"
  echo "- PROCESSING YEAR ${year}"
  echo "--------------------------------------------------"
  echo ""

  ###
  # Iterate prefixes.
  ###
  while IFS=' ' read -r symbol prefix variable radius dataset
  do

    echo "--------------------------------------------------"
    echo "- Year:     ${year}"
    echo "- Symbol:   ${symbol}"
    echo "- Prefix:   ${prefix}"
    echo "- Variable: ${variable}"
    echo "- Radius:   ${radius}"
    echo "- Dataset:  ${dataset}"
    echo "--------------------------------------------------"

    ###
    # Iterate CSV files fir current year.
    ###
    pattern="${folder}/${symbol}${year}"
    echo "$pattern"
    for file in "${pattern}"*.csv
    do

      ###
      # Check if there is a file.
      ###
      if [ -e "$file" ]; then

        ###
        # Get date from filename.
        ###
        len=${#symbol}
        name=$(basename -- "$file")
        date=${name:${len}:8}
        target="${symbol}${date}"

        echo ""
        echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo "<<< IMPORT ${name}"
        echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

  #      ###
  #      # Import file into database.
  #      ###
  #      arangoimport \
  #          --server.endpoint "$host" \
  #          --server.database "$1" \
  #          --server.username "$user" \
  #          --server.password "$pass" \
  #          --file "$file" \
  #          --headers-file "$head" \
  #          --type "csv" \
  #          --collection "LOAD" \
  #          --overwrite true \
  #          --auto-rate-limit true \
  #          --ignore-missing true
  #      if [ $? -ne 0 ]
  #      then
  #          echo "*************"
  #          echo "*** ERROR ***"
  #          echo "*************"
  #          exit 1
  #      fi

  #      ###
  #      # Process file.
  #      ###
  #      script="${2}/workflow/${symbol}dump.sh"
  #      sh "${script}" "${1}" "${2}" ${year} "${symbol}" "${variable}" ${radius} "${date}" "${dataset}"
  #      if [ $? -ne 0 ]
  #      then
  #          echo "*************"
  #          echo "*** ERROR ***"
  #          echo "*************"
  #          exit 1
  #      fi

        ###
        # Add to Store.
        ###

      else
        echo "No files found matching the pattern ${pattern}."
        break
      fi

    done

  done < "${config}"

  echo ""

done

echo "--------------------------------------------------"
echo "- PROCESSED FILES"
echo "--------------------------------------------------"
echo ""