#!/usr/bin/env python3
import glob
import sys
import os


def has_agg_function(query):
    return 'MIN' in query or 'MAX' in query or 'COUNT' in query or 'SUM' in query or 'AVG' in query


def rewrite_file(infile):
    outfile=infile + ".1"
    count=0
    with open(outfile, 'w') as fout:
        with open(infile, 'r') as f:
            content = f.read()
            parts = content.split('\n\n')
            for p in parts:
                p = p.strip()
                if 'CAST( NULL AS' in p:
                    count = count + 1
                    continue
                if 'DISTINCT' in p and ('GROUP BY' in p or has_agg_function(p)):
                    count = count + 1
                    continue
                if has_agg_function(p) and ('FROM' not in p):
                    count = count + 1
                    continue
                if ' FROM ( tab' in p:
                    count = count + 1
                    continue
                if 'skipif mysql' in p:
                    count = count + 1
                    continue
                if p.startswith('NULL'):
                    count = count + 1
                    continue
                try:
                    _ = int(p.split('\n')[0])
                    count = count + 1
                    continue
                except:
                    pass

                if p.find('----', p.find('----') + 4) == -1:
                    fout.write(p)
                    fout.write('\n\n')
                else:
                    count = count + 1
                    #print(p)
    if count > 0:
        print("count=%d renaming %s to %s" % (count, outfile, infile))
        os.rename(outfile, infile)


for root, dirs, files in os.walk("./doris_test"):
    for name in files:
        if not name.endswith('.test'):
            continue
        f = os.path.join(root, name)
        rewrite_file(f)

            
            



