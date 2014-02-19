echo -e "$HOSTNAME;\tCPU usuage(%);\tMEM usuage(GByte)" >> /MD1200_1/hckim/monitor/Result.txt

for DATE in $@
do
		MEMUSE=$(sar -r -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | tail -1 | perl -pi -e 's/ +/@/g' | cut -f 3 -d @)
		MEMCACHE=$(sar -r -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | tail -1 | perl -pi -e 's/ +/@/g' | cut -f 6 -d @)
		CPUUSER=$(sar -u -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | tail -1 | perl -pi -e 's/ +/@/g' | cut -f 3 -d @)
		CPUSYSTEM=$(sar -u -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | tail -1 | perl -pi -e 's/ +/@/g' | cut -f 5 -d @)

		MEM=$(($MEMUSE-$MEMCACHE))
		MEMRESULT=$(($MEM/1000000))
		CPU=$(echo $CPUSYSTEM+$CPUUSER | bc)

		echo -e "$DATE;\t$CPU;\t$MEMRESULT" >> /MD1200_1/hckim/monitor/Result.txt
#	echo $DATE"_"$HOSTNAME >> /MD1200_1/hckim/monitor/Result.txt
#	sar -u -r -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | tail -1 >> /MD1200_1/hckim/monitor/Result.txt
done
