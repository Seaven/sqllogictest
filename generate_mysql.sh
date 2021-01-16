#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

dsn=${1:?"dsn"};shift
testList=${1:?"testList"};shift
targetDir=${1:?"targetDir"};shift

cat ${testList}|while read line;do
  set +e +o pipefail
  db=${dbPrefix}_${dbSuffix}
  file=$(perl -e "print qq{${line}}=~s{^(\\w+)}{${targetDir}}r")
  db=$(perl -e "print join qq(_), grep {length(\$_)>0} split qr{\\W+}, qq{${file}}")
  dir=$(dirname ${file})
  echo "# begin process ${line}: db=${db}, gen=${file}"
  isql ${dsn} <<<"drop database if exists ${db}" >/dev/null 2>&1
  isql ${dsn} <<<"create database if not exists ${db}" >/dev/null 2>&1
  mkdir -p ${dir}

  echo "src/sqllogictest --odbc 'DATABASE=${db};DSN=${dsn}' ${line} >${file}"
  src/sqllogictest --odbc "DATABASE=${db};DSN=${dsn}" ${line} >${file}
  echo "# end   process ${line}"
  echo
  set -e -o pipefail
done
echo "## all done"
