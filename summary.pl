#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(sum);
use Data::Dumper;

my @result=();

while (<>){
  if (/(?:PASS|FAIL):\s*(\d+)\s*result wrong\s*(\d+)\s*errors out of\s*(\d+)\s* tests in \S+ - (\d+) skipped./){
    push @result, [$1,$2,$3,$4];
  }
}

print Dumper(\@result);
my $wrongNum=sum(map{$_->[0]} @result);
my $errorNum=sum(map{$_->[1]} @result);
my $totalNum=sum(map{$_->[2]} @result);
my $skipNum=sum(map{$_->[3]} @result);
my $validNum=$totalNum-$errorNum-$skipNum;
my $validPercent=$validNum/$totalNum*100;
print "wrongs=$wrongNum, errors=$errorNum, totals=$totalNum, skips=${skipNum}, valid=$validNum, validPercent=${validPercent}\n";
