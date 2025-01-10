#!/bin/sh
# $1: Database name.
# $2: Home directory path.

###
# Load default parameters.
###
source "${HOME}/.ArangoDB"

# Configuration
DB_NAME="$1"
COLLECTION_LOAD="LOAD"
COLLECTION_STORE="STORE"
COLLECTION_GROUP="GROUP"
COLLECTION_SHAPES="DroughtObservatoryMap"
FILE_SHAPES="${2}/data/required/DroughtObservatoryMap.jsonl.gz"
INDEX_NAME1="idx_hash"
INDEX_NAME2="idx_hash_date"
INDEX_NAME3="idx_value"
ARANGODB_HOST="$host"
ARANGODB_USER="$user"
ARANGODB_PASSWORD="$pass"

echo ""
echo "**************************************************"
echo "*** SETUP DATABASE, COLLECTIONS AND INDEXES."
echo "**************************************************"
echo "*** DATABASE:      ${DB_NAME}"
echo "*** COLLECTION 1:  ${COLLECTION_LOAD}"
echo "*** COLLECTION 2:  ${COLLECTION_STORE}"
echo "*** COLLECTION 3:  ${COLLECTION_GROUP}"
echo "*** COLLECTION 4:  ${COLLECTION_SHAPES}"
echo "*** SHAPES:        ${FILE_SHAPES}"
echo "**************************************************"

# Create a temporary file
TEMP_FILE=$(mktemp /tmp/arangodb_script.XXXXXX)

# Write the JavaScript commands to the temporary file
echo "
'use strict';

///
// Connect to ArangoDB.
///
const db = require('@arangodb').db;

///
// Create database if it doesn't exist.
///
if (!db._databases().includes('$DB_NAME')) {
  db._createDatabase('$DB_NAME');
  console.log('===> Database $DB_NAME created');
} else {
  console.log('Database $DB_NAME already exists');
}

///
// Use the database.
///
db._useDatabase('$DB_NAME');

///
// Create collections if they don't exist.
///
if (!db._collection('$COLLECTION_LOAD')) {
  db._create('$COLLECTION_LOAD');
  console.log('==> Collection $COLLECTION_LOAD created');
} else {
  console.log('Collection $COLLECTION_LOAD already exists');
}

if (!db._collection('$COLLECTION_STORE')) {
  db._create('$COLLECTION_STORE');
  console.log('==> Collection $COLLECTION_STORE created');
} else {
  console.log('Collection $COLLECTION_STORE already exists');
}

if (!db._collection('$COLLECTION_GROUP')) {
  db._create('$COLLECTION_GROUP');
  console.log('==> Collection $COLLECTION_GROUP created');
} else {
  console.log('Collection $COLLECTION_GROUP already exists');
}

///
// Create indexes.
///
var collection = db._collection('$COLLECTION_LOAD');
if (!collection.getIndexes().some(function(i) { return i.name === '$INDEX_NAME3'; })) {
  collection.ensureIndex({
  	name: '$INDEX_NAME3',
  	type: 'persistent',
  	fields: [
		'value'
  	]
  });
  console.log('===> Index $INDEX_NAME3 created for $COLLECTION_LOAD');
} else {
  console.log('Index $INDEX_NAME3 already exists');
}

collection = db._collection('$COLLECTION_STORE');
if (!collection.getIndexes().some(function(i) { return i.name === '$INDEX_NAME1'; })) {
  collection.ensureIndex({
  	name: '$INDEX_NAME1',
  	type: 'persistent',
  	fields: [
		'geometry_hash'
  	]
  });
  console.log('===> Index $INDEX_NAME1 created for $COLLECTION_STORE');
} else {
  console.log('Index $INDEX_NAME1 already exists');
}
if (!collection.getIndexes().some(function(i) { return i.name === '$INDEX_NAME2'; })) {
  collection.ensureIndex({
  	name: '$INDEX_NAME2',
  	type: 'persistent',
  	fields: [
		'geometry_hash',
		'std_date'
  	]
  });
  console.log('===> Index $INDEX_NAME2 created for $COLLECTION_STORE');
} else {
  console.log('Index $INDEX_NAME2 already exists');
}

collection = db._collection('$COLLECTION_GROUP');
if (!collection.getIndexes().some(function(i) { return i.name === '$INDEX_NAME2'; })) {
  collection.ensureIndex({
  	name: '$INDEX_NAME2',
  	type: 'persistent',
  	fields: [
		'geometry_hash',
		'std_date'
  	]
  });
  console.log('===> Index $INDEX_NAME2 created for $COLLECTION_GROUP');
} else {
  console.log('Index $INDEX_NAME2 already exists');
}
" > "$TEMP_FILE"

# Execute the JavaScript file using arangosh
arangosh --server.endpoint="$ARANGODB_HOST" --server.username="$ARANGODB_USER" --server.password="$ARANGODB_PASSWORD" --javascript.execute "$TEMP_FILE"
rm "$TEMP_FILE"
if [ $? -ne 0 ]
then
  echo "*************"
  echo "*** ERROR ***"
  echo "*************"
  exit 1
fi

###
# Load geometries.
###
if [ -e "$FILE_SHAPES" ]; then
	echo "==> Loading shape geometries."
	arangoimport \
		--server.endpoint "$host" \
		--server.username "$user" \
		--server.password "$pass" \
		--server.database "$1" \
		--collection "$COLLECTION_SHAPES" \
		--create-database true \
		--create-collection true \
		--create-collection-type "document" \
		--overwrite true \
		--ignore-missing true \
		--file "${FILE_SHAPES}" \
		--type "jsonl" \
		--auto-rate-limit true \
		--progress true
	if [ $? -ne 0 ]
	then
		echo "*************"
		echo "*** ERROR ***"
		echo "*************"
		exit 1
	fi
else
	echo "==> Missing shape geometries."
fi

echo ""
echo "**************************************************"
echo "*** SETUP TERMINATED."
echo "**************************************************"
echo ""
