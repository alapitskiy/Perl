package ALAP::Fitech::LogAnal1;

use 5.010_000;
use feature ();

use strict;
use warnings;
use Data::Dumper;

use ALAP::Util::DateTime;

use ALAP::Util::ExecutionTime;

my $dateRe = qr/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}):(\d{3})/;
my $delim = '--- New File ---';
my $delimRe = qr/\Q$delim\L/;

my @durs;
my $lastStart;

#unshift( @ARGV, q(-) ) if scalar @ARGV < 1;

#unshift( @ARGV,
  #q(E:\fproject\svn\h2\replicator\test\profiling\jerker\h2-replicator-5652.log)
  #q(D:\temp\h2-replicator.log)
  #q(E:\fproject\svn\h2\replicator\test\profiling\jerker\h2-replicator.log)
#  q(D:\link\tempf\plog\h2-replicator.log-11216)
#) if scalar @ARGV < 1;

use ALAP::Util::FileUtil2;
my $fh = joinOutput( $delim, [ (sort {-M $a <=> -M $b} glob('D:\link\tempf\plog\h2-replicator.log-*'))[0..30] ]);
my $i = 0;
for(;;) {
  my $line = <$fh>;
  do{ select(undef,undef,undef,0.1); redo; } if ! defined $line;
  last if $line =~ m/^EOF$/;

  if ($line =~ m/$delimRe/) {
    undef $lastStart;
  }
$i++;
  if ($line =~ m/\>getting/) {
    my @arr = $line =~ m/$dateRe/ or die "wrong format on line $.";
    $lastStart = {
#      str     => "$. $line",
      str     => "$line",
      dateArr => \@arr,
    };
  }

  if ( $lastStart and $line =~ m/\<got/) {
    my @arr = $line =~ m/$dateRe/ or die "wrong format on line $.";

    push @durs,
      [
      getDurationInMs( $lastStart->{dateArr}, \@arr ),
#      $lastStart->{str}, "$. $line",
      $lastStart->{str}, "$line",
      ];

    undef $lastStart;
  }
}

say "i: $i";

close $fh;

@durs = sort { $b->[0] <=> $a->[0] } @durs;

my $sum = 0;

open FH, '>', 'E:\fproject\svn\h2\replicator\test\profiling\jerker\stat.out';
say FH for map { $sum+=$_->[0]; $_->[0] } @durs;
close FH;


say $sum/1000;

print Dumper(\@durs[0..10]);


#  for my $elem (@durs[1..10]) {
#    say $elem->[0];
#    say $elem->[1];
#    say $elem->[2];
#  }

