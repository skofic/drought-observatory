#!/bin/sh

###
# Dump JSONL files and add shape to map if necessary.
#
# $1: Database name.
# $2: Local home path.
# $3: Current year.
# $4: Symbol.
# $5: Variable.
# $6: Radius.
# $7: Date.
# $8: Dataset.
###

###
# Check parameters.
###
if [ "$#" -ne 8 ]
then
	echo "Usage: FAPAN_dump.sh <database name> <home path> <year> <symbol> <variable <radius> <date> <dataset>"
	exit 1
fi

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

###
# Globals.
###
cache="${path}/cache"
export="${2}/data/JSONL"
query="${2}/query/${4}process.aql"
target="${4}${7}"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">>> PROCESS ${target}.jsonl.gz"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

###
# Export data into data folder.
###
arangoexport \
    --server.endpoint "$host" \
    --server.database "$1" \
    --server.username "$user" \
    --server.password "$pass" \
    --output-directory "$cache" \
    --custom-query-file "$query" \
    --custom-query-bindvars "{\"date\": \"${7}\", \"variable\": \"${5}\", \"dataset\": \"${8}\", \"radius\": ${6}}" \
    --compress-output true \
    --overwrite true \
    --type "jsonl"
    if [ $? -ne 0 ]
then
    echo "*************"
    echo "*** ERROR ***"
    echo "*************"
    exit 1
fi

###
# Name dump to the collection name.
###
mv -f "${cache}/query.jsonl.gz" "${export}/${target}.jsonl.gz"
if [ $? -ne 0 ]
then
    echo "*************"
    echo "*** ERROR ***"
    echo "*************"
    exit 1
fi

#
#
#
#
####
## Globals.
####
#symbol="$4"
#radius="$6"
#variable="$5"
#dataset="7b789ef4-aa2d-4f25-91c4-feab9d4cbb9b"
#cache="${path}/cache"
#folder="${2}/data/CSV"
#export="${2}/data/JSONL"
#head="${2}/config/header.csv"
#query="${2}/query/process.aql"
#
#echo "--------------------------------------------------"
#echo "- DUMP CDI FILES"
#echo "--------------------------------------------------"
#
####
## Iterate CSV files.
####
#for file in "${folder}/${symbol}"*.csv
#do
#
#    ###
#    # Get date from filename.
#    ###
#    len=${#symbol}
#    name=$(basename -- "$file")
#    date=${name:${len}:8}
#    target="${symbol}${date}"
#
#    echo ""
#    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
#    echo "<<< IMPORT ${target}.csv"
#    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
#
#    ###
#    # Import file into database.
#    ###
#    arangoimport \
#        --server.endpoint "$host" \
#        --server.database "$1" \
#        --server.username "$user" \
#        --server.password "$pass" \
#        --file "$file" \
#        --headers-file "$head" \
#        --type "csv" \
#        --collection "LOAD" \
#        --overwrite true \
#        --auto-rate-limit true \
#        --ignore-missing true
#    if [ $? -ne 0 ]
#    then
#        echo "*************"
#        echo "*** ERROR ***"
#        echo "*************"
#        exit 1
#    fi
#
#done

echo "--------------------------------------------------"
echo "- DUMPED CDI FILES"
echo "--------------------------------------------------"
echo ""