#!/bin/bash
DBF_INPUT=$1
MYSQL_CONN=$2
TABLE_SCHEMA=$3

source /home/mysql_conn.sh


for filename in /workspace/$DBF_INPUT/*.dbf; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    tablename="${filename/.dbf/}"
    tablename="${tablename/.\/$DBF_INPUT\/}"
    echo $tablename

    echo "Loading files $TABLE_SCHEMA . $filename into $MYSQL_CONN"

    DBF_ARGS="-h$MYSQL_HOST -U$MYSQL_ROOT -P$MYSQL_PASS -d$TABLE_SCHEMA -t$tablename -c"
    if ! dbf2mysql $DBF_ARGS "$filename" -s ADD='`ADD`',MODE='`MODE`',YEAR='`YEAR`',_NullFlags=; then
        echo "ERROR: dbf2mysql load failed for $filename, check file exists in cloud."
    fi
done

for filename in /workspace/$DBF_INPUT/*.DBF; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    tablename="${filename/.DBF/}"
    tablename="${tablename/.\/$DBF_INPUT\/}"
    echo $tablename

    echo "Loading files $TABLE_SCHEMA . $filename into $MYSQL_CONN"

    DBF_ARGS="-h$MYSQL_HOST -U$MYSQL_ROOT -P$MYSQL_PASS -d$TABLE_SCHEMA -t$tablename -c"
    if ! dbf2mysql $DBF_ARGS "$filename" -s ADD='`ADD`',MODE='`MODE`',YEAR='`YEAR`',_NullFlags=; then
        echo "ERROR: dbf2mysql load failed for $filename, check file exists in cloud."
    fi
done

for filename in /workspace/$DBF_INPUT/*.Dbf; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    tablename="${filename/.Dbf/}"
    tablename="${tablename/.\/$DBF_INPUT\/}"
    echo $tablename

    echo "Loading files $TABLE_SCHEMA . $filename into $MYSQL_CONN"

    DBF_ARGS="-h$MYSQL_HOST -U$MYSQL_ROOT -P$MYSQL_PASS -d$TABLE_SCHEMA -t$tablename -c"
    if ! dbf2mysql $DBF_ARGS "$filename" -s ADD='`ADD`',MODE='`MODE`',YEAR='`YEAR`',_NullFlags=; then
        echo "ERROR: dbf2mysql load failed for $filename, check file exists in cloud."
    fi
done
