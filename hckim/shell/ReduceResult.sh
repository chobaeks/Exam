#!/bin/sh
SOURCEPATH=$1
CREATEPATH='/MD1200_1/hckim/CodeCoverage'
TIME=`ls -l $BINARYPATH | perl -pi -e 's/.*linuxx86_64\///g' | perl -pi -e 's/\///g'`
INFOFILE=$2



lcov -e $INFOFILE */epm/epm_api.cpp */epm/epm_authorization.cpp */epm/epm_authorization.h */epm/query_source/epm_query_source_builder.cpp */epm/runtime/epm_rt_session.h */epm/runtime/epm_rt_session.cpp */epm/runtime/epm_rt_session_manager.cpp */epm/epm_sql.cpp */epm/epm_sql.h */epm/runtime/epm_rt_hierarchy_navigate.cpp */epm/runtime/epm_rt_filter.cpp */repository/extensions/runtimes/epm_translator.h */repository/extensions/runtimes/epm* */repository/extensions/runtimes/epm_translator.enums.h */ptime/common/monitor/EpmSessionsMonitor.cc */ptime/common/monitor/EpmSessionsMonitor.h */ptime/query/catalog/epm_modelinfo.cc */ptime/query/catalog/epm_modelinfo.h */ptime/query/catalog/epm_querysourceinfo.cc */ptime/query/catalog/epm_querysourceinfo.h */ptime/query/checker/check_epm_model.cc */ptime/query/checker/check_epm_query_source.cc -o reduced_$INFOFILE

exit 0

lcov -e result_20131029.info $SOURCEPATH/epm/* */epm/query_source/* */epm/runtime/* */mds/metadata/* */ims_search_api/*EPM* */ptime/common/monitor/* */ptime/query/checker/* */ptime/session/eapi/jdbc/* */ptime/query/catalog/* */ptime/query/plan_executor/ddl/* */ptime/query/procedure/* */repository/extensions/runtimes/epm* -o reduced_2.info
#"$SOURCEPATH/epm/runtime/*" \ 
#$SOURCEPATH/DistMetadata/* \ 
#$SOURCEPATH/Authorization/* \
#$SOURCEPATH/ims_search_api/* \
#$SOURCEPATH/ptime/query/checker/* \
#$SOURCEPATH/ptime/query/catalog/* \
#$SOURCEPATH/ptime/query/plan_executor/ddl/* \
#$SOURCEPATH/ptime/query/procedure/* \
#$SOURCEPATH/ptime/session/eapi/jdbc/* \
#$SOURCEPATH/ptime/common/monitor/* \

