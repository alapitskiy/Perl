package ALAP::English::Dictionary::MWCollegiate::RemoveEmptyLines;
# The script eliminates empty lines from a source so that lingvo compiler doens't swear.
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

my $in_file =
# q"D:/link/tempf/MWCollegiate for Lingvo/orig/En-En-MWCollegiate11.dsl";
 q"D:/link/tempf/OxfordAmericanThesaurusEnEn/tmp/OxfordAmericanThesaurusEnEn.dsl";

open my $inH, q"<:raw:encoding(UTF-16LE)", $in_file;

#my $out_file = q"D:/link/tempf/latin_samples/out.dsl";
#my $out_file = q"D:/link/tempf/latin_samples/Urban Dictionary (En-En) part 1.dsl";
#my $out_file = q"D:/link/tempf/MWCollegiate for Lingvo/orig/En-En-MWCollegiate11_out.dsl";
my $out_file = q"D:/link/tempf/OxfordAmericanThesaurusEnEn/tmp/OxfordAmericanThesaurusEnEn_out.dsl";

open my $outH, q">:raw", $out_file;

#print $outH "\xFF\xFE";

binmode $outH, ":encoding(UTF-16LE)";

while (my $line = <$inH>) {
    print $outH $line if $line !~ m/^\s*$/;
}