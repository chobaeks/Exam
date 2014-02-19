#!/bin/sh
function ADDLIST ()
{
	SERVER=$1
	LISTSTART=$2
	LISTEND=$3
	DIGITS=$4
	
	for i in `seq $LISTSTART 1 $LISTEND`
	do
		for (( A=5;A<${#}+1;A++ )); do
			if [ ${!A} -eq $i ]; then
				continue 2
			fi
		done

		if [ $DIGITS = YES ];then
			LINE=`echo $i | wc -c`
			if [ $LINE -eq 2 ];then
				i=0$i
			fi
		fi

	LIST=("${LIST[@]}" "$SERVER$i")
	done
}

LIST=()
ADDLIST selbld 1 118 YES 5 7 10
ADDLIST selibm 11 82 YES
ADDLIST seltera 1 32 NO 31

for LAST in ${LIST[@]}; do
	echo -e $LAST 
done
