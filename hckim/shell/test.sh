#!/bin/bash
POOL=/sapmnt/production/makeresults/newdb/POOL_ST_CONT/epm/opt/linuxx86_64
WDFLAST=`ssh root@lu246053.dhcp.wdf.sap.corp "cat $POOL/LastBuild/__installer.HDB/server/manifest | grep 2013 | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'"`
POOLVERSION=`cat $POOL/LastBuild/__installer.HDB/server/manifest | grep 2013 | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`

echo $WDFLAST
echo $POOLVERSION
