#!/bin/bash

START_DATE=`date`
PNAME="rsync --relative --checksum --partial --stats --human-readable --compress --links -e ssh"
#SRC_ROOT="/home/jylee/c"
SRC_ROOT="sb4adm@seltear13:/MD1200_1/EPM/Binary/201307220200/"
TARGET_ROOT="/MD1200_1/hckim/test"
MAX=10
FILES=`find ${SRC_ROOT}`

for FILE in $FILES ; do
  while (true) ; do
    RUNNING=`ps -e | grep rsync | wc -l`
    if [ $RUNNING -lt $MAX ] ; then
      break
    fi
	sleep 1
  done
  echo "$PNAME $FILE $TARGET_ROOT"
  $PNAME $FILE $TARGET_ROOT &
done

wait

echo "Done"
