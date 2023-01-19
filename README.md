
##

    docker run --rm -it --entrypoint bash docker-gcp-bigdata:latest

    docker run --rm -it --entrypoint bash pjabadesco/docker-gcp-bigdata:latest

## MYSQL - BIGQUERY EXAMPLE

```sh

PROJECT_ID="PROJECTID"
LOCATION="asia-southeast1"
GCP_CREDS="/home/certs/credentials.json"
gcloud auth activate-service-account --key-file="$GCP_CREDS"
gcloud config set project "$PROJECT_ID"
gcloud config set compute/region "$LOCATION"

gcloud projects list

BUCKET_NAME=$1
MYSQL_CONN=
TABLE_SCHEMA=
TABLE_NAME=
DATASET=

bash /app/mysql_table_to_big_query_dataset.sh $BUCKET_NAME $MYSQL_CONN $TABLE_SCHEMA $TABLE_NAME $DATASET
bash -xv /app/mysql_schema_to_big_query_dataset.sh  "$BUCKET_NAME" "$MYSQL_CONN" "$TABLE_SCHEMA" "$TABLE_NAME" "$DATASET"

```
