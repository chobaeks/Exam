TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`
NAME=`cat /proc/sys/kernel/hostname`

DF=`df -l | grep -v /srv/iso | sed -e '1d' | grep % | sed -e 's/.*\(..[0-9]\)%.*/\1/'`
MD=`df | grep \/MD | sed -e 's/.*\(..[0-9]\)%.*/\1/'`

USEDMEM=`free | sed -e '1d' | sed -e '$d' | sed -e '$d' | sed -e 's/.*Mem:\s*[0-9]*\s*\([0-9]*\)\s*.*/\1/'`
CACHEMEM=`free | sed -e '1d' | sed -e '1d' | sed -e '$d' | sed -e 's/.*cache:\s*[0-9]*\s*\([0-9]*\).*/\1/'`
TOTALMEM=`free | sed -e '1d' | sed -e '$d' | sed -e '$d' | sed -e 's/.*Mem:\s*\([0-9]*\)\s.*/\1/'`
MEM=`expr $USEDMEM - $CACHEMEM`
LIMIT=`expr $TOTALMEM \/ 100 \* 70`

if [ $MEM -gt $LIMIT ];then
    ps -eo user,pid,ppid,rss,size,vsize,pmem,pcpu,time,cmd --sort -rss > /MD1200_1/hckim/logs/monitor/Memory_"$NAME"_$TIME.log
else
	continue
fi

for i in $DF;do
	if [ $i -gt 90 ];then
		df > /MD1200_1/hckim/logs/monitor/Space_"$NAME"_$TIME.log
	fi	
done

for i in $MD;do
	if [ $i -gt 90 ];then
		df > /MD1200_1/hckim/logs/monitor/Space_"$NAME"_$TIME.log
	fi	
done
