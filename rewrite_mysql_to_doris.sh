#!/bin/bash
basedir=$(cd $(dirname $(readlink -f ${BASH_SOURCE:-$0}));pwd)
cd ${basedir}
set -e -o pipefail
targetDir=${1:?"undefined 'targetDir'"};shift
find ${targetDir} -type f -name '*.test' |xargs -i{} perl -i.bak -pe 's/^\s*(CREATE\s*TABLE\s*\w+\s*\(\s*(\w+)\s+.*);$/\1 DUPLICATE KEY(\x{60}\2\x{60}) DISTRIBUTED BY HASH(\2) BUCKETS 10 PROPERTIES (\x{22}replication_num\x{22} = \x{22}1\x{22});/g' '{}'
