#!/bin/bash

set -e

if [[ $MYSQL_DATABASE == "" ]]; then
    echo "undefined MYSQL_DATABASE"
    exit 1
fi
if [[ $MYSQL_MASTER_SERVERS == "" ]]; then
    echo "undefined MYSQL_MASTER_SERVERS"
    exit 1
fi

servers=(${MYSQL_MASTER_SERVERS//,/ })
for server in ${servers[@]}; do
    count=0
    while true; do
        if ! mysqladmin ping -u root -h "$server" --silent; then
            echo "ping ..."
            count=0
        else
            count=$(expr $count + 1)
        fi
        if (( ${count} >= 3 )); then
            break
        fi
        sleep 1
    done
done

dump_file_path="/tmp/dump-files"
mkdir -p "${dump_file_path}"

gtid_executed=()

for server in ${servers[@]}; do
    mysqldump -u root \
              -h ${server} \
              --default-character-set=binary \
              --master-data=2 \
              --single-transaction \
              -c \
              --routines \
              --triggers \
              --events \
              --order-by-primary \
              --hex-blob \
              --databases ${MYSQL_DATABASE} > "${dump_file_path}/${server}.sql"
    gtid_executed+=($(mysql -N -B -h ${server} -u root -e 'select @@global.gtid_executed'))
done

mysql -u root -e "SET global read_only = ON"
mysql -u root -e "STOP SLAVE"
mysql -u root -e "RESET SLAVE ALL"
mysql -u root -e "RESET MASTER"

# join
g=$(IFS=,; echo "${gtid_executed[*]}")
g=$(echo -n "${g}" | perl -pe 's/\n//g')
mysql -u root -e "SET GLOBAL GTID_PURGED=\"${g}\""

for server in ${servers[@]}; do
    cat "${dump_file_path}/${server}.sql" | grep -v "GLOBAL.GTID_PURGED=" | mysql -u root --default-character-set=binary
    mysql -u root -e "CHANGE MASTER TO MASTER_HOST='${server}', MASTER_USER='root', MASTER_AUTO_POSITION=1 FOR CHANNEL '${server}'"
done

mysql -u root -e "START SLAVE"

