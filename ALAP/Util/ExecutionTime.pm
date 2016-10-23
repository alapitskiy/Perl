package ALAP::Util::ExecutionTime;
use Modern::Perl;

my $time;
BEGIN {
  $time = time();
}

END {
  use integer;
  $time = time() - $time;

  my $min = $time / 60;
  my $sec = $time - $min * 60;

  STDOUT->flush();
  say STDERR "Time: $min min $sec sec";
}
