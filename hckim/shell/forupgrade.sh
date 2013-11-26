#!/bin/sh
BINARYPATH=/MD1200_1/hckim/EPMBranch/opt/linuxx86_64/Lastbuild
TIME=`ls -l $BINARYPATH | perl -pi -e 's/.*linuxx86_64\///g' | perl -pi -e 's/\///g'`

$BINARYPATH/__installer.HDB/hdbupd -password=trextrex -system_user_password=manager -s SB5 --ignore=check_version
sleep 300
$BINARYPATH/test/python_support_internal/installTestPkg.sh -s SB5 $BINARYPATH/test/python_support_internal/python_support_internal.sar
$BINARYPATH/test/tests/installTestPkg.sh -s SB5 MD1200_1/hckim/EPMBranch/opt/linuxx86_64/Currentbuild/test/tests/testpack.sar

mkdir /MD1200_1/EPM/Binary/$TIME
cp -rva $BINARYPATH/__installer.HDB/* /MD1200_1/EPM/Binary/$TIME
tar -cvf /MD1200_1/EPM/Binary/installer_tmp.tar /MD1200_1/EPM/Binary/$TIME && rm -R /MD1200_1/EPM/Binary/$TIME

mkdir /MD1200_1/EPM/Binary/$TIME
cp -rva $BINARYPATH/test/* /MD1200_1/EPM/Binary/$TIME
tar -cvf /MD1200_1/EPM/Binary/testPackages_tmp.tar /MD1200_1/EPM/Binary/$TIME && rm -R /MD1200_1/EPM/Binary/$TIME
