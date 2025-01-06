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
cache="${path}/cache"
folder="${2}/data/CSV"
export="${2}/data/JSONL"

echo "--------------------------------------------------"
echo "- PROCESS FILES"
echo "--------------------------------------------------"
echo ""

###
# Iterate years.
###
for year in $(seq ${3} 1 ${4})
do

	echo "--------------------------------------------------"
	echo "- PROCESSING YEAR ${year}"
	echo "--------------------------------------------------"
	first=1

	###
	# Iterate prefixes.
	###
	while IFS=' ' read -r symbol prefix variable radius dataset
	do

		echo ""
		echo "--------------------------------------------------"
		echo "- Year:     ${year}"
		echo "- Symbol:   ${symbol}"
		echo "- Prefix:   ${prefix}"
		echo "- Variable: ${variable}"
		echo "- Radius:   ${radius}"
		echo "- Dataset:  ${dataset}"
		echo "--------------------------------------------------"

		###
		# Iterate CSV files for current year.
		###
		pattern="${folder}/${symbol}${year}"
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

				###
				# Import file into database.
				###
				arangoimport \
					--server.endpoint "$host" \
					--server.database "$1" \
					--server.username "$user" \
					--server.password "$pass" \
					--file "$file" \
					--headers-file "$head" \
					--type "csv" \
					--collection "LOAD" \
					--overwrite true \
					--auto-rate-limit true \
					--ignore-missing true
				if [ $? -ne 0 ]
				then
					echo "*************"
					echo "*** ERROR ***"
					echo "*************"
					exit 1
				fi

				###
				# Set target.
				###
				target="${symbol}${date}"

				echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
				echo ">>> PROCESS ${target}.jsonl.gz"
				echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

				###
				# Generate complete records.
				###
				arangoexport \
					--server.endpoint "$host" \
					--server.database "$1" \
					--server.username "$user" \
					--server.password "$pass" \
					--output-directory "$cache" \
					--custom-query-file "${2}/query/${4}process.aql" \
					--custom-query-bindvars "{\"date\": \"${date}\", \"variable\": \"${variable}\", \"dataset\": \"${dataset}\", \"radius\": ${radius}}" \
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

				echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				echo "<<< IMPORT ${target}.jsonl.gz"
				echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

				###
				# Import complete records into STORE.
				###
				arangoimport \
					--server.endpoint "$host" \
					--server.database "$1" \
					--server.username "$user" \
					--server.password "$pass" \
					--file "${export}/${target}.jsonl.gz" \
					--type "jsonl" \
					--collection "STORE" \
					--overwrite true \
					--auto-rate-limit true \
					--ignore-missing true
				if [ $? -ne 0 ]
				then
					echo "*************"
					echo "*** ERROR ***"
					echo "*************"
					exit 1
				fi

				echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
				echo ">>> EXPORT MAP DUMP"
				echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

				###
				# Generate complete records.
				###
				arangoexport \
					--server.endpoint "$host" \
					--server.database "$1" \
					--server.username "$user" \
					--server.password "$pass" \
					--output-directory "$cache" \
					--custom-query-file "${2}/query/map.aql" \
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
				# Name dump to the MAP.
				###
				mv -f "${cache}/query.jsonl.gz" "${export}/MAP.jsonl.gz"
				if [ $? -ne 0 ]
				then
					echo "*************"
					echo "*** ERROR ***"
					echo "*************"
					exit 1
				fi

				echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				echo "<<< IMPORT MAP.jsonl.gz"
				echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

				###
				# Import file into DroughtObservatoryMap.
				###
				arangoimport \
					--server.endpoint "$host" \
					--server.database "$1" \
					--server.username "$user" \
					--server.password "$pass" \
					--file "${export}/MAP.jsonl.gz" \
					--type "jsonl" \
					--collection "DroughtObservatoryMap" \
					--overwrite false \
					--auto-rate-limit true \
					--ignore-missing true \
					--on-duplicate "ignore"
				if [ $? -ne 0 ]
				then
						echo "*************"
						echo "*** ERROR ***"
						echo "*************"
						exit 1
				fi

				echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
				echo ">>> EXPORT DATA DUMP"
				echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

				###
				# Generate complete records.
				###
				arangoexport \
					--server.endpoint "$host" \
					--server.database "$1" \
					--server.username "$user" \
					--server.password "$pass" \
					--output-directory "$cache" \
					--custom-query-file "${2}/query/data.aql" \
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
				# Name dump to the DATA.
				###
				mv -f "${cache}/query.jsonl.gz" "${export}/DATA.jsonl.gz"
				if [ $? -ne 0 ]
				then
					echo "*************"
					echo "*** ERROR ***"
					echo "*************"
					exit 1
				fi

				echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				echo "<<< IMPORT DATA.jsonl.gz"
				echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

				###
				# Import file into GROUP.
				###
				if [ $first -eq 1 ]
				then
					arangoimport \
						--server.endpoint "$host" \
						--server.database "$1" \
						--server.username "$user" \
						--server.password "$pass" \
						--file "${export}/DATA.jsonl.gz" \
						--type "jsonl" \
						--collection "GROUP" \
						--overwrite true \
						--auto-rate-limit true \
						--ignore-missing true \
						--on-duplicate "ignore"
					if [ $? -ne 0 ]
					then
						echo "*************"
						echo "*** ERROR ***"
						echo "*************"
						exit 1
					fi

					###
					# Reset flag.
					###
					first=0

				else
					arangoimport \
						--server.endpoint "$host" \
						--server.database "$1" \
						--server.username "$user" \
						--server.password "$pass" \
						--file "${export}/DATA.jsonl.gz" \
						--type "jsonl" \
						--collection "GROUP" \
						--overwrite false \
						--auto-rate-limit true \
						--ignore-missing true \
						--on-duplicate "ignore"
					if [ $? -ne 0 ]
					then
						echo "*************"
						echo "*** ERROR ***"
						echo "*************"
						exit 1
					fi
				fi

			else
				echo "No files found matching the pattern ${pattern}."
				break

			fi # scanned existing file

		done # iterating CSV files

	done < "${config}" # iterating configurations

	###
	# Reset flag.
	###
	first=0
	echo ""

	###
	# Group year data.
	###

#	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#	echo ">>> EXPORT DATA FOR YEAR ${year}"
#	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#
#	###
#	# Generate complete records.
#	###
#	arangoexport \
#		--server.endpoint "$host" \
#		--server.database "$1" \
#		--server.username "$user" \
#		--server.password "$pass" \
#		--output-directory "$cache" \
#		--custom-query-file "${2}/query/data.aql" \
#		--compress-output true \
#		--overwrite true \
#		--type "jsonl"
#	if [ $? -ne 0 ]
#	then
#		echo "*************"
#		echo "*** ERROR ***"
#		echo "*************"
#		exit 1
#	fi
#
#	###
#	# Name dump to the DATA.
#	###
#	mv -f "${cache}/query.jsonl.gz" "${export}/DATA.jsonl.gz"
#	if [ $? -ne 0 ]
#	then
#		echo "*************"
#		echo "*** ERROR ***"
#		echo "*************"
#		exit 1
#	fi

done #iterating years

echo "--------------------------------------------------"
echo "- PROCESSED FILES"
echo "--------------------------------------------------"
echo ""