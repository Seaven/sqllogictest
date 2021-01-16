#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail

dsn=${1:?"dsn"};shift
inputDir=${1:?"inputDir"};shift
numSplit=${1:?"numSplit"};shift
targetDir=${1:?"targetDir"};shift

fileList=$(perl -e "print join qq(_), grep {length(\$_)>0} split qr{\\W+}, qq{${targetDir}}").list

perl -le "print qq{Phase I: generate fileList\nfind ${inputDir} -type f -name "*.test" >${fileList}}"
find ${inputDir} -type f -name "*.test" >${fileList}

splitPrefix=${fileList}.split
num=$(wc -l ${fileList}|perl -aF/\\s+/ -ne 'print $F[0]')
linesPerSplit=$(((num+numSplit-1)/numSplit))

perl -le "print qq{Phase II: split fileList\nsplit -l ${linesPerSplit} -d ${fileList} ${splitPrefix}.}"
split -l ${linesPerSplit} -d ${fileList} ${splitPrefix}.

perl -le "print qq{Phase III: generate all mysql tests\n${basedir}/generate_all_mysql.sh ${dsn} ${splitPrefix} ${targetDir}}"
${basedir}/generate_all_mysql.sh ${dsn} ${splitPrefix} ${targetDir}


perl -le "print qq{Phase IV: rewrite mysql tests into doris tests\n${basedir}/rewrite_mysql_to_doris.sh ${targetDir}}"
${basedir}/rewrite_mysql_to_doris.sh ${targetDir}
