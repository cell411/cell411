#!/usr/bin/perl


use strict;
use warnings;
use autodie qw(:all);
use IO::Socket;
use POSIX qw(strftime);

use strict;
use warnings;
use feature 'say';

use IO::Socket qw(AF_INET AF_UNIX SOCK_STREAM SHUT_WR);

my $server = IO::Socket->new(
  Domain => AF_INET,
  Type => SOCK_STREAM,
  Proto => 'tcp',
  LocalHost => '0.0.0.0',
  LocalPort => 3333,
  ReusePort => 1,
  Listen => 5,
) || die "Can't open socket: $IO::Socket::errstr";
say "Waiting on 3333";

our($dateFormat);
$dateFormat="%Y%m%d-%H%M%S";
sub date() {
  return strftime($dateFormat,gmtime(time));
}

my $number=10000-1;
while (1) {
  $number++;
  # waiting for a new client connection
  #
  my $client = $server->accept();

  # get information about a newly connected client
  my $client_address = $client->peerhost();
  my $client_port = $client->peerport();
  say "Connection from $client_address:$client_port";

  next if fork;
  open(STDOUT,"|tee logfile.$number.log");
  while(<$client>){
    $_=join(": ", date(),$_);
    print;
  };
  $client->shutdown(SHUT_WR);
};
$server->close();



