#!/usr/bin/perl
use Data::Dumper;
$Data::Dumper::Terse=1;
$Data::Dumper::Useqq=1;

use strict;
use warnings;
sub dump_file(\[%@]);

$\="\n";
$,=" ";

my @text = qx(pg_dump -s);
for(@text){
  s{^--.*}{};
};
@text=sort(grep { length } split(/\n\n+/,join("",@text)));
my @words;
for(@text) {
  if(m{^create\s+}i){
  } elsif(m{^set\s+}i){
    print "@{[@_]}";
  } elsif(m{^alter\s+}i){
    print "@{[@_]}";
  } else {
    print "@{[@_]}";
  };
};


my $num=100;
sub dump_file(\[%@]){
  my $ref=shift or die "expected a ref as first (and only) arg";
  local($")="\n";
  my $file=join("","file",($num++),".plm");
  open(my $fh,">$file") or die "open$file:$!";
  $fh->print(Dumper($ref));
  close($fh) or die "close:$file:$!";
};

