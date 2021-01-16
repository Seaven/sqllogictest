#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

dsn=${1:?"dsn"};shift
testList=${1:?"testList"};shift
verifyDir=${1:?"verifyDir"};shift
strict=${1:-"yes"}

cat ${testList}|while read line;do
  set +e +o pipefail
  db=$(perl -e "print join qq(_), grep {length(\$_)>0} split qr{\\W+}, qq{${line}}")
  verifyFile=$(perl -e "print qq{${line}}=~s{^(\\w+)}{${verifyDir}}r")
  dir=$(dirname ${verifyFile})

  echo "# begin verify ${line}: db=${db} verifyFile=${verifyFile}"
  isql ${dsn} <<<"drop database if exists ${db}" >/dev/null 2>&1
  isql ${dsn} <<<"create database if not exists ${db}" >/dev/null 2>&1

  mkdir -p ${dir}
  echo ${db}
  src/sqllogictest --odbc "DATABASE=${db};DSN=${dsn}" ${line} --verify >${verifyFile} 2>&1
  set -e -o pipefail
  if [ "x${strict}x"  == "xyesx" ];then
    ok=$(perl -ne 'print qq/ok/ if m{0 result wrong 0 errors out of.*\s+0 skipped\.}' ${verifyFile})
  else
    ok=$(perl -ne 'print qq/ok/ if m{(\d+) result wrong (\d+) errors out of.*\s+(\d+)\s+skipped\.} && $1 == 0' ${verifyFile})
  fi

  result=$(tail -1 ${verifyFile})
  if [ "x${ok}x" == "xokx" ];then
    echo "${line}:PASS:${result}"
  else
    echo "${line}:FAIL:${result}"
  fi
  echo "# end   verify ${line}"

  #isql ${dsn} <<<"drop database if exists ${db}" >/dev/null 2>&1
  echo
done
echo "## all done"
