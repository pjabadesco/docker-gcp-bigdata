#!/bin/bash
BUCKET_NAME=$1
MSSQL_CONN=$2
TABLE_SCHEMA=$3
TABLE_NAME=$4
# PROJECT_ID=`gcloud config list --format 'value(core.project)' 2>/dev/null`
UIDX=`date  '+_%Y_%m_%d'`
# DATASET="$TABLE_SCHEMA$UIDX"
DATASET="${MSSQL_CONN}_${TABLE_SCHEMA}"
upload_folder="$BUCKET_NAME/UPLOAD/"
#https://gist.github.com/intotecho/173401b1ce1a2c18decc3ce22ffeb5a7

source /home/mssql_conn.sh

# init directories
mkdir -p /workspace/mssql_output

# gcloud config set project $PROJECT_ID
echo "Import $TABLE_SCHEMA.$TABLE_NAME from MSSQL to BigQuery $PROJECT_ID:$DATASET.$TABLE_NAME via bucket $upload_folder"

#  uncomment set -x for more printouts
#set -x

mytime=`date '+%y%m%d%H%M'`
hostname=`hostname | tr 'A-Z' 'a-z'`
file_prefix="$TABLE_NAME$mytime$TABLE_SCHEMA"

echo $file_prefix


#check if data set exists and create if not
bq_safe_mk() {
    location=$1
    dataset=$2
    exists=$(bq ls -d | grep -w $dataset)
    if [ -n "$exists" ]; then
       echo "BigQuery Dataset $dataset already exists"
    else
       echo "Creating BigQuery Dataset $dataset"
       bq mk --location=$location $dataset
    fi
}

# Cleanup function called on exit
function cleanup_files () {
    echo 'cleaning...'
    rm /workspace/mssql_output/${TABLE_NAME}.*
}


# make sure bucket, schema and table names are supplied
if [ $# -ne 4 ];then
echo "Copy a table from MSSQL schema to existing bucket in current gcp project then import to BigQuery dataset $DATASET."
echo "usage: $0 BUCKET_NAME MSSQL_CONN SCHEMA_NAME TABLE_NAME"
exit 1
fi

echo "Creating JSON schema from MSSQL table structure"
sql_query="
    SELECT REPLACE(COLUMN_NAME,' ','_')+':'+
        (CASE DATA_TYPE
            WHEN 'date' THEN 'TIMESTAMP'
            WHEN 'datetime' THEN 'TIMESTAMP'
            WHEN 'smalldatetime' THEN 'TIMESTAMP'
            WHEN 'timestamp' THEN 'TIMESTAMP'
            WHEN 'bigint' THEN 'INTEGER'
            WHEN 'int' THEN 'INTEGER'
            WHEN 'smallint' THEN 'INTEGER'
            WHEN 'tinyint' THEN 'INTEGER'
            WHEN 'decimal' THEN 'FLOAT'
            WHEN 'float' THEN 'FLOAT'
            WHEN 'money' THEN 'FLOAT'
            WHEN 'numeric' THEN 'FLOAT'
            ELSE 'STRING'
        END)
    from INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME='$TABLE_NAME' AND TABLE_SCHEMA='$TABLE_SCHEMA'
"

cols=''
# colcnt=1;
for row in `sqlcmd $mssqlargs -Q "$sql_query" | awk 'NR>3 {print last} {last=$0}'`
do
    cols+="$row,"
done
cols=${cols%?}

# import data to big query
bcp $TABLE_NAME out /workspace/mssql_output/$TABLE_NAME.csv $mssqlargs -q -c -t"@**@" -r"\n*@@*"
python3 /app/csvbqcols.py "/workspace/mssql_output/${TABLE_NAME}.csv" "/workspace/mssql_output/${TABLE_NAME}.tmp.csv" -c $cols
sed $'s/[^[:print:]\t]//g' /workspace/mssql_output/${TABLE_NAME}.tmp.csv > /workspace/mssql_output/${TABLE_NAME}.tmp1.csv #REMOVE SPECIAL CHARS
sed '$ d' /workspace/mssql_output/${TABLE_NAME}.tmp1.csv > /workspace/mssql_output/${TABLE_NAME}.csv #REMOVE LAST LINE 

bq_safe_mk $LOCATION $DATASET
BQ_ARGS="--location=$LOCATION --replace --source_format=CSV "
if [[ -f "/workspace/mssql_output/${TABLE_NAME}.csv" ]]
then
    if ! bq load $BQ_ARGS "${DATASET}.${TABLE_NAME}" "/workspace/mssql_output/${TABLE_NAME}.csv" $cols; then
        echo "ERROR: bq load failed for /workspace/mssql_output/${TABLE_NAME}.csv, check file exists in cloud."
    fi
fi

cleanup_files