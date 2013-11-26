LOGPATH='/MD1200_1/hckim/logs'
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
LOGFILE=$LOGPATH/Log_CodeCoverage_"$HOST"_"$TIME".log

function WRITELOG()
{
LOGTIME=`date`
echo -e "-------- $LOGTIME ---------- $1 -----------------------------" >> $LOGFILE
echo -e "" >> $LOGFILE
}

WRITELOG "Script Start"
chmod 777 $LOGFILE

WRITELOG "build Start"
su - epm226 -c "/home/epm226/build.sh >> $LOGFILE"
WRITELOG "build End"

sleep 600

WRITELOG "CodeCoverage Start"
ssh 10.60.45.221 "sh /MD1200_1/hckim/CodeCoverage/Auto.sh /MD3200_1/hckim/epm226 >> $LOGFILE"
WRITELOG "CodeCoverage End"

WRITELOG "Script End"
