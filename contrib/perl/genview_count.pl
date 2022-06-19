#!/usr/bin/perl
use strict;
use warnings;
use autodie qw(:all);

splice(@ARGV);
open(STDIN,"pg_dump -s |");

my@union;
while(<>){
  next unless /^CREATE TABLE/;
  s/^[^"]*//;
  s/[^"]*$//;
  s/"//g;
  push(@union,$_);
};

@union=sort @union;
@union = map { ( qq($_), qq("$_") ) } @union;
$\="\n";
my ($max) = reverse sort { $a <=> $b } map { length } @union;
my $pad = " "x$max;
@union = map {( "$_$pad" )} @union;
@union = map { substr($_,0,$max) } @union;


my @final;

while(@union) {
  push(@final, sprintf(q{select '%s' as tab, count(*) as cnt from %s},shift(@union),shift(@union)));
  push(@final,"union");
};
pop@final;
open(STDOUT,"|psql");
print "create or replace view counts\n";
print "as\n";
print "select tab, cnt from (\n";
print for @final;
print ") x order by tab\n";
print ";";
print "select * from counts;\n";

