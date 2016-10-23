package ALAP::Tidy::PerlTidy;
use Modern::Perl;
use Perl::Tidy;
use File::Temp 'tempfile';
use autodie;

my $source = $ARGV[0] // '-';
do { say 'not perl file'; exit 0; } if $source !~ m/\.(pl|pm)|\-$/i;
{
  my $tempFilename;

  {
    my $tempHandle;
    ( $tempHandle, $tempFilename ) = tempfile(
      'perlTidyXXXX',
      SUFFIX => '.tmp',
      UNLINK => 1
    );

    perltidy(
      source      => $source,
      destination => $tempFilename,
      argv        => '-olq -i=2'
    );

    $tempHandle->close();
  }
  use File::Copy;
  File::Copy::syscopy $tempFilename, $source;
}
