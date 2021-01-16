#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

dsn=${1:?"dsn"};shift
inputDir=${1:?"inputDir"};shift
numSplit=${1:?"numSplit"};shift
verifyDir=${1:?"verifyDir"};shift
strict=${1:-"no"}

fileList=$(perl -e "print join qq(_), grep {length(\$_)>0} split qr{\\W+}, qq{${inputDir}}").list

perl -le "print qq{Phase I: generate fileList\nfind ${inputDir} -type f -name "*.test" >${fileList}}"
find ${inputDir} -type f -name "*.test" >${fileList}

splitPrefix=${fileList}.split
num=$(wc -l ${fileList}|perl -aF/\\s+/ -ne 'print $F[0]')
linesPerSplit=$(((num+numSplit-1)/numSplit))

perl -le "print qq{Phase II: split fileList\nsplit -l ${linesPerSplit} -d ${fileList} ${splitPrefix}.}"
split -l ${linesPerSplit} -d ${fileList} ${splitPrefix}.

perl -le "print qq{Phase III: verify doris tests}"

pids=""
for f in $(ls ${splitPrefix}.*|perl -lne "print if /^${splitPrefix}\\.\\d+$/");do
  echo "./verify_doris.sh ${dsn} ${f} ${verifyDir} ${strict} >${f}.result 2>&1 &"
  ./verify_doris.sh ${dsn} ${f} ${verifyDir} ${strict} >${f}.result 2>&1 &
  pids="${pids} $!"
done

for pid in ${pids};do
  wait ${pid}
  echo "process#${pid} done"
done
echo "all done!!!"

perl -le "print qq{Phase IV: sort result}"
cat ${splitPrefix}.*.result |perl -lne 'print $1 if m{^\s*(\S+:(FAIL|PASS).*$)}' |perl -aF':' -lne 'print "$F[1]:$F[0]"' |sort -t: -k1,1 |tee ${splitPrefix}.final.result
