#!/usr/bin/sh
POOL=/sapmnt/production/makeresults/newdb_dev3/POOL_ST_CONT/epm/opt/linuxx86_64
AREA=/area51/temp/EPM_TEST_LANDSCAPE_DATA/branch_binaries/opt/linuxx86_64
LASTAREAVERSION=`ls -l $AREA/LastBuild | sed -e 's/.*\(201.*\)/\1/'`
POOLLIST=`ls /sapmnt/production/makeresults/newdb_dev3/POOL_ST_CONT/epm/opt/linuxx86_64`

for BINARY in $POOLLIST
do
	if [ $BINARY = "LastBuild" ]; then
		continue
	fi

BINARYTIME=`cat $POOL/$BINARY/__installer.HDB/server/manifest | grep 201 | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`

	if [ $BINARYTIME = $LASTAREAVERSION ]; then
		echo -e "SEL"
		ls -l $POOL | grep $BINARY
		echo -e ""

		echo -e "WDF"
		ssh root@lu246053.dhcp.wdf.sap.corp /home/hyunchang/check_copy.sh
		exit 0
	fi
done
