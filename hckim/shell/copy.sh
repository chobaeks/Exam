#/bin/bash
LOGPATH='/MD1200_1/hckim/logs'
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
LOGFILE=$LOGPATH/Log_copy_"$HOST"_"$TIME".log
POOL=/sapmnt/production/makeresults/newdb_dev3/POOL_ST_CONT/epm/opt/linuxx86_64
AREA=/area51/temp/EPM_TEST_LANDSCAPE_DATA/branch_binaries/opt/linuxx86_64
POOLVERSION=`cat $POOL/LastBuild/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
AREAVERSION=`cat $AREA/LastBuild/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
WDFLAST=`ssh root@lu246053.dhcp.wdf.sap.corp "cat $POOL/LastBuild/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'"`
A=0

function WRITELOG()
{
LOGTIME=`date`
echo -e "" >> $LOGFILE
echo -e "-------- $LOGTIME ---------- $1 -----------------------------" >> $LOGFILE
echo -e "" >> $LOGFILE
}

WRITELOG "Sync Check...."
while [ $WDFLAST != $POOLVERSION ]; do 
	if [ $A -eq 30 ]; then
		exit 0
	fi
	echo "different...waiting 600s" >> $LOGFILE
	sleep 600
	A=`expr $A + 1`
POOLVERSION=`cat $POOL/LastBuild/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
done
WRITELOG "Sync OK"

WRITELOG "SEL Start"
if [ $POOLVERSION != $AREAVERSION ]; then
	mkdir $AREA/$POOLVERSION 

WRITELOG "Copy Start"
	cp $POOL/LastBuild/* $AREA/$POOLVERSION
	cp -r $POOL/LastBuild/__installer.HDB $AREA/$POOLVERSION
	cp -r $POOL/LastBuild/test $AREA/$POOLVERSION
WRITELOG "Copy End"

	rm $AREA/LastBuild
	ln -s $POOLVERSION $AREA/LastBuild
else
	echo -e "Nothing to do" >> $LOGFILE
fi
WRITELOG "SEL End"

WRITELOG "WDF Start"
ssh root@lu246053.dhcp.wdf.sap.corp /home/hyunchang/backup.sh >> $LOGFILE
WRITELOG "WDF End"
