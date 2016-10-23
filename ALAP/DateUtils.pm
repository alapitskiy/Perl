package ALAP::DateUtils;

use Modern::Perl;

1;

sub previousDay {
  unshift( @_, shift // 0 );
  use POSIX qw(strftime);
  for my $daysBack (@_) {
  if ($daysBack =~ m/^\d+$/) {
    my @f = localtime( time() - 86400 * $daysBack );
    print strftime( "%Y %b %d", @f ) . "\n";
  }
    #printf "%04d-%02d-%02d\n", $f[5] + 1900, $f[4] + 1, $f[3];
  }
}

sub previousWeek {
  my @weeks = grep {m/^\d+$/} @_;
  my $dow   = ( localtime() )[6];
  $dow = $dow - 7 if $dow > 5;
  my @dayBacks = map { $_ = $_ * 7 + $dow + 1; } @weeks;

  for my $dayBack (@dayBacks) {
    my @sat = localtime( time() - 86400 * $dayBack );
    my @sun = localtime( time() - 86400 * ( $dayBack - 1 ) );
    print strftime( "%Y %b %d", @sat ) . '-' . strftime( "%d", @sun ) . "\n";
  }
}
