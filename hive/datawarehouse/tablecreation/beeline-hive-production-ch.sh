#!/usr/bin/env bash
echo "<<beeline -f>>  PASSWORDFILE EXECUTIONFILE "
PASSWORDFILE=$(pwd)/$1
EXECUTIONFILE=$(pwd)/$2
echo " |||| ----- EXECUTION PRINTED WITH CONNECTION SCTRING ----- |||| "
while IFS='' read -r line || [[ -n "$line" ]]; do
    LOCAL_PASSWORD="$line"
    LOCAL_CONNECT=$( echo " !connect jdbc:hive2://chpbda04:10000/staged_akamai;user=oracle;password=${LOCAL_PASSWORD};principal=hive/chpbda04.prod.ch.perform.local@BDA2.PERFORMGROUP.COM ;")
    sed  -i "1i ${LOCAL_CONNECT}" ${EXECUTIONFILE}
    beeline -f $EXECUTIONFILE
    sed -i '1d' ${EXECUTIONFILE}
done < "$PASSWORDFILE"
