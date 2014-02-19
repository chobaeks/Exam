#!/bin/bash
BINARYPATH=/HDB_POOL/epm/opt/linuxx86_64/LastBuild
PARAMETERNUMBER=$#
INSTALLPATH="None"
SID=$1
#LOCALSIDS=`cat /usr/sap/sapservices | perl -pi -e 's/LD_LIBRARY_PATH=\/usr\/sap\///g' | perl -pi -e 's/\/HDB.*//g' | sed 1d | sed 1d`
#LOCALIDS=`cat /usr/sap/sapservices | perl -pi -e 's/LD_LIBRARY_PATH=\/usr\/sap\/...\/HDB//g' | perl -pi -e 's/\/exe.*//g' | sed 1d | sed 1d`
PARAMETERS=($2 $3 $4 $5 $6 $7 $8 $9)
USER=`whoami`
ASK=0
TESTPACKAGE=0
function USUAGE_MESSAGE ()
{
	echo -e "Usage: sh $0 [SID] [OPTIONS].."
	echo -e "SID"
	echo -e "\t\tThe rule of SID is [A-Z][A-Z,0-9][A-Z,0-9]. It's default parameter, please run with it."
	echo -e "OPTIONS"
	echo -e "  -b, --binarypath"
	echo -e "\t\tUse binary from other path [default: /MD1200_1/hckim/EPMBranch/dbg/linuxx86_64/Lastbuild]"
	echo -e "  -i, --instanceid"
	echo -e "\t\tSelect instance ID yourself [The default from 'hdbinst --help']" 
	echo -e "  -p, --installpath"
	echo -e "\t\tUse storage from other path for install (include DATA, LOG paths) [default: /MD3200_2/auto]"
	echo -e "  -t, --testpackage"
	echo -e "\t\tAdd extract testPackages step (python_support_internal, testpack) [default: No]"
	echo -e "  -n, --nonstop"
	echo -e "\t\tDon't ask start the command"
	echo -e "EXAMPLES"
	echo -e "\t\tSimple) sh $0 KHC"
	echo -e "\t\tUsing all parameters) sh $0 KHC -i 08 -p /MD3200_1/hckim -b /sapmnt/production/makeresults/newdb/POOL/orange_COR/opt/linuxx86_64/LastBuild/ -t -n"
}

function CHECK_PARAMETERS ()
{
	if [ $PARAMETERNUMBER -eq 0 ]; then
 		USUAGE_MESSAGE
 		exit
	fi

	if [ $PARAMETERNUMBER -gt 8 ]; then
		echo "Error : Too many parameters"
 		USUAGE_MESSAGE
 		exit
	fi
}

function CHECK_OPTIONS ()
{
ID=`$BINARYPATH/__installer.HDB/hdbinst --help | grep Instance | perl -pi -e 's/\D//g'`
USERID=`$BINARYPATH/__installer.HDB/hdbinst --help | grep uid | perl -pi -e 's/\D//g'`

	for (( A=0;A<${#PARAMETERS[@]};A++ ));do
		case ${PARAMETERS["$A"]} in
			-b) 
				A=`expr $A + 1`
				BINARYPATH=${PARAMETERS["$A"]}
				if [ -e $BINARYPATH/__installer.HDB/hdbinst ]; then
					continue
				else
					echo "Error : Can't find 'hdbinst' in '"$BINARYPATH"/__installer.HDB/' PATH"
					USUAGE_MESSAGE
					exit
				fi;; 	

			--binarypath)
				A=`expr $A + 1`
				BINARYPATH=${PARAMETERS["$A"]}
				if [ -e $BINARYPATH/__installer.HDB/hdbinst ]; then
					continue
				else
					echo "Error : Can't find 'hdbinst' in '"$BINARYPATH"/__installer.HDB/' PATH"
					USUAGE_MESSAGE
					exit
				fi;; 	

			-i)
				A=`expr $A + 1`
				ID=${PARAMETERS["$A"]}
#				for LOCALID in $LOCALIDS; do
#					if [ $LOCALID -eq $ID ] ; then
#						echo "$ID is already used"
#						exit
#					fi
#				done
				;;

			--instanceid)
				A=`expr $A + 1`
				ID=${PARAMETERS["$A"]}
#				for LOCALID in $LOCALIDS; do
#					if [ $LOCALID -eq $ID ] ; then
#						echo "$ID is already used"
#						exit
#					fi
#				done
				;;

			-p)
				A=`expr $A + 1`
				INSTALLPATH=${PARAMETERS["$A"]}
				if [ -d $INSTALLPATH ]; then
					continue
				else
					echo "Error : Can't find '$INSTALLPATH' PATH"
					USUAGE_MESSAGE
					exit
				fi;;

			--installpath)
				A=`expr $A + 1`
				INSTALLPATH=${PARAMETERS["$A"]}
				if [ -d $INSTALLPATH ]; then
					continue
				else
					echo "Error : Can't find '$INSTALLPATH' PATH"
					USUAGE_MESSAGE
					exit
				fi;;

			-n)
				ASK=1;;

			-nonstop)
				ASK=1;;

			-t)
				TESTPACKAGE=1;;

			-testpackage)
				TESTPACKAGE=1;;

			*)
				echo "Error: ${PARAMETERS["$A"]} is unknown parameter"
				USUAGE_MESSAGE
				exit;;
		esac
	done
}

function CHECK_SID ()
{
	if [ ${#SID} -ne 3 ]; then
		echo "Error : The rule of SID is [A-Z][A-Z,0-9][A-Z,0-9]"
		exit
	fi

#	for LOCALSID in $LOCALSIDS; do
#		if [ $LOCALSID = $SID ]; then
#			echo "$SID is already used"
#			exit
#		fi
#	done
}

function START ()
{
$BINARYPATH/__installer.HDB/hdbinst --sapmnt=$INSTALLPATH -s $SID --number=$ID --password=trextrex --home=/usr/sap/$SID/home --shell=/bin/sh --userid=$USERID --datapath=$INSTALLPATH/$SID/global/hdb/data --logpath=$INSTALLPATH/$SID/global/hdb/log --system_user_password=manager --autostart=n --system_usage=test

sleep 300

if [ $TESTPACKAGE -eq 1 ]; then
	sh $BINARYPATH/test/python_support_internal/installTestPkg.sh -s $SID $BINARYPATH/test/python_support_internal/python_support_internal.tgz
	sh $BINARYPATH/test/tests/installTestPkg.sh -s $SID $BINARYPATH/test/tests/testpack.tgz
fi
}

function CHECK_START()
{
	if [ $INSTALLPATH = "None" ]; then
		INSTALLPATH="/MD3200_2/auto/"
	fi

	if [ -d $INSTALLPATH ]; then
		continue	
	else
		echo "Can't find $INSTALLPATH"
		USUAGE_MESSAGE
		exit
	fi

	echo "This is install command : "
	echo $BINARYPATH/__installer.HDB/hdbinst --sapmnt=$INSTALLPATH -s $SID --number=$ID --password=trextrex --home=/usr/sap/$SID/home --shell=/bin/sh --userid=$USERID --datapath=$INSTALLPATH/$SID/global/hdb/data --logpath=$INSTALLPATH/$SID/global/hdb/log --system_user_password=manager --autostart=n
	if [ $TESTPACKAGE -eq 1 ]; then
			echo "Extract testpackages = Y "
	else
			echo "Extract testpackages = N "
	fi
	echo ""
	
	if [ $ASK -eq 0 ]; then
			echo "Do you want run the command? [Y] "
			read INPUT
			case $INPUT in
				Y) START;;
				y) START;;	
				N) echo "Canceled";exit;;
				n) echo "Canceled";exit;;
				"") START;;
				*) echo "Cancled";exit;;
			esac
	else
			START
	fi
}

if [ $USER != "root" ]; then
	echo "Error : Please use root user" 
	exit
fi

if [ -e $BINARYPATH/__installer.HDB/hdbinst ]; then
	continue
else
	echo "Can't find 'hdbinst' in '"$BINARYPATH"/__installer.HDB/' PATH"
	exit
fi 

CHECK_PARAMETERS
CHECK_SID
CHECK_OPTIONS
CHECK_START
