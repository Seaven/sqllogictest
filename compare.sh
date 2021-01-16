#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

configFile=${1:?"undefined 'configFile'"};shift

green_print(){
  echo -e "\e[32;40;1m$*\e[m" 
}

red_print(){
  echo -e "\e[31;40;1m$*\e[m"
}

yellow_print(){
  echo -e "\e[33;100;1m$*\e[m"
}

processLine(){
  local aConnStr=${1:?"undefined 'aConnStr'"};shift
  local aScript=${1:?"undefined 'aScript'"};shift
  local bConnStr=${1:?"undefined 'bConnStr'"};shift
  local bScript=${1:?"undefined 'bScript'"};shift
  set -- $(echo ${aConnStr}|perl -ne 'print "$1 $2" if /^DATABASE=(\w+);DSN=(\w+)$/')
  local aDB=${1:?"undefined 'aDB'"};shift
  local aDSN=${1:?"undefined 'aDSN'"};shift
  set -- $(echo ${bConnStr}|perl -ne 'print "$1 $2" if /^DATABASE=(\w+);DSN=(\w+)$/')
  local bDB=${1:?"undefined 'bDB'"};shift
  local bDSN=${1:?"undefined 'bDSN'"};shift
  echo "===BEGIN compare ${aDB}@${aDSN}:${aScript} with ${bDB}@${bDSN}:${bScript} ==="
  set +e +o pipefail
  isql ${aDSN} <<<"drop database if exists ${aDB}"
  isql ${bDSN} <<<"drop database if exists ${bDB}"
  isql ${aDSN} <<<"create database if not exists ${aDB}"
  isql ${bDSN} <<<"create database if not exists ${bDB}"
  local aResult=$(basename ${aScript}).result
  local bResult=$(basename ${bScript}).result
  set -e -o pipefail
  src/sqllogictest --odbc "DATABASE=${aDB};DSN=${aDSN}" ${aScript} >${aResult}
  src/sqllogictest --odbc "DATABASE=${bDB};DSN=${bDSN}" ${bScript} >${bResult}
  if ! diff ${aResult} ${bResult};then
    red_print "${aResult}:${bResult} mismatch"
  else
    green_print "${aResult}:${bResult} match"
  fi
  echo "=====END compare ${aDB}@${aDSN}:${aScript} with ${bDB}@${bDSN}:${bScript} ==="

}

cat ${configFile}| while read line;do
  processLine ${line}
done
