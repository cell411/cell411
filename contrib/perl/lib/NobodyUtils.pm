package NobodyUtils;;
require Exporter;
our(@ISA) = qw(Exporter);
our(@EXPORT_OK) = qw(slurp xfork);


use strict;
use warnings;
use autodie qw(:all);
use Data::Dumper;


sub slurp(@) {
  die "usage: slurp( filename ... )" unless @_;
  local(@ARGV) = @_;
  return join("",<ARGV>);
};

sub xfork() {
  my $pid=fork;
  die "fork:$!" unless defined $pid;
  return $pid;
};

1;
