#!/bin/bash
BUCKET_NAME=$1
MYSQL_CONN=$2
TABLE_SCHEMA=$3
DATASET=$4
#https://gist.github.com/intotecho/173401b1ce1a2c18decc3ce22ffeb5a7

source /home/mysql_conn.sh

# gcloud config set project $PROJECT_ID

upload_folder="$BUCKET_NAME/UPLOAD/$TABLE_SCHEMA/"

# Cleanup function called on exit
function cleanup_files () {
  gsutil rm gs://$upload_folder*.gz
  echo "cleanup done"
}

if [ $# -ne r2 ];then
echo "Copy all tables in a schema from MYSQL to existing bucket in current gcp project then import to BigQuery dataset $DATASET."
echo "usage: $0 BUCKET_NAME SCHEMA_NAME"
exit 1
fi

for tbl_name in `mysqlshow $mysqlargs $TABLE_SCHEMA | awk 'NR > 4 {print $2}'`
do
  echo "Start importing $tbl_name"
  bash /app/mysql_table_to_big_query_dataset.sh "$BUCKET_NAME" "$MYSQL_CONN" "$TABLE_SCHEMA" "$tbl_name" "$DATASET"
done
cleanup_files
echo "Done. Results. View status in script_succ_*.log and script_err_*.log"


