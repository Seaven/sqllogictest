#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

dsn=${1:?"dsn"};shift
prefix=${1:?"test prefix pattern"};shift
targetDir=${1:?"targetDir"};shift

pids=""
for f in $(ls ${prefix}.*|perl -lne "print if /^${prefix}\\.\\d+$/");do
  echo "./generate_mysql.sh ${dsn} ${f} ${targetDir}"
  ./generate_mysql.sh ${dsn} ${f} ${targetDir} &
  pids="${pids} $!"
done

for pid in ${pids};do
  wait ${pid}
  echo "process#${pid} done"
done
echo "all done!!!"
