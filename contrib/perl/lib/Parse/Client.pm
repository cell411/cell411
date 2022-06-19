package Parse::Client;

use Carp qw(croak confess carp cluck );
$SIG{__WARN__}=sub { carp(@_); };
$SIG{__DIE__}=sub { croak(@_); };
use strict;
use warnings;
use autodie qw(:all);
use Data::Dumper;
use JSON;
use LWP::UserAgent;
use HTTP::Headers;
use NobodyUtils qw(slurp);
use LWP::UserAgent;

BEGIN {
  $Data::Dumper::Deparse=1;
  $Data::Dumper::Sortkeys=1;
};

our(%Config, %stash);
$Config{configFile} = "$ENV{HOME}/.parse/config.dev.json";
$Config{configText} = slurp($Config{configFile});
$Config{configData} = decode_json $Config{configText};
$Config{headerMap} = {
  "X-Parse-Application-Id" => "appId", 
  "X-Parse-REST-API-Key" => "restAPIKey",
  "X-Parse-Revocable-Session" => "revSession",
  "X-Parse-Session-Token" => "sessionToken",
};

sub new {
  my ($class) = ref($_[0]) ? ref(shift) : shift;
  my ($self) = {};
  bless($self, $class);

  my ($agent) = new LWP::UserAgent();
  $self->{agent}=add_stash( $agent );
  my ($headers) = $agent->default_headers;
  $self->{headers}=add_stash($headers);
  
  my $map = $Config{headerMap};
  my $data = $Config{configData};

  {
    my $temp = $data->{sessionToken};
    $self->{sessionToken}=\$temp;
    $data->{sessionToken}=\$temp;
  };
  $self->{url}=$data->{pubServerURL};
  for($data->{revSession}){
    $_=1 unless defined $_;
  };
  for my $key1(keys %$map) {
    my $key2 = $map->{$key1};
    my $rval = \$data->{$key2};
    $$rval="" unless defined $$rval;
    my $val = $$rval;
    $headers->header($key1,$val);
  };
  return $self;

};
sub add_stash {
  my $self=shift if $_[0]->isa("Parse::Client");
  my $val=shift;
  my $key="$val";
  $stash{$key}=$val;
  return ($key);
};
sub agent {
  my $self=shift;
  my $key = $self->{agent};
  my $val = $stash{$key};
  return $val;
};
sub headers {
  my $self=shift;
  my $key = $self->{headers};
  my $val = $stash{$key};
  return $val;
};
#sub base_url {
  #  return $Config{configData}{
sub setup {
  return slurp($Config{configFile});
};

sub mk_request {
  my $self=shift;
  my $agent=$self->agent;
  my $method=shift;
  print "method: $method\n";
  my $frag=shift;
  print "frag=$frag\n";
  my $base = $self->{url};
  print "base=$base\n";
  $base =~ s{/*$}{};
  $frag =~ s{^\*}{};
  my $full = "$base/$frag";
  print "full=$full\n";
  my $res;
  @_ = { username => 'dev2@copblock.app',  password => 'aa' };
  if(lc($method) eq lc("POST")) {
    $res = $agent->post($full, @_);
  } elsif (lc($method) eq lc("GET")) {
    $res = $agent->get($full, @_);
  } elsif (lc($method) eq lc("PUT")) {
    $res = $agent->put($full, @_);
  } elsif (lc($method) eq lc("DELETE")) {
    $res = $agent->delete($full, @_);
  };
  return $self->process($res);
};
sub process {
  my $self=shift;
  my $res = shift;
  if(!$res->is_success) {
    print "request failed.  status: ", $res->status_line, "\n";
  } else {
    my %content;
    my @parts = map { split(/ *; */, $_) }  $res->header("content-type");
    print "(@parts)\n"; 
    $content{type}=shift @parts;
    while(defined($_=shift@parts)) {
      if(s{^charset\s*=\s*}{}) {
        $content{charset}=$_;
      }
    };
    $content{length}=$res->header("content-length");
    $content{text}=$res->decoded_content;
    if($content{type} eq 'application/json') {
      $content{data}=decode_json($content{text}); 
    };
    print Dumper(\%content);

    exit(1);
  }
  return $res;
};

#    our($HOME);
#    our($Config, %Config);
#    
#    *HOME=\$ENV{HOME};
#    (%Config) = ( configFile => "$HOME/.parse/config.dev.json" );
#    
#    
#    $DB::single=1;
#    eval "use NobodyUtils qw(slurp);";
#    eval "\$Config = slurp( \$Config{configFile} );";
#    
#    
#

1;
