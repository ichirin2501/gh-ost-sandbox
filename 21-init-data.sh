#!/bin/bash

set -e

if [[ $MYSQL_DATABASE == "" ]]; then
    echo "undefined MYSQL_DATABASE"
    exit 1
fi
if [[ $MYSQL_INIT_DATA_SIZE_LIST == "" ]]; then
    echo "undefined MYSQL_INIT_DATA_SIZE_LIST"
    exit 1
fi

count=0
while true; do
    if ! mysqladmin ping -u root --silent; then
        echo "ping ..."
        count=0
    else
    count=$(expr $count + 1)
    fi
    if (( ${count} >= 5 )); then
        break
    fi
    sleep 1
done

list=(${MYSQL_INIT_DATA_SIZE_LIST//,/ })

for d in ${list[@]}; do
    s=(${d//:/ })
    if (( ${#s[@]} != 2 )); then
        echo "failed to parse data: $s"
        exit 1
    fi
    table_name=${s[0]}
    size=${s[1]}

    mysql_random_data_load -s /var/run/mysqld/mysqld.sock -u root ${MYSQL_DATABASE} ${table_name} ${size}
done
