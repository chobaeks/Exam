#!/usr/bin/sh
COVERAGEPATH=/http/CodeCoverage
rm $COVERAGEPATH/index.html

PATHS=(
/epm
/DistMetadata
/Authorization
/ims_search_api
/ptime/storage/mm
/ptime/session/eapi/jdbc
/ptime/common/monitor
/ptime/common/tolerance
/ptime/query/checker
/ptime/query/catalog
/ptime/query/plan_executor/ddl
/ptime/query/procedure
/repository/extensions/runtimes
)

SCRIPTS=(
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
testImportExport.py \(test77,test78\)
)

FILES=`ls $COVERAGEPATH | grep 20`

echo -e "
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html lang=\"en\">

<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>Code coverage - branch EPM </title>
<link rel=\"stylesheet\" type=\"text/css\" href=\"gcov.css\">
</head>
<body>

<table width=\"100%\" border=0 cellspacing=0 cellpadding=0>
<tr><td class=\"title\">Code coverage - branch EPM</td></tr>
<tr><td class=\"ruler\"><img src=\"glass.png\" width=3 height=3 alt=\"\"></td></tr>
</table>

<center>

<table width=\"100%\">
<tr></tr>
<tr>
<td class=\"header1\" align="center">Compile date of the binary</td>
</tr>

" >> index.html

for FILE in $FILES; do
TIME=`echo $FILE | sed -e 's/\(....\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5/'`
echo -e "
<tr>
<td class=\"body2\"><a href=\"$FILE/part/index.html\">$TIME</a>&nbsp;&nbsp;<a href=\"$FILE/full/index.html\">Full</a>&nbsp;&nbsp;<a href=\"$FILE/scriptresult/index.html\">Test Results</a></td>
</tr>
" >> index.html
done

echo -e "
</table>
<table width=\"100%\">
<tr><td class=\"ruler\"><img src=\"glass.png\" width=2 height=1 alt=\"\"></td></tr>
</table>
<br />
<table valign=top width=\"50%\">

<td valign=top>

<table width=\"25%\">
<tr>
<td class=\"header1\" align="center">Included paths</a></td>
</tr>
" >> index.html

for (( A=0;A<${#PATHS[@]};A++ )) do
echo -e "
<tr><td class=\"body3\">${PATHS[$A]}</a></td></tr>
" >> index.html
done

echo -e "
</table>

</td>


<td>
<table width=\"100%\">
<tr>
<td class=\"header1\" align="center">Executed test scripts</a></td>
</tr>
" >> index.html


for (( A=0;A<${#SCRIPTS[@]};A++ )) do
echo -e "
<tr><td class=\"body3\">${SCRIPTS[$A]}</a></td></tr>
" >> index.html
done

echo -e "
</table>
</td>
</table>
</body>
</html>
" >> index.html

for FILE in $FILES; do
RESULTS=`ls ./$FILE/scriptresult | grep .result`
TIME=`echo $FILE | sed -e 's/\(....\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5/'`
rm ./$FILE/scriptresult/index.html
cp ./gcov.css ./$FILE/scriptresult/

echo -e "
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html lang=\"en\">

<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>$TIME Test script results</title>
<link rel=\"stylesheet\" type=\"text/css\" href=\"gcov.css\">
</head>
<body>

<table width=\"100%\" border=0 cellspacing=0 cellpadding=0>
<tr><td class=\"title\">$TIME Test script results</td></tr>
<tr><td class=\"ruler\"><img src=\"glass.png\" width=3 height=3 alt=\"\"></td></tr>
</table>
<p><p>
<table align=center width=\"50%\" border=1>
<tr>
<td align=center>File name</td> 
<td align=center>Result</td>
</tr>
" >> ./$FILE/scriptresult/index.html

for RESULT in $RESULTS; do
FILENAME=`echo $RESULT | sed -e 's/\(.*\)\.result/\1/'`
OK=`cat ./$FILE/scriptresult/$RESULT | grep "Ok ="`
FAIL=`cat ./$FILE/scriptresult/$RESULT | grep "FAILED ="`
SKIP=`cat ./$FILE/scriptresult/$RESULT | grep "Skipped ="`
echo -e "
<tr>
<td align=center> <a href=\"./$RESULT\">$FILENAME</a></td>
<td align=center>
" >> ./$FILE/scriptresult/index.html


if [ ${#FAIL[@]} -ne 0 ]; then
	echo -e "
	$FAIL
	" >> ./$FILE/scriptresult/index.html 
fi

if [ ${#SKIP[@]} -ne 0 ]; then
	echo -e "
	$SKIP
	" >> ./$FILE/scriptresult/index.html 
fi

echo -e "
$OK</td>
</tr>
" >> ./$FILE/scriptresult/index.html
done

echo -e "
</table>
</body>
</html>
" >> ./$FILE/scriptresult/index.html
done

