#!/usr/bin/perl
use strict;
use warnings;
use autodie qw(:all);
use Data::Dumper;

END{
  close(STDOUT);
};
my $db = shift @ARGV;

die "usage: genview_count.pl <db>" unless defined $db;
splice(@ARGV);
open(STDIN,"pg_dump -s $db |");

my@union;
my@rej;
while(<>){
  next unless /^CREATE TABLE/;
  s/^[^"]*//;
  s/[^"]*$//;
  s/"//g;
  push(@union,$_);
};

@union=sort @union;
@union = grep { length } @union;
sub make_counts($@){
  my ($name,@union)=@_;
  @union = map { ( qq($_), qq("$_") ) } @union;
  $\="\n";
  my ($max) = reverse sort { $a <=> $b } map { length } @union;
  my $pad = " "x$max;
  @union = map {( "$_$pad" )} @union;
  @union = map { substr($_,0,$max) } @union;


  my @final;

  while(@union) {
    my ( $tab1, $tab2 );
    $tab1=shift(@union);
    $tab2=shift(@union);
    next unless length($tab1) && length($tab2);
    push(@final, sprintf(q{select '%s' as tab, count(*) as cnt from %s},$tab1,$tab2));
    push(@final,"union");
  };
  pop@final;
  open(PIPE,"| tee temp |psql $db");
  select(PIPE);
  print "create or replace view counts\n";
  print "as\n";
  print "select tab, cnt from (\n";
  print for @final;
  print ") x order by tab\n";
  print ";";
  print "select * from counts;\n";
  close(PIPE);
  select(STDOUT);
};
print Dumper(\@union);
make_counts("rej_counts",@union);
@union = grep { !/^rej_/ } @union;
make_counts("counts",@union);
