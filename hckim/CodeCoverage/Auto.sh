#!bin/sh
SID="ML7"
SIDMIN=`echo $SID | tr '[A-Z]' '[a-z]'`
SIDADM="$SIDMIN"adm
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
SOURCEPATH=$1
WRKPATH=$SOURCEPATH/sys/wrk
OBJECTPATH=$SOURCEPATH/sys/wrk/opt/obj
BINARYPATH=$SOURCEPATH/gen/opt
CREATEPATH='/MD1200_1/hckim/CodeCoverage'
LOGPATH='/MD1200_1/hckim/logs'
LOGFILE=$LOGPATH/Log_Auto_"$HOST"_"$TIME".log
INFOFILEPATH=$CREATEPATH/Result_"HOST"_$TIME.info
BASEPATH="/MD1200_1/hckim/CodeCoverage/ScriptResults"
RESULTPATH=$BASEPATH/$TIME'_'$SID'_'$HOSTNAME
HTTPPATH='/http/CodeCoverage'

touch $LOGFILE
chmod 777 $LOGFILE

function CREATEINFOFILE ()
{
lcov -d $OBJECTPATH/epm \
     -d $OBJECTPATH/DistMetadata \
	 -d $OBJECTPATH/Authorization \
	 -d $OBJECTPATH/ims_search_api \
	 -d $OBJECTPATH/ptime/storage/mm \
	 -d $OBJECTPATH/ptime/session/eapi/jdbc \
	 -d $OBJECTPATH/ptime/common/monitor \
	 -d $OBJECTPATH/ptime/common/tolerance \
	 -d $OBJECTPATH/repository/extensions/runtimes \
	 -d $OBJECTPATH/ptime/query/checker \
	 -d $OBJECTPATH/ptime/query/catalog \
	 -d $OBJECTPATH/ptime/query/plan_executor/ddl \
	 -d $OBJECTPATH/ptime/query/procedure \
	 -f -c --no-markers --gcov-tool /usr/bin/gcov --ignore-errors gcov,source -o $INFOFILEPATH
}

function REDUCED ()
{
lcov -e $INFOFILEPATH */epm/epm_api.cpp */epm/epm_authorization.cpp */epm/epm_authorization.h */epm/query_source/epm_query_source_builder.cpp */epm/runtime/epm_rt_session.h */epm/runtime/epm_rt_session.cpp */epm/runtime/epm_rt_session_manager.cpp */epm/epm_sql.cpp */epm/epm_sql.h */epm/runtime/epm_rt_hierarchy_navigate.cpp */epm/runtime/epm_rt_filter.cpp */repository/extensions/runtimes/epm_translator.h */repository/extensions/runtimes/epm* */repository/extensions/runtimes/epm_translator.enums.h */ptime/common/monitor/EpmSessionsMonitor.cc */ptime/common/monitor/EpmSessionsMonitor.h */ptime/query/catalog/epm_modelinfo.cc */ptime/query/catalog/epm_modelinfo.h */ptime/query/catalog/epm_querysourceinfo.cc */ptime/query/catalog/epm_querysourceinfo.h */ptime/query/checker/check_epm_model.cc */ptime/query/checker/check_epm_query_source.cc -o "$INFOFILEPATH"_reduced
}

function WRITELOG ()
{
LOGTIME=`date`
echo -e "-------- $LOGTIME ---------- $1 -----------------------------" >> $LOGFILE
echo -e "" >> $LOGFILE
}

WRITELOG "Start"
chmod 777 -R $WRKPATH/opt $WRKPATH/dbg >> $LOGFILE

WRITELOG "Autoinstall Start"
sh /MD1200_1/hckim/automation/autoinstall.sh $SID -b $BINARYPATH -p /MD1200_1/hckim -t -n >> $LOGFILE
WRITELOG "Autoinstall End"

sleep 600 

WRITELOG "ExecuteScript Start"
su - $SIDADM -c "/MD1200_1/hckim/CodeCoverage/ExecuteScript.sh $RESULTPATH >> $LOGFILE"
chmod 777 -R $WRKPATH/opt $WRKPATH/dbg >> $LOGFILE
su - $SIDADM -c "python /usr/sap/$SID/SYS/exe/hdb/testscripts/suiteEPMRepo.py"
chmod 777 -R $WRKPATH/opt $WRKPATH/dbg >> $LOGFILE
WRITELOG "ExecuteScript End"

WRITELOG "HDB stop Start"
su - $SIDADM -c "HDB stop" >> $LOGFILE
WRITELOG "HDB stop End"

#su - $SIDADM -c "HDB version > $CREATEPATH/version"
chmod 777 -R $WRKPATH/opt $WRKPATH/dbg >> $LOGFILE

WRITELOG "Make folders Start"
FOLDERNAME=`cat $BINARYPATH/__installer.HDB/server/manifest | grep date | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'` >> $LOGFILE
mkdir $HTTPPATH/$FOLDERNAME
mkdir $HTTPPATH/$FOLDERNAME/part
mkdir $HTTPPATH/$FOLDERNAME/full
mkdir $HTTPPATH/$FOLDERNAME/scriptresult
WRITELOG "Make folders End"

WRITELOG "Copy sciprt results Start"
cp $RESULTPATH/* $HTTPPATH/$FOLDERNAME/scriptresult
chmod 777 -R $HTTPPATH/$FOLDERNAME/scriptresult/* 
WRITELOG "Copy sciprt results End"

WRITELOG "Create infofile Start"
CREATEINFOFILE
WRITELOG "Create infofile End"

WRITELOG "Create reduced file Start"
REDUCED
WRITELOG "Create reduced file End"

WRITELOG "Create html file Start"
genhtml -f -s --no-branch-coverage --no-function-coverage --legend -o $HTTPPATH/$FOLDERNAME/part "$INFOFILEPATH"_reduced
genhtml -f -s --no-branch-coverage --no-function-coverage --legend -o $HTTPPATH/$FOLDERNAME/full $INFOFILEPATH
WRITELOG "Create html file End"

sh /http/CodeCoverage/Creatindex.sh
WRITELOG "Sciprt End"
