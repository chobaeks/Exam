LOGPATH='/MD1200_1/hckim/logs'
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
LOGFILE=$LOGPATH/Log_CodeCoverage_"$HOST"_"$TIME".log
BINARYPATH=/MD3200_1/hckim/epm226/gen/opt

function WRITELOG()
{
LOGTIME=`date`
echo -e "-------- $LOGTIME ---------- $1 -----------------------------" >> $LOGFILE
echo -e "" >> $LOGFILE
}

WRITELOG "Script Start"
chmod 777 $LOGFILE

if [ -e $BINARYPATH/__installer.HDB ];then
	BEFORE=`cat $BINARYPATH/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
fi
	
WRITELOG "build Start"
su - epm226 -c "/home/epm226/build.sh >> $LOGFILE"
WRITELOG "build End"

sleep 600

if [ -e $BINARYPATH/__installer.HDB ];then
	AFTER=`cat $BINARYPATH/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
else
	WRITELOG "Build failed! Can't find __installer.HDB PATH. End script"
	exit 0
fi

if [ $AFTER = $BEFORE ];then
	WRITELOG "Same bniary! End script"
	exit 0
fi

WRITELOG "CodeCoverage Start"
ssh 10.60.45.221 "sh /MD1200_1/hckim/CodeCoverage/Auto.sh /MD3200_1/hckim/epm226 >> $LOGFILE"
WRITELOG "CodeCoverage End"

WRITELOG "Script End"
