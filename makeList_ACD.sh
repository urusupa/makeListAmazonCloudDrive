#!/bin/sh
###############################################################################
# makeList_ACD.sh
# Amazon Cloud Driveのファイル一覧を作成する
# in:
# out:
# return RETCD
###############################################################################

. ${LIB_DIR}/common.sh


###############################################################################
# メイン
###############################################################################

JOBSTART $*

STEPSTART acdcli_sync
echo "[sync]" >> ${LOGFILE}
acdcli sync >> ${LOGFILE}
echo "[tree]" >> ${LOGFILE}
treefile="${TMP_DIR}/acdcli_tree.txt"
echo "${treefile}" >> ${LOGFILE}
acdcli tree > ${treefile}
STEPEND

STEPSTART Makelist
EXECRUBY ${RUBY_DIR}/makeListAmazonCloudDrive.rb
STEPEND

STEPSTART InsertDB
EXECRUBY ${RUBY_DIR}/insertListAmazonCloudDrive.rb
STEPEND

JOBEND
