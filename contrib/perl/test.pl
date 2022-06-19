use lib "lib";
use Carp;

$SIG{__WARN__} = warn { die "warn(@_)"; };
$SIG{__DIE__}= sub { die "die(@_)"; };

eval {
  warn("warning, warning!");
  print "eval survived warning\n";
};
print "($@)" if "$@";
eval {
  die("die, you gravy sucking pig!");
  print "eval survived death";
};
