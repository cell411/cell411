#!/usr/bin/perl

while(<DATA>){
  chomp;
  while(1) {
    chomp;
    print "$_\n";
    system($_);
    $cmd=<STDIN>;
    if($cmd=~/^n$/){
      last;
    }
  };
};

__DATA__
curl "http://localhost:1336/geocode?address=1415+Brooklyn+Ave,Ann+Arbor,Mi,USA&type=address"
curl "http://localhost:1336/geocode?address=1415+brooklyn+ave&type=address"
curl "http://localhost:1336/geocode?address=1415+brooklyn&type=address"
curl "http://localhost:1336/geocode?address=75+Leverett+Street,Keene,NH&type=address"
curl "http://localhost:1336/geocode?address=73+Leverett+Street,Keene,NH&type=address"
curl "http://localhost:1336/geocode?address=75+Leverett+Street,Keene,NH,US&type=address"
curl "http://localhost:1336/geocode?address=8917+Beeler+Dr,Tampa,Fl&type=address"
curl "http://localhost:1336/geocode?address=8917+Beeler,Tampa,Fl&type=address"
curl "http://localhost:1336/geocode?address=Keene,NH&type=city"
curl "http://localhost:1336/geocode?address=Keene,NH,US&type=city"
curl "http://localhost:1336/reverseGeocode?lat=42.937140222222226&lng=-72.28547444444445&type=address"
