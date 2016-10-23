package ALAP::Tidy::PerlTidyConsole;
use Modern::Perl;
use Perl::Tidy;
use File::Temp 'tempfile';
use autodie;

my $source = $ARGV[0] // '-';
do { say 'not perl file'; exit 0; } if $source !~ m/\.(pl|pm)|\-$/i;
my ( $tempHandle, $tempFilename ) = tempfile(
  'perlTidyXXXX',
  SUFFIX => '.tmp',
  UNLINK => 1
);

perltidy(
  source      => $source,
  destination => $tempFilename,
  argv        => '-olq -i=2'
);

# incompatible with tempfile
#    use File::Slurp;
#    print( read_file($tempFilename) );
#    unlink $tempFilename;

#  print <$tempHandle>;
while (<$tempHandle> ) {
chomp $_;
print $_;
}
#my $to_print = do { local $/; };
#print STDERR $to_print;

1;