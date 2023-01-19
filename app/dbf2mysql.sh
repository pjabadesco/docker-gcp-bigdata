#!/bin/bash
DBF_INPUT=$1
MYSQL_CONN=$2
TABLE_SCHEMA=$3

source /home/mysql_conn.sh

# init directories
mkdir -p /workspace/dbf_input/$DBF_INPUT

# S="ACCESSIBLE='`ACCESSIBLE`',ACCOUNT='`ACCOUNT`',ACTION='`ACTION`',ADD='`ADD`',ADMIN='`ADMIN`',AFTER='`AFTER`',AGAINST='`AGAINST`',AGGREGATE='`AGGREGATE`',ALGORITHM='`ALGORITHM`',ALL='`ALL`',ALTER='`ALTER`',ALWAYS='`ALWAYS`',ANALYSE='`ANALYSE`',ANALYZE='`ANALYZE`',AND='`AND`',ANY='`ANY`',AS='`AS`',ASC='`ASC`',ASCII='`ASCII`',ASENSITIVE='`ASENSITIVE`',AT='`AT`',AUTHORS='`AUTHORS`',AUTOEXTEND_SIZE='`AUTOEXTEND_SIZE`',AUTO_INCREMENT='`AUTO_INCREMENT`',AVG='`AVG`',AVG_ROW_LENGTH='`AVG_ROW_LENGTH`',BACKUP='`BACKUP`',BEFORE='`BEFORE`',BEGIN='`BEGIN`',BETWEEN='`BETWEEN`',BIGINT='`BIGINT`',BINARY='`BINARY`',BINLOG='`BINLOG`',BIT='`BIT`',BLOB='`BLOB`',BLOCK='`BLOCK`',BOOL='`BOOL`',BOOLEAN='`BOOLEAN`',BOTH='`BOTH`',BTREE='`BTREE`',BUCKETS='`BUCKETS`',BY='`BY`',BYTE='`BYTE`',CACHE='`CACHE`',CALL='`CALL`',CASCADE='`CASCADE`',CASCADED='`CASCADED`',CASE='`CASE`',CATALOG_NAME='`CATALOG_NAME`',CHAIN='`CHAIN`',CHANGE='`CHANGE`',CHANGED='`CHANGED`',CHANNEL='`CHANNEL`',CHAR='`CHAR`',CHARACTER='`CHARACTER`',CHARSET='`CHARSET`',CHECK='`CHECK`',CHECKSUM='`CHECKSUM`',CIPHER='`CIPHER`',CLASS_ORIGIN='`CLASS_ORIGIN`',CLIENT='`CLIENT`',CLONE='`CLONE`',CLOSE='`CLOSE`',COALESCE='`COALESCE`',CODE='`CODE`',COLLATE='`COLLATE`',COLLATION='`COLLATION`',COLUMN='`COLUMN`',COLUMNS='`COLUMNS`',COLUMN_FORMAT='`COLUMN_FORMAT`',COLUMN_NAME='`COLUMN_NAME`',COMMENT='`COMMENT`',COMMIT='`COMMIT`',COMMITTED='`COMMITTED`',COMPACT='`COMPACT`',COMPLETION='`COMPLETION`',COMPONENT='`COMPONENT`',COMPRESSED='`COMPRESSED`',COMPRESSION='`COMPRESSION`',CONCURRENT='`CONCURRENT`',CONDITION='`CONDITION`',CONNECTION='`CONNECTION`',CONSISTENT='`CONSISTENT`',CONSTRAINT='`CONSTRAINT`',CONSTRAINT_CATALOG='`CONSTRAINT_CATALOG`',CONSTRAINT_NAME='`CONSTRAINT_NAME`',CONSTRAINT_SCHEMA='`CONSTRAINT_SCHEMA`',CONTAINS='`CONTAINS`',CONTEXT='`CONTEXT`',CONTINUE='`CONTINUE`',CONTRIBUTORS='`CONTRIBUTORS`',CONVERT='`CONVERT`',CPU='`CPU`',CREATE='`CREATE`',CROSS='`CROSS`',CUBE='`CUBE`',CUME_DIST='`CUME_DIST`',CURRENT='`CURRENT`',CURRENT_DATE='`CURRENT_DATE`',CURRENT_TIME='`CURRENT_TIME`',CURRENT_TIMESTAMP='`CURRENT_TIMESTAMP`',CURRENT_USER='`CURRENT_USER`',CURSOR='`CURSOR`',CURSOR_NAME='`CURSOR_NAME`',DATA='`DATA`',DATABASE='`DATABASE`',DATABASES='`DATABASES`',DATAFILE='`DATAFILE`',DATE='`DATE`',DATETIME='`DATETIME`',DAY='`DAY`',DAY_HOUR='`DAY_HOUR`',DAY_MICROSECOND='`DAY_MICROSECOND`',DAY_MINUTE='`DAY_MINUTE`',DAY_SECOND='`DAY_SECOND`',DEALLOCATE='`DEALLOCATE`',DEC='`DEC`',DECIMAL='`DECIMAL`',DECLARE='`DECLARE`',DEFAULT='`DEFAULT`',DEFAULT_AUTH='`DEFAULT_AUTH`',DEFINER='`DEFINER`',DEFINITION='`DEFINITION`',DELAYED='`DELAYED`',DELAY_KEY_WRITE='`DELAY_KEY_WRITE`',DELETE='`DELETE`',DENSE_RANK='`DENSE_RANK`',DESC='`DESC`',DESCRIBE='`DESCRIBE`',DESCRIPTION='`DESCRIPTION`',DES_KEY_FILE='`DES_KEY_FILE`',DETERMINISTIC='`DETERMINISTIC`',DIAGNOSTICS='`DIAGNOSTICS`',DIRECTORY='`DIRECTORY`',DISABLE='`DISABLE`',DISCARD='`DISCARD`',DISK='`DISK`',DISTINCT='`DISTINCT`',DISTINCTROW='`DISTINCTROW`',DIV='`DIV`',DO='`DO`',DOUBLE='`DOUBLE`',DROP='`DROP`',DUAL='`DUAL`',DUMPFILE='`DUMPFILE`',DUPLICATE='`DUPLICATE`',DYNAMIC='`DYNAMIC`',EACH='`EACH`',ELSE='`ELSE`',ELSEIF='`ELSEIF`',EMPTY='`EMPTY`',ENABLE='`ENABLE`',ENCLOSED='`ENCLOSED`',ENCRYPTION='`ENCRYPTION`',END='`END`',ENDS='`ENDS`',ENGINE='`ENGINE`',ENGINES='`ENGINES`',ENUM='`ENUM`',ERROR='`ERROR`',ERRORS='`ERRORS`',ESCAPE='`ESCAPE`',ESCAPED='`ESCAPED`',EVENT='`EVENT`',EVENTS='`EVENTS`',EVERY='`EVERY`',EXCEPT='`EXCEPT`',EXCHANGE='`EXCHANGE`',EXCLUDE='`EXCLUDE`',EXECUTE='`EXECUTE`',EXISTS='`EXISTS`',EXIT='`EXIT`',EXPANSION='`EXPANSION`',EXPIRE='`EXPIRE`',EXPLAIN='`EXPLAIN`',EXPORT='`EXPORT`',EXTENDED='`EXTENDED`',EXTENT_SIZE='`EXTENT_SIZE`',FALSE='`FALSE`',FAST='`FAST`',FAULTS='`FAULTS`',FETCH='`FETCH`',FIELDS='`FIELDS`',FILE='`FILE`',FILE_BLOCK_SIZE='`FILE_BLOCK_SIZE`',FILTER='`FILTER`',FIRST='`FIRST`',FIRST_VALUE='`FIRST_VALUE`',FIXED='`FIXED`',FLOAT='`FLOAT`',FLOAT4='`FLOAT4`',FLOAT8='`FLOAT8`',FLUSH='`FLUSH`',FOLLOWING='`FOLLOWING`',FOLLOWS='`FOLLOWS`',FOR='`FOR`',FORCE='`FORCE`',FOREIGN='`FOREIGN`',FORMAT='`FORMAT`',FOUND='`FOUND`',FRAC_SECOND='`FRAC_SECOND`',FROM='`FROM`',FULL='`FULL`',FULLTEXT='`FULLTEXT`',FUNCTION='`FUNCTION`',GENERAL='`GENERAL`',GENERATED='`GENERATED`',GEOMCOLLECTION='`GEOMCOLLECTION`',GEOMETRY='`GEOMETRY`',GEOMETRYCOLLECTION='`GEOMETRYCOLLECTION`',GET='`GET`',GET_FORMAT='`GET_FORMAT`',GET_MASTER_PUBLIC_KEY='`GET_MASTER_PUBLIC_KEY`',GLOBAL='`GLOBAL`',GRANT='`GRANT`',GRANTS='`GRANTS`',GROUP='`GROUP`',GROUPING='`GROUPING`',GROUPS='`GROUPS`',GROUP_REPLICATION='`GROUP_REPLICATION`',HANDLER='`HANDLER`',HASH='`HASH`',HAVING='`HAVING`',HELP='`HELP`',HIGH_PRIORITY='`HIGH_PRIORITY`',HISTOGRAM='`HISTOGRAM`',HISTORY='`HISTORY`',HOST='`HOST`',HOSTS='`HOSTS`',HOUR='`HOUR`',HOUR_MICROSECOND='`HOUR_MICROSECOND`',HOUR_MINUTE='`HOUR_MINUTE`',HOUR_SECOND='`HOUR_SECOND`',IDENTIFIED='`IDENTIFIED`',IF='`IF`',IGNORE='`IGNORE`',IGNORE_SERVER_IDS='`IGNORE_SERVER_IDS`',IMPORT='`IMPORT`',IN='`IN`',INDEX='`INDEX`',"
# S+="INDEXES='`INDEXES`',INFILE='`INFILE`',INITIAL_SIZE='`INITIAL_SIZE`',INNER='`INNER`',INNOBASE='`INNOBASE`',INNODB='`INNODB`',INOUT='`INOUT`',INSENSITIVE='`INSENSITIVE`',INSERT='`INSERT`',INSERT_METHOD='`INSERT_METHOD`',INSTALL='`INSTALL`',INSTANCE='`INSTANCE`',INT='`INT`',INT1='`INT1`',INT2='`INT2`',INT3='`INT3`',INT4='`INT4`',INT8='`INT8`',INTEGER='`INTEGER`',INTERVAL='`INTERVAL`',INTO='`INTO`',INVISIBLE='`INVISIBLE`',INVOKER='`INVOKER`',IO='`IO`',IO_AFTER_GTIDS='`IO_AFTER_GTIDS`',IO_BEFORE_GTIDS='`IO_BEFORE_GTIDS`',IO_THREAD='`IO_THREAD`',IPC='`IPC`',IS='`IS`',ISOLATION='`ISOLATION`',ISSUER='`ISSUER`',ITERATE='`ITERATE`',JOIN='`JOIN`',JSON='`JSON`',JSON_TABLE='`JSON_TABLE`',KEY='`KEY`',KEYS='`KEYS`',KEY_BLOCK_SIZE='`KEY_BLOCK_SIZE`',KILL='`KILL`',LAG='`LAG`',LANGUAGE='`LANGUAGE`',LAST='`LAST`',LAST_VALUE='`LAST_VALUE`',LEAD='`LEAD`',LEADING='`LEADING`',LEAVE='`LEAVE`',LEAVES='`LEAVES`',LEFT='`LEFT`',LESS='`LESS`',LEVEL='`LEVEL`',LIKE='`LIKE`',LIMIT='`LIMIT`',LINEAR='`LINEAR`',LINES='`LINES`',LINESTRING='`LINESTRING`',LIST='`LIST`',LOAD='`LOAD`',LOCAL='`LOCAL`',LOCALTIME='`LOCALTIME`',LOCALTIMESTAMP='`LOCALTIMESTAMP`',LOCK='`LOCK`',LOCKED='`LOCKED`',LOCKS='`LOCKS`',LOGFILE='`LOGFILE`',LOGS='`LOGS`',LONG='`LONG`',LONGBLOB='`LONGBLOB`',LONGTEXT='`LONGTEXT`',LOOP='`LOOP`',LOW_PRIORITY='`LOW_PRIORITY`',MASTER='`MASTER`',MASTER_AUTO_POSITION='`MASTER_AUTO_POSITION`',MASTER_BIND='`MASTER_BIND`',MASTER_CONNECT_RETRY='`MASTER_CONNECT_RETRY`',MASTER_DELAY='`MASTER_DELAY`',MASTER_HEARTBEAT_PERIOD='`MASTER_HEARTBEAT_PERIOD`',MASTER_HOST='`MASTER_HOST`',MASTER_LOG_FILE='`MASTER_LOG_FILE`',MASTER_LOG_POS='`MASTER_LOG_POS`',MASTER_PASSWORD='`MASTER_PASSWORD`',MASTER_PORT='`MASTER_PORT`',MASTER_PUBLIC_KEY_PATH='`MASTER_PUBLIC_KEY_PATH`',MASTER_RETRY_COUNT='`MASTER_RETRY_COUNT`',MASTER_SERVER_ID='`MASTER_SERVER_ID`',MASTER_SSL='`MASTER_SSL`',MASTER_SSL_CA='`MASTER_SSL_CA`',MASTER_SSL_CAPATH='`MASTER_SSL_CAPATH`',MASTER_SSL_CERT='`MASTER_SSL_CERT`',MASTER_SSL_CIPHER='`MASTER_SSL_CIPHER`',MASTER_SSL_CRL='`MASTER_SSL_CRL`',MASTER_SSL_CRLPATH='`MASTER_SSL_CRLPATH`',MASTER_SSL_KEY='`MASTER_SSL_KEY`',MASTER_SSL_VERIFY_SERVER_CERT='`MASTER_SSL_VERIFY_SERVER_CERT`',MASTER_TLS_VERSION='`MASTER_TLS_VERSION`',MASTER_USER='`MASTER_USER`',MATCH='`MATCH`',MAXVALUE='`MAXVALUE`',MAX_CONNECTIONS_PER_HOUR='`MAX_CONNECTIONS_PER_HOUR`',MAX_QUERIES_PER_HOUR='`MAX_QUERIES_PER_HOUR`',MAX_ROWS='`MAX_ROWS`',MAX_SIZE='`MAX_SIZE`',MAX_UPDATES_PER_HOUR='`MAX_UPDATES_PER_HOUR`',MAX_USER_CONNECTIONS='`MAX_USER_CONNECTIONS`',MEDIUM='`MEDIUM`',MEDIUMBLOB='`MEDIUMBLOB`',MEDIUMINT='`MEDIUMINT`',MEDIUMTEXT='`MEDIUMTEXT`',MEMORY='`MEMORY`',MERGE='`MERGE`',MESSAGE_TEXT='`MESSAGE_TEXT`',MICROSECOND='`MICROSECOND`',MIDDLEINT='`MIDDLEINT`',MIGRATE='`MIGRATE`',MINUTE='`MINUTE`',MINUTE_MICROSECOND='`MINUTE_MICROSECOND`',MINUTE_SECOND='`MINUTE_SECOND`',MIN_ROWS='`MIN_ROWS`',MOD='`MOD`',MODE='`MODE`',MODIFIES='`MODIFIES`',MODIFY='`MODIFY`',MONTH='`MONTH`',MULTILINESTRING='`MULTILINESTRING`',MULTIPOINT='`MULTIPOINT`',MULTIPOLYGON='`MULTIPOLYGON`',MUTEX='`MUTEX`',MYSQL_ERRNO='`MYSQL_ERRNO`',NAME='`NAME`',NAMES='`NAMES`',NATIONAL='`NATIONAL`',NATURAL='`NATURAL`',NCHAR='`NCHAR`',NDB='`NDB`',NDBCLUSTER='`NDBCLUSTER`',NESTED='`NESTED`',NEVER='`NEVER`',NEW='`NEW`',NEXT='`NEXT`',NO='`NO`',NODEGROUP='`NODEGROUP`',NONE='`NONE`',NOT='`NOT`',NOWAIT='`NOWAIT`',NO_WAIT='`NO_WAIT`',NO_WRITE_TO_BINLOG='`NO_WRITE_TO_BINLOG`',NTH_VALUE='`NTH_VALUE`',NTILE='`NTILE`',NULL='`NULL`',NULLS='`NULLS`',NUMBER='`NUMBER`',NUMERIC='`NUMERIC`',NVARCHAR='`NVARCHAR`',OF='`OF`',OFFSET='`OFFSET`',OLD_PASSWORD='`OLD_PASSWORD`',ON='`ON`',ONE='`ONE`',ONE_SHOT='`ONE_SHOT`',ONLY='`ONLY`',OPEN='`OPEN`',OPTIMIZE='`OPTIMIZE`',OPTIMIZER_COSTS='`OPTIMIZER_COSTS`',OPTION='`OPTION`',OPTIONALLY='`OPTIONALLY`',OPTIONS='`OPTIONS`',OR='`OR`',ORDER='`ORDER`',ORDINALITY='`ORDINALITY`',OTHERS='`OTHERS`',OUT='`OUT`',OUTER='`OUTER`',OUTFILE='`OUTFILE`',OVER='`OVER`',OWNER='`OWNER`',PACK_KEYS='`PACK_KEYS`',PAGE='`PAGE`',PARSER='`PARSER`',PARSE_GCOL_EXPR='`PARSE_GCOL_EXPR`',PARTIAL='`PARTIAL`',PARTITION='`PARTITION`',PARTITIONING='`PARTITIONING`',PARTITIONS='`PARTITIONS`',PASSWORD='`PASSWORD`',PATH='`PATH`',PERCENT_RANK='`PERCENT_RANK`',PERSIST='`PERSIST`',PERSIST_ONLY='`PERSIST_ONLY`',PHASE='`PHASE`',PLUGIN='`PLUGIN`',PLUGINS='`PLUGINS`',PLUGIN_DIR='`PLUGIN_DIR`',POINT='`POINT`',POLYGON='`POLYGON`',PORT='`PORT`',PRECEDES='`PRECEDES`',PRECEDING='`PRECEDING`',PRECISION='`PRECISION`',PREPARE='`PREPARE`',PRESERVE='`PRESERVE`',PREV='`PREV`',PRIMARY='`PRIMARY`',PRIVILEGES='`PRIVILEGES`',PROCEDURE='`PROCEDURE`',PROCESS='`PROCESS`',PROCESSLIST='`PROCESSLIST`',PROFILE='`PROFILE`',PROFILES='`PROFILES`',PROXY='`PROXY`',PURGE='`PURGE`',QUARTER='`QUARTER`',QUERY='`QUERY`',QUICK='`QUICK`',RANGE='`RANGE`',RANK='`RANK`',READ='`READ`',READS='`READS`',READ_ONLY='`READ_ONLY`',READ_WRITE='`READ_WRITE`',REAL='`REAL`',REBUILD='`REBUILD`',RECOVER='`RECOVER`',RECURSIVE='`RECURSIVE`',REDOFILE='`REDOFILE`',"
# S+="REDO_BUFFER_SIZE='`REDO_BUFFER_SIZE`',REDUNDANT='`REDUNDANT`',REFERENCE='`REFERENCE`',REFERENCES='`REFERENCES`',REGEXP='`REGEXP`',RELAY='`RELAY`',RELAYLOG='`RELAYLOG`',RELAY_LOG_FILE='`RELAY_LOG_FILE`',RELAY_LOG_POS='`RELAY_LOG_POS`',RELAY_THREAD='`RELAY_THREAD`',RELEASE='`RELEASE`',RELOAD='`RELOAD`',REMOTE='`REMOTE`',REMOVE='`REMOVE`',RENAME='`RENAME`',REORGANIZE='`REORGANIZE`',REPAIR='`REPAIR`',REPEAT='`REPEAT`',REPEATABLE='`REPEATABLE`',REPLACE='`REPLACE`',REPLICATE_DO_DB='`REPLICATE_DO_DB`',REPLICATE_DO_TABLE='`REPLICATE_DO_TABLE`',REPLICATE_IGNORE_DB='`REPLICATE_IGNORE_DB`',REPLICATE_IGNORE_TABLE='`REPLICATE_IGNORE_TABLE`',REPLICATE_REWRITE_DB='`REPLICATE_REWRITE_DB`',REPLICATE_WILD_DO_TABLE='`REPLICATE_WILD_DO_TABLE`',REPLICATE_WILD_IGNORE_TABLE='`REPLICATE_WILD_IGNORE_TABLE`',REPLICATION='`REPLICATION`',REQUIRE='`REQUIRE`',RESET='`RESET`',RESIGNAL='`RESIGNAL`',RESOURCE='`RESOURCE`',RESPECT='`RESPECT`',RESTART='`RESTART`',RESTORE='`RESTORE`',RESTRICT='`RESTRICT`',RESUME='`RESUME`',RETURN='`RETURN`',RETURNED_SQLSTATE='`RETURNED_SQLSTATE`',RETURNS='`RETURNS`',REUSE='`REUSE`',REVERSE='`REVERSE`',REVOKE='`REVOKE`',RIGHT='`RIGHT`',RLIKE='`RLIKE`',ROLE='`ROLE`',ROLLBACK='`ROLLBACK`',ROLLUP='`ROLLUP`',ROTATE='`ROTATE`',ROUTINE='`ROUTINE`',ROW='`ROW`',ROWS='`ROWS`',ROW_COUNT='`ROW_COUNT`',ROW_FORMAT='`ROW_FORMAT`',ROW_NUMBER='`ROW_NUMBER`',RTREE='`RTREE`',SAVEPOINT='`SAVEPOINT`',SCHEDULE='`SCHEDULE`',SCHEMA='`SCHEMA`',SCHEMAS='`SCHEMAS`',SCHEMA_NAME='`SCHEMA_NAME`',SECOND='`SECOND`',SECOND_MICROSECOND='`SECOND_MICROSECOND`',SECURITY='`SECURITY`',SELECT='`SELECT`',SENSITIVE='`SENSITIVE`',SEPARATOR='`SEPARATOR`',SERIAL='`SERIAL`',SERIALIZABLE='`SERIALIZABLE`',SERVER='`SERVER`',SESSION='`SESSION`',SET='`SET`',SHARE='`SHARE`',SHOW='`SHOW`',SHUTDOWN='`SHUTDOWN`',SIGNAL='`SIGNAL`',SIGNED='`SIGNED`',SIMPLE='`SIMPLE`',SKIP='`SKIP`',SLAVE='`SLAVE`',SLOW='`SLOW`',SMALLINT='`SMALLINT`',SNAPSHOT='`SNAPSHOT`',SOCKET='`SOCKET`',SOME='`SOME`',SONAME='`SONAME`',SOUNDS='`SOUNDS`',SOURCE='`SOURCE`',SPATIAL='`SPATIAL`',SPECIFIC='`SPECIFIC`',SQL='`SQL`',SQLEXCEPTION='`SQLEXCEPTION`',SQLSTATE='`SQLSTATE`',SQLWARNING='`SQLWARNING`',SQL_AFTER_GTIDS='`SQL_AFTER_GTIDS`',SQL_AFTER_MTS_GAPS='`SQL_AFTER_MTS_GAPS`',SQL_BEFORE_GTIDS='`SQL_BEFORE_GTIDS`',SQL_BIG_RESULT='`SQL_BIG_RESULT`',SQL_BUFFER_RESULT='`SQL_BUFFER_RESULT`',SQL_CACHE='`SQL_CACHE`',SQL_CALC_FOUND_ROWS='`SQL_CALC_FOUND_ROWS`',SQL_NO_CACHE='`SQL_NO_CACHE`',SQL_SMALL_RESULT='`SQL_SMALL_RESULT`',SQL_THREAD='`SQL_THREAD`',SQL_TSI_DAY='`SQL_TSI_DAY`',SQL_TSI_FRAC_SECOND='`SQL_TSI_FRAC_SECOND`',SQL_TSI_HOUR='`SQL_TSI_HOUR`',SQL_TSI_MINUTE='`SQL_TSI_MINUTE`',SQL_TSI_MONTH='`SQL_TSI_MONTH`',SQL_TSI_QUARTER='`SQL_TSI_QUARTER`',SQL_TSI_SECOND='`SQL_TSI_SECOND`',SQL_TSI_WEEK='`SQL_TSI_WEEK`',SQL_TSI_YEAR='`SQL_TSI_YEAR`',SRID='`SRID`',SSL='`SSL`',STACKED='`STACKED`',START='`START`',STARTING='`STARTING`',STARTS='`STARTS`',STATS_AUTO_RECALC='`STATS_AUTO_RECALC`',STATS_PERSISTENT='`STATS_PERSISTENT`',STATS_SAMPLE_PAGES='`STATS_SAMPLE_PAGES`',STATUS='`STATUS`',STOP='`STOP`',STORAGE='`STORAGE`',STORED='`STORED`',STRAIGHT_JOIN='`STRAIGHT_JOIN`',STRING='`STRING`',SUBCLASS_ORIGIN='`SUBCLASS_ORIGIN`',SUBJECT='`SUBJECT`',SUBPARTITION='`SUBPARTITION`',SUBPARTITIONS='`SUBPARTITIONS`',SUPER='`SUPER`',SUSPEND='`SUSPEND`',SWAPS='`SWAPS`',SWITCHES='`SWITCHES`',SYSTEM='`SYSTEM`',TABLE='`TABLE`',TABLES='`TABLES`',TABLESPACE='`TABLESPACE`',TABLE_CHECKSUM='`TABLE_CHECKSUM`',TABLE_NAME='`TABLE_NAME`',TEMPORARY='`TEMPORARY`',TEMPTABLE='`TEMPTABLE`',TERMINATED='`TERMINATED`',TEXT='`TEXT`',THAN='`THAN`',THEN='`THEN`',THREAD_PRIORITY='`THREAD_PRIORITY`',TIES='`TIES`',TIME='`TIME`',TIMESTAMP='`TIMESTAMP`',TIMESTAMPADD='`TIMESTAMPADD`',TIMESTAMPDIFF='`TIMESTAMPDIFF`',TINYBLOB='`TINYBLOB`',TINYINT='`TINYINT`',TINYTEXT='`TINYTEXT`',TO='`TO`',TRAILING='`TRAILING`',TRANSACTION='`TRANSACTION`',TRIGGER='`TRIGGER`',TRIGGERS='`TRIGGERS`',TRUE='`TRUE`',TRUNCATE='`TRUNCATE`',TYPE='`TYPE`',TYPES='`TYPES`',UNBOUNDED='`UNBOUNDED`',UNCOMMITTED='`UNCOMMITTED`',UNDEFINED='`UNDEFINED`',UNDO='`UNDO`',UNDOFILE='`UNDOFILE`',UNDO_BUFFER_SIZE='`UNDO_BUFFER_SIZE`',UNICODE='`UNICODE`',UNINSTALL='`UNINSTALL`',UNION='`UNION`',UNIQUE='`UNIQUE`',UNKNOWN='`UNKNOWN`',UNLOCK='`UNLOCK`',UNSIGNED='`UNSIGNED`',UNTIL='`UNTIL`',UPDATE='`UPDATE`',UPGRADE='`UPGRADE`',USAGE='`USAGE`',USE='`USE`',USER='`USER`',USER_RESOURCES='`USER_RESOURCES`',USE_FRM='`USE_FRM`',USING='`USING`',UTC_DATE='`UTC_DATE`',UTC_TIME='`UTC_TIME`',VALIDATION='`VALIDATION`',VALUES='`VALUES`',VARBINARY='`VARBINARY`',VARCHAR='`VARCHAR`',VARCHARACTER='`VARCHARACTER`',VARIABLES='`VARIABLES`',VARYING='`VARYING`',VCPU='`VCPU`',VIEW='`VIEW`',VIRTUAL='`VIRTUAL`',VISIBLE='`VISIBLE`',WAIT='`WAIT`',WARNINGS='`WARNINGS`',WEEK='`WEEK`',WEIGHT_STRING='`WEIGHT_STRING`',WHEN='`WHEN`',WHERE='`WHERE`',WHILE='`WHILE`',WINDOW='`WINDOW`',WITH='`WITH`',WITHOUT='`WITHOUT`',WORK='`WORK`',WRAPPER='`WRAPPER`',WRITE='`WRITE`',X509='`X509`',XA='`XA`',XID='`XID`',XML='`XML`',XOR='`XOR`',YEAR='`YEAR`',YEAR_MONTH='`YEAR_MONTH`',ZEROFILL='`ZEROFILL`'"

for filename in /workspace/dbf_input/$DBF_INPUT/*.dbf; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    tablename="${filename/.dbf/}"
    tablename="${tablename/.\/$DBF_INPUT\/}"
    echo $tablename

    echo "Loading files $TABLE_SCHEMA . $filename into $MYSQL_CONN"

    DBF_ARGS="-h$MYSQL_HOST -U$MYSQL_ROOT -P$MYSQL_PASS -d$TABLE_SCHEMA -t$tablename -c -q -r"
    if ! dbf2mysql $DBF_ARGS "$filename" -s $S; then
        echo "ERROR: dbf2mysql load failed for $filename, check file exists in cloud."
    fi
done

for filename in /workspace/dbf_input/$DBF_INPUT/*.DBF; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    tablename="${filename/.DBF/}"
    tablename="${tablename/.\/$DBF_INPUT\/}"
    echo $tablename

    echo "Loading files $TABLE_SCHEMA . $filename into $MYSQL_CONN"

    DBF_ARGS="-h$MYSQL_HOST -U$MYSQL_ROOT -P$MYSQL_PASS -d$TABLE_SCHEMA -t$tablename -c -q -r"
    if ! dbf2mysql $DBF_ARGS "$filename" -s $S; then
        echo "ERROR: dbf2mysql load failed for $filename, check file exists in cloud."
    fi
done

for filename in /workspace/dbf_input/$DBF_INPUT/*.Dbf; do
    [ -e "$filename" ] || continue
    # ... rest of the loop body 
    tablename="${filename/.Dbf/}"
    tablename="${tablename/.\/$DBF_INPUT\/}"
    echo $tablename

    echo "Loading files $TABLE_SCHEMA . $filename into $MYSQL_CONN"

    DBF_ARGS="-h$MYSQL_HOST -U$MYSQL_ROOT -P$MYSQL_PASS -d$TABLE_SCHEMA -t$tablename -c -q -r"
    if ! dbf2mysql $DBF_ARGS "$filename" -s $S; then
        echo "ERROR: dbf2mysql load failed for $filename, check file exists in cloud."
    fi
done