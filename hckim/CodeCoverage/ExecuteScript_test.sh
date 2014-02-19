#!/bin/sh
BASEPATH="/MD1200_1/hckim/CodeCoverage/ScriptResults"
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
RESULTPATH=$BASEPATH/$TIME'_'$SAPSYSTEMNAME'_'$HOSTNAME
FILES=(
testEPM
suiteEPMRepo
suiteEPMSQL
#testObjectPrivileges 
#testMetadata 
#testDistDDLTest 
#testMetadataSeparation
#testCatalogMigration 
#testImportExport 
#testIntegrityChecker
#testSQLGrammar
#testEPM_DDL
#suitePublicInterfaces
#testDistDDLLockTest 
)

mkdir $RESULTPATH

for (( A=0;A<${#FILES[@]};A++ )) do
		python /usr/sap/$SAPSYSTEMNAME/HDB[0-9][0-9]/exe/testscripts/${FILES["$A"]}.py >> $RESULTPATH/${FILES["$A"]}.result
done
