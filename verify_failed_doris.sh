#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

dsn=${1:?"dsn"};shift
testList=${1:?"testList"};shift
dbPrefix=${1:?"dbPrefix"};shift
dbStart=${1:?"dbStart"};shift

cat ${testList}|while read line;do
  db=${dbPrefix}_$(printf "%05d" ${dbStart})
  dbStart=$((dbStart+1))
  echo "# begin verify ${line}:db=${db}"
  set +e +o pipefail
  isql ${dsn} <<<"drop database if exists ${db}" >/dev/null 2>&1
  isql ${dsn} <<<"create database if not exists ${db}" >/dev/null 2>&1
  src/sqllogictest --odbc "DATABASE=${db};DSN=${dsn}" ${line} --verify 2>&1
  set -e -o pipefail
done
echo "## all done"
