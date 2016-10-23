package ALAP::English::OneNote::SpreadByMonth;
use Modern::Perl;
use ALAP::FileUtils;

# Copy template file into month folders
# Input params
# $1 - source name
# $2 - destination name

my ( $source, $dest ) = @ARGV;
die "Specifty source template and destination folder" unless $dest;
make_path($dest);

my @monthDays = qw( 31 28 31 30 31 30 31 31 30 31 30 31 );
my ($monthNumber) = basename($dest) =~ /^\d{2}/g;
my $days = $monthDays[ $monthNumber - 1 ];
for my $i ( 1 .. $days ) {
  my $newFile = $dest . '/' . sprintf( '%02u.one', $i );
  copy( $source, $newFile ) unless -e $newFile;
}

1;
