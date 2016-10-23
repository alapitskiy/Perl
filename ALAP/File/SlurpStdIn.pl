package ALAP::File::SlurpStdIn;
use Modern::Perl;

my ($out) = @ARGV or die 'provide target file';

my $guts = do { local $/ = <STDIN> };

open my $handle, ">", $out or die $!;
print $handle $guts;
close $handle;
