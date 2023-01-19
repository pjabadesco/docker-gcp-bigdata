#!/bin/bash
CSV_INPUT=$1
MYSQL_CONN=$2
TABLE_SCHEMA=$3

source mysql_conn.sh

for filename in /workspace/$CSV_INPUT/*.csv; do
    [ -e "$filename" ] || continue
    tablename="${filename/.dbf/}"
    tablename="${tablename/.Dbf/}"
    tablename="${tablename/.DBF/}"
    tablename="${tablename/.csv/}"
    tablename="${tablename/.\/$CSV_INPUT\/}"
    # ... rest of the loop body 
    sed -i 's/"T"/"1"/g' "$filename" # REPLACE "T" to "1"
    sed -i 's/"F"/"0"/g'  "$filename" # REPLACE "F" to "0"
    sed $'s/[^[:print:]\t]//g' "$filename" > "$filename.final" #REMOVE SPECIAL CHARS
    mysql $mysqlargs $TABLE_SCHEMA -Bse"TRUNCATE TABLE $tablename"
    mysql $mysqlargs $TABLE_SCHEMA -Bse"LOAD DATA LOCAL INFILE '$filename.final' REPLACE INTO TABLE $tablename CHARACTER SET latin1 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"'"
done

for filename in /workspace/$CSV_INPUT/*.CSV; do
    [ -e "$filename" ] || continue
    tablename="${filename/.dbf/}"
    tablename="${tablename/.Dbf/}"
    tablename="${tablename/.DBF/}"
    tablename="${tablename/.CSV/}"
    tablename="${tablename/.\/$CSV_INPUT\/}"
    # ... rest of the loop body 
    sed -i 's/"T"/"1"/g' "$filename" # REPLACE "T" to "1"
    sed -i 's/"F"/"0"/g'  "$filename" # REPLACE "F" to "0"
    sed $'s/[^[:print:]\t]//g' "$filename" > "$filename.final" #REMOVE SPECIAL CHARS
    mysql $mysqlargs $TABLE_SCHEMA -Bse"TRUNCATE TABLE $tablename"
    mysql $mysqlargs $TABLE_SCHEMA -Bse"LOAD DATA LOCAL INFILE '$filename.final' REPLACE INTO TABLE $tablename CHARACTER SET latin1 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"'"
done

