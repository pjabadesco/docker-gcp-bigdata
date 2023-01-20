#!/bin/bash
BUCKET_NAME=$1
MYSQL_CONN=$2
TABLE_SCHEMA=$3
TABLE_NAME=$4
# PROJECT_ID=`gcloud config list --format 'value(core.project)' 2>/dev/null`
UIDX=`date  '+_%Y_%m_%d'`
# DATASET="$TABLE_SCHEMA$UIDX"
DATASET="${MYSQL_CONN}_${TABLE_SCHEMA}"
upload_folder="$BUCKET_NAME/UPLOAD/$TABLE_SCHEMA/"
mysql_output="/workspace/mysql_output/$TABLE_NAME"
json_query_file="/workspace/mysql_output/$TABLE_NAME.json_query.txt"
#https://gist.github.com/intotecho/173401b1ce1a2c18decc3ce22ffeb5a7

source /home/mysql_conn.sh

# init directories
mkdir -p /workspace/mysql_output

# gcloud config set project $PROJECT_ID
echo "Import $TABLE_SCHEMA.$TABLE_NAME from MySQL to BigQuery $PROJECT_ID:$DATASET.$TABLE_NAME via bucket $upload_folder"

#  uncomment set -x for more printouts
#set -x

mytime=`date '+%y%m%d%H%M'`
# hostname=`hostname | tr 'A-Z' 'a-z'`
file_prefix="$TABLE_NAME$mytime$TABLE_SCHEMA"
file_prefix_path="mysql_output/$TABLE_NAME$mytime$TABLE_SCHEMA"

echo $file_prefix
splitat="4000000000"
bulkfiles=200
maxbad=3000


# Cleanup function called on exit
function cleanup_files () {
  rm -f ${mysql_output}.*
  rm -f ${file_prefix_path}*
  rm -f $json_query_file
  gsutil rm gs://$upload_folder$TABLE_NAME.sql
  gsutil rm gs://$upload_folder$TABLE_NAME.json
  gsutil rm gs://$upload_folder$TABLE_NAME*.gz
  echo "cleanup done"
}


# make sure bucket, schema and table names are supplied
if [ $# -ne 4 ];then
echo "Copy a table from MySQL schema to existing bucket in current gcp project then import to BigQuery dataset $DATASET."
echo "usage: $0 BUCKET_NAME MYSQL_CONN SCHEMA_NAME TABLE_NAME"
exit 1
fi

echo "Creating JSON schema from mysql table structure"
cat > $json_query_file << heredoc
select CONCAT('{"name": "', (CASE WHEN LEFT(COLUMN_NAME,1) REGEXP '^[0-9]+$' THEN CONCAT('_',COLUMN_NAME) ELSE COLUMN_NAME END), '","type":"', IF(DATA_TYPE like "%date%", "TIMESTAMP",IF(DATA_TYPE like "%timestamp%","TIMESTAMP",IF(DATA_TYPE like "%int%", "INTEGER",IF(DATA_TYPE = "decimal","FLOAT","STRING")))) , '"},') as json from information_schema.columns where TABLE_SCHEMA = '$TABLE_SCHEMA' AND TABLE_NAME = '$TABLE_NAME' ORDER BY ORDINAL_POSITION ASC;
heredoc
echo '[' > $mysql_output.json
mysql $mysqlargs -Bs < $json_query_file | sed '$s/,$//' >> $mysql_output.json
mysql $mysqlargs $TABLE_SCHEMA -Bse"show create table $TABLE_NAME\G" > $mysql_output.sql
echo ']' >> $mysql_output.json

echo "Uploading schemas: $TABLE_NAME.json, $TABLE_NAME.sql to cloud: $upload_folder"
gsutil cp $mysql_output.json gs://$upload_folder
gsutil cp $mysql_output.sql gs://$upload_folder

echo "Exporting table: $TABLE_SCHEMA.$TABLE_NAME to CSV-like file: $mysql_output.txt1"
MYSQL_COLS_SQL="SET SESSION group_concat_max_len = 1000000; select GROUP_CONCAT((CASE WHEN DATA_TYPE like \"%date%\" THEN CONCAT('STR_TO_DATE(IF(\`',COLUMN_NAME,'\`>\"1900-01-01\",\`',COLUMN_NAME,'\`,null),\"%Y-%m-%d %T\")') ELSE CONCAT('\`' , COLUMN_NAME , '\`') END) ORDER BY ORDINAL_POSITION ASC) from information_schema. columns where TABLE_SCHEMA = '$TABLE_SCHEMA' AND TABLE_NAME = '$TABLE_NAME';"
MYSQL_COLS=$(mysql $mysqlargs $TABLE_SCHEMA -se "$MYSQL_COLS_SQL")
echo $MYSQL_COLS
mysql $mysqlargs $TABLE_SCHEMA --quick -Bse"select $MYSQL_COLS from $TABLE_NAME" > $mysql_output.txt1
FILESIZE=$(stat -c%s "$mysql_output.txt1")
if [ -s "$mysql_output.txt1" ]
then
   echo "Converting file $mysql_output.txt1 $FILESIZE to CSV format for Big Query"
else
  echo "$mysql_output.txt1 is empty or does not exist! Exiting."
  cleanup_files
  exit 3
fi
echo 'tr'
tr -d "\r" < $mysql_output.txt1 > $mysql_output.txt
# echo 'sed1'
# sed -i "s/$/\t$TABLE_SCHEMA/"  $TABLE_NAME.txt
echo 'sed2'
sed -i 's/(Ctrl-v)(Ctrl-m)//g' $mysql_output.txt

echo "Spliting large file $mysql_output.txt to files with prefix $file_prefix_path"
split -C $splitat $mysql_output.txt $file_prefix_path

#echo "Loop and upload $file_prefix to google cloud"
for file in `ls $file_prefix_path*`
do
  # big query does not seem to like double quotes and NULL
  sed -i -e 's/\"//g' -e's/NULL//g' $file
  gzip $file
  echo "Uploading CSV dumpfile: $file.gz to google cloud: $upload_folder"
  gsutil cp $file.gz gs://$upload_folder
  if [ $? -ne 0 ];then
    echo "$file could not be uploaded to cloud"
    cleanup_files
    exit 3
  fi
  #rm -f $file.gz
done

#check if data set exists and create if not
bq_safe_mk() {
    dataset=$1
    exists=$(bq ls -d | grep -w $dataset)
    if [ -n "$exists" ]; then
       echo "BigQuery Dataset $dataset already exists"
    else
       echo "Creating BigQuery Dataset $dataset"
       bq mk --location=$LOCATION $dataset
    fi
}

# import data to big query
bq_safe_mk $DATASET
#echo "Check what's matching in the bucketi: $upload_folder$file_prefix"
filelist=`gsutil ls gs://$upload_folder$file_prefix*.gz | xargs -n$bulkfiles | tr ' ', ','`
echo "Loading files $filelist into Big Query"

COUNTER=0
for mylist in $filelist
do
  # Check if we have a TIMESTAMP or DATE column, if we do then we can use partitioning
  COUNTER=$((COUNTER+1))
  job_id=$file_prefix$COUNTER
  BQ_ARGS="--location=$LOCATION --replace -F \t --job_id=$job_id --max_bad_records=$maxbad"
  echo "bq rm -f -t ${DATASET}.${TABLE_NAME}"
  bq rm -f -t "${DATASET}.${TABLE_NAME}"
  echo "bq load $BQ_ARGS "${DATASET}.${TABLE_NAME}" "$mylist" "${mysql_output}.json
  if ! bq load $BQ_ARGS "${DATASET}.${TABLE_NAME}" "$mylist" "${mysql_output}.json"; then
    echo "ERROR: bq load failed for $file, check file exists in cloud."
    # cleanup_files
    # exit 2
  fi
done

echo "$0 completed."
cleanup_files
exit
