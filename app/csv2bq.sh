#!/bin/bash
DATASET=$1

maxbad=3000

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
    rm -f /workspace/dbf_input/*
    rm -f /workspace/dbf_output/*
}

# import data to big query
bq_safe_mk $LOCATION $DATASET

# init directories
mkdir -p /workspace/dbf_input
mkdir -p /workspace/dbf_output

for filename in /workspace/dbf_output/*.csv; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    echo "Loading files $filename into Big Query"
    tablename="${filename/.csv/}"
    tablename="${tablename/.\/dbf_output\/}"
    echo $tablename
    BQ_ARGS="--location=$LOCATION --nosync --replace --source_format=CSV --autodetect --skip_leading_rows=1"
    if ! bq load $BQ_ARGS "${DATASET}.${tablename}" "$filename"; then
        echo "ERROR: bq load failed for $file, check file exists in cloud."
    fi
done

cleanup_files