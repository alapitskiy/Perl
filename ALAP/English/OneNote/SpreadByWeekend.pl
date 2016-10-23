package ALAP::English::OneNote::SpreadByWeekend;
use Modern::Perl;
use ALAP::FileUtils;
use Calendar::Simple;
use DateTime;
use POSIX;

# Copy template file into month folders
# Input params
# $1 - source name
# $2 - destination name

my ( $source, $dest ) = @ARGV;
die "Specifty source template and destination folder" unless $dest;

my ($year) = basename($dest) =~ /^\d{4}/g;

my $i=1;
for my $month ( 1 .. 12 ) {
  my @call = calendar( $month, $year );

  #  use Data::Dumper;
  #  print Dumper(\@call);
  shift2dimArray( \@call );

  #  print Dumper(\@call);
  for my $week (@call) {
    @$week[6] = 1 if !defined @$week[6];
    if ( defined @$week[5] ) {
      my $newFile = $dest . '/'
        . sprintf('%02d ', $i) . getDayRange( $year, $month, @$week[5], @$week[6] ) . '.one';
      copy( $source, $newFile ) unless -e $newFile;
      $i++;
    }
  }
}

sub getDayRange {
  my ( $year, $month, $sat, $sun ) = @_;
  my $dt = DateTime->new(
    year  => $year,
    month => $month,
    day   => $sat,
  );
  return $dt->month_abbr . ' ' . sprintf( '%02d-%02d', $sat, $sun );
}

sub shift2dimArray {
  my @arr = @{ shift; };
  for my $i ( 0 .. $#arr ) {
    my $dim1 = $arr[$i];
    my $dim2 = $arr[ $i + 1 ];
    shift @$dim1;
    if ( defined $dim2 ) {
      push @$dim1, @$dim2[0];
    }
    else {
      push @$dim1, 1;
    }
  }
}

1;
