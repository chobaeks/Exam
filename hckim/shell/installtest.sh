#!/bin/bash
LOCALSIDS=`cat /usr/sap/sapservices | perl -pi -e 's/LD_LIBRARY_PATH=\/usr\/sap\///g' | perl -pi -e 's/\/HDB.*//g' | sed 1d | sed 1d`
BINARYPATH=/MD1200_1/hckim/EPMBranch/opt/linuxx86_64/Lastbuild/__installer.HDB
CHECKSIDFOLDER=`ls /usr/sap`

for LOCALSID in $LOCALSIDS; do
	if [ $LOCALSID = TE1 ]; then
		ps -u te1adm -o pid | xargs kill -9
		$BINARYPATH/hdbuninst -s TE1 --batch --force
	fi
			 
	if [ $LOCALSID = TE2 ]; then
		ps -u te2adm -o pid | xargs kill -9
		$BINARYPATH/hdbuninst -s TE2 --batch --force
	fi
done

for SIDFOLDER in $CHECKSIDFOLDER; do
	if [ $SIDFOLDER = TE1 ]; then
		ps -u te1adm -o pid | xargs kill -9
		$BINARYPATH/hdbuninst -s TE1 --batch --force
	fi
			 
	if [ $SIDFOLDER = TE2 ]; then
		ps -u te2adm -o pid | xargs kill -9
		$BINARYPATH/hdbuninst -s TE2 --batch --force
	fi
done

sh /MD1200_1/hckim/automation/autoinstall.sh TE2 -b /MD1200_1/hckim/EPMBranch/opt/linuxx86_64/Lastbuild -t -n
sleep 100
sh /MD1200_1/hckim/automation/autoinstall.sh TE1 -b /MD1200_1/hckim/EPMBranch/dbg/linuxx86_64/Lastbuild -t -n
sleep 100
