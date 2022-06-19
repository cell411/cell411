#!/usr/bin/perl

BEGIN {
  use lib qw(/usr/local/lib/perl);
};
use strict;
use autodie qw(:all);
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Parse::Client;
use Data::Dumper;
use UNIVERSAL;
use Carp;

$SIG{__DIE__} = \&confess;
$SIG{__WARN__} = \&carp;

my $warn=1;
sub func_d {
  warn("This is a warning") if $warn;
};
sub func_c {
  return func_d;
};
sub func_b {
  return func_c;
}
sub func_a {
  return func_b;
};


my $client = new Parse::Client;
#print "ref(\$client) => ", ref($client), "\n";
my $agent = $client->agent;
#print "ref(\$agent) => ", ref($agent), "\n";
my $headers = $client->headers;
#print "ref(\$headers) => ", ref($headers), "\n";

my $file;
open($file,">client.pdump");
$file->print(Dumper($client), "\n\n");
close($file);

open($file,">agent.pdump");
$file->print(Dumper($agent), "\n\n");
close($file);

open($file,">headers.pdump");
$file->print(Dumper($headers), "\n\n");
close($file);

my $res = $client->mk_request(qw( PoSt login));
print Dumper($res);

