BINARYPATH=/MD3200_1/hckim/epm226/gen/opt

if [ -e $BINARYPATH/__installer.HDB ];then
	BEFORE=`cat $BINARYPATH/__installer.HDB/server/manifest | grep 2013 | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
	AFTER=`cat $BINARYPATH/__installer.HDB/server/manifest | grep 2013 | sed -e 's/.*\(....\)-\(..\)-\(..\)\s\(..\):\(..\):\(..\)/\1\2\3\4\5/'`
fi

if [ $AFTER = $BEFORE ];then
	echo $BEFORE
	echo $AFTER
	echo "same"
else
	echo "End"
fi

