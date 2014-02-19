#!/bin/sh
BASEPATH="/MD1200_1/hckim/CodeCoverage/ScriptResults"
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
RESULTPATH=$BASEPATH/$TIME'_'$SAPSYSTEMNAME'_'$HOSTNAME
FILES=(
testEPMDDLDistributed
testEPM
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
suiteEPMRepo
suiteEPMSQL
#testCatalogMigration
#testMetadataSeparation
#testDistDDLTest 
#testMetadata 
#testMetadataIntegrity
)

cp /MD1200_1/hckim/CodeCoverage/Change_metadata/testEPMDDLDistributed.py /usr/sap/$SAPSYSTEMNAME/HDB[0-9][0-9]/exe/testscripts/

mkdir $RESULTPATH

for (( A=0;A<${#FILES[@]};A++ )) do
		python /usr/sap/$SAPSYSTEMNAME/HDB[0-9][0-9]/exe/testscripts/${FILES["$A"]}.py >> $RESULTPATH/${FILES["$A"]}.result
done

python /usr/sap/$SAPSYSTEMNAME/HDB[0-9][0-9]/exe/testscripts/testImportExport.py -t test77 -t test78 >> $RESULTPATH/testImportExport.py.result
