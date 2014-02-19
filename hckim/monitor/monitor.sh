TIMES=(10:10 10:20 10:30 10:40 10:50 11:00 11:10 11:20 11:30 11:40 11:50 12:00 12:10 12:20 12:30 12:40 12:50 13:00 13:10 13:20 13:30 13:40 13:50 14:00 14:10 14:20 14:30 14:40 14:50 15:00 15:10 15:20 15:30 15:40 15:50 16:00 16:10 16:20 16:30 16:40 16:50 17:00 17:10 17:20 17:30 17:40 17:50 18:00 18:10 18:20 18:30 18:40 18:50 19:00 19:10 19:20 19:30 19:40 19:50 20:00 20:10 20:20 20:30 20:40 20:50 21:00 21:10 21:20 21:30 21:40 21:50 22:00)

for DATE in $@
do

echo -e "$HOSTNAME  $DATE" >> /MD1200_1/hckim/monitor/Result.txt
echo -e "TIME;\tCPU usuage(%);\tMEM usuage(GByte)" >> /MD1200_1/hckim/monitor/Result.txt

	MEMUSEtmp=$(sar -r -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | perl -pi -e 's/ +/@/g' | cut -f 3 -d @ | tail +4 )
	MEMCACHEtmp=$(sar -r -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | perl -pi -e 's/ +/@/g' | cut -f 6 -d @ | tail +4 )
	CPUUSERtmp=$(sar -u -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | perl -pi -e 's/ +/@/g' | cut -f 3 -d @ | tail +4 )
	CPUSYSTEMtmp=$(sar -u -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | perl -pi -e 's/ +/@/g' | cut -f 5 -d @ | tail +4 )
	
	MEMUSE=($MEMUSEtmp)
	MEMCACHE=($MEMCACHEtmp)
	CPUUSER=($CPUUSERtmp)
	CPUSYSTEM=($CPUSYSTEMtmp)


	for (( A=0;A<${#MEMUSE[@]}-1;A++ ));do
			MEM=$((${MEMUSE[$A]}-${MEMCACHE[$A]}))
			MEMRESULT=$(($MEM/1000000))
			CPU=$(echo ${CPUSYSTEM[$A]}+${CPUUSER[$A]} | bc)
		echo -e "${TIMES[$A]};\t$CPU;\t$MEMRESULT" >> /MD1200_1/hckim/monitor/Result.txt
	done
echo -e "\n" >> /MD1200_1/hckim/monitor/Result.txt

#		MEM=$(($MEMUSE-$MEMCACHE))
#		MEMRESULT=$(($MEM/1000000))
#		CPU=$(echo $CPUSYSTEM+$CPUUSER | bc)

#		echo -e "$DATE;\t$CPU;\t$MEMRESULT" >> /MD1200_1/hckim/monitor/Result.txt
#	echo $DATE"_"$HOSTNAME >> /MD1200_1/hckim/monitor/Result.txt
#	sar -u -r -f /var/log/sa/sa$DATE -s 10:00:00 -e 20:00:00 | tail -1 >> /MD1200_1/hckim/monitor/Result.txt
done
