#!/bin/bash
BUCKET_NAME=$1
MSSQL_CONN=$2
TABLE_SCHEMA=$3
TABLE_EXCLUDES=$4

source /home/mssql_conn.sh

sql_query="
    SELECT DISTINCT TABLE_NAME from INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = '"$TABLE_SCHEMA"'
        AND TABLE_NAME NOT LIKE 'a_%' 
        AND TABLE_NAME NOT LIKE 'MSmerge%'
        AND TABLE_NAME NOT LIKE 'Test%'
        AND TABLE_NAME NOT LIKE 'Temp%'
        AND TABLE_NAME NOT LIKE 'vw%'
        AND TABLE_NAME NOT LIKE 'x%'
"

TABLE_EXCLUDES_LEN=${#TABLE_EXCLUDES}
if (( $TABLE_EXCLUDES_LEN > 0 )); then
    EX_ARRAY=($(echo "$TABLE_EXCLUDES" | tr ',' '\n'))
    for element in "${EX_ARRAY[@]}"
    do
        sql_query+=" AND TABLE_NAME NOT LIKE '${element}'"        
    done
    echo $sql_query
fi

for tbl_name in `sqlcmd $mssqlargs -Q "$sql_query" | awk 'NR>3 {print last} {last=$0}'`
do
    echo "Start importing $tbl_name"
    bash /app/mssql_table_to_big_query.sh "$BUCKET_NAME" "$MSSQL_CONN" "$TABLE_SCHEMA" "$tbl_name"
done
# echo "Done. Results. View status in script_succ_*.log and script_err_*.log"