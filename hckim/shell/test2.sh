#!/bin/sh
SERVERLIST=(selbld selibm seltera)
liststartselbld=01
listendselbld=118
blistselbld=(02 03)
liststartselibm=11
listendselibm=82
listendseltera=01
listendseltera=23
LIST=()

for SERVER in ${SERVERLIST[@]}; do
	LISTSTART=liststart$SERVER
	LISTEND=listend$SERVER
	for i in `seq ${!LISTSTART[0]} 1 ${!LISTEND[0]}`
	do
		LINE=`echo $i | wc -c`
		if [ $LINE -eq 2 ];then
			i=0$i
		fi
		LIST=("${LIST[@]}" "$SERVER$i")
	done
done

for LAST in ${LIST[@]}; do
	echo -e $LAST 
done
