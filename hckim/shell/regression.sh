#!/bin/sh
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
LOGPATH='/MD1200_1/hckim/logs'
LOGFILE=$LOGPATH/Log_$0_$1_"$HOST"_"$TIME".log
FILES=( 
testBaseFunctionality.py
testSQLGrammar.py
testMetadata.py
testGrantRevoke.py
testObjectPrivileges.py
suiteMds.py
suiteEPMCore.py
suiteEPMSQL.py
suiteEPMRepo.py
suiteEPMUnit.py
suiteEPMConsolidation.py
suiteEPMScenario.py
suiteSearch_Services.py
)

#if [ -e /MD1200_1/hckim/automation/result_regression.txt ]; then
#	rm /MD1200_1/hckim/automation/result_regression.txt
#fi

for (( A=0;A<${#FILES[@]};A++ )) do
	python /usr/sap/$SAPSYSTEMNAME/SYS/exe/hdb/testscripts/${FILES[$A]} >> $LOGFILE
done
