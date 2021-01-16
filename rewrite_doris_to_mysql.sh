#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail
targetDir=${1:?"undefined 'targetDir'"};shift
find ${targetDir} -type f -name '*.test' |xargs -i{} perl -i.bak -pe 's/^\s*(CREATE\s*TABLE\s*\w+\s*\(\s*(\w+)\s+.*)\s*DUPLICATE.*$/\1;/g' '{}'
