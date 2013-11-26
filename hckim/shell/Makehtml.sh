#!/bin/sh
BASEPATH="/MD1200_1/hckim/CodeCoverage/Results"
INFOPATH="/MD1200_1/hckim/CodeCoverage"
DATE=201310292201
INFOFILE=Result_201310301550

genhtml -f -s --no-branch-coverage --no-function-coverage --legend -o $BASEPATH/$DATE $INFOPATH/$INFOFILE.info >> $BASEPATH/${FILES["$A"]}.log
genhtml -f -s --no-branch-coverage --no-function-coverage --legend -o "$BASEPATH/$DATE"_full $INFOPATH/reduced$INFOFILE.info >> $BASEPATH/${FILES["$A"]}.log
