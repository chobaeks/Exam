#!/bin/sh
BASEPATH="/MD1200_1/hckim/CodeCoverage/ScriptResults"
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
RESULTPATH=$1
FILES=(
testEPM
suiteEPMRepo
testEPMAdjustmentOnly
testEPMConsolidationEnd2End_demo2
testEPMCopy
testEPMCurrConvElim
testEPMCurrencyConversion
testEPMCurrencyConversion2
testEPMCurrencyConversionFaurecia
testEPMCurrencyConversionMatching
testEPMCurrencyConversionNoOptionals
testEPMCurrencyConversion_demo2
testEPMDisaggr
testEPMDistributed
testEPMEliminationAdjustment
testEPMEliminationConsoMethod
testEPMEliminationECMCT
testEPMEliminationGenerated
testEPMEliminationMultirule
testEPMEliminationMultistep
testEPMEliminationNullHandling
testEPMEliminationThresholds
testEPMFilter
testEPMHierFilter
testEPMHierLevelPost
testEPMHierTransform
testEPMInAE2E
testEPMLang
testEPMLookupMulti
testEPMLookupSingle
testEPMModel
testEPMPCM
testEPMParameters
testEPMPublish
testEPMScript
testEPMValidate
testMonitoringViewSchema
testObjectPrivileges
testGrantRevoke 
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

python /usr/sap/$SAPSYSTEMNAME/HDB[0-9][0-9]/exe/testscripts/testImportExport.py -t test77 -t test78 >> $RESULTPATH/testImportExport.py.result
