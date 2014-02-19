#!/bin/sh
SOURCEPATH=$1
CREATEPATH='/MD1200_1/hckim/CodeCoverage'
TIME=`date +%G%m%d%k%M | sed "s/\s/0/g"`

lcov -d $SOURCEPATH/epm \
     -d $SOURCEPATH/DistMetadata \
	 -d $SOURCEPATH/Authorization \
	 -d $SOURCEPATH/ims_search_api \
	 -d $SOURCEPATH/ptime/storage/mm \
	 -d $SOURCEPATH/ptime/session/eapi/jdbc \
	 -d $SOURCEPATH/ptime/common/monitor \
	 -d $SOURCEPATH/ptime/common/tolerance \
	 -d $SOURCEPATH/repository/extensions/runtimes \
	 -d $SOURCEPATH/ptime/query/checker \
	 -d $SOURCEPATH/ptime/query/catalog \
	 -d $SOURCEPATH/ptime/query/plan_executor/ddl \
	 -d $SOURCEPATH/ptime/query/procedure \
	 -f -c --no-markers --gcov-tool /usr/bin/gcov --ignore-errors gcov,source -o $CREATEPATH/Result_"$HOST"_$TIME.info
	 
#    -d $SOURCEPATH/ptime/query \
