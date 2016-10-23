package ALAP::English::Dictionary::MWCollegiate::CropSound;
# The script cuts away sound links from a dictionary source
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

my $in_file =
 q"D:/link/tempf/MWCollegiate for Lingvo/dsl/En-En-MWCollegiate11.dsl";

open my $inH, q"<:raw:encoding(UTF-16LE)", $in_file;

#my $out_file = q"D:/link/tempf/latin_samples/out.dsl";
#my $out_file = q"D:/link/tempf/latin_samples/Urban Dictionary (En-En) part 1.dsl";
my $out_file = q"D:/link/tempf/MWCollegiate for Lingvo/dsl/En-En-MWCollegiate11_out.dsl";

open my $outH, q">:raw", $out_file;

#print $outH "\xFF\xFE";

binmode $outH, ":encoding(UTF-16LE)";

my @headers = ();

while (my $line = <$inH>) {
    $line =~ s!\[s\][^\[\]\/]+\.wav\[\/s\] ?!!g;

    #$line =~ s!\[\/?trn\]!!g; # Eliminating [trn] tags.

    print $outH $line;
}