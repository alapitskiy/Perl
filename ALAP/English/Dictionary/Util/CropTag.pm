package ALAP::English::Dictionary::Util::CropTag;
# The script cuts away sound links from a dictionary source
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

my $in_file =
 q"D:/link/tempf/lt/sources/no_trn/La-En-Lewis & Short Latin Dictionary_new.dsl.bak";

open my $inH, q"<:raw:encoding(UTF-16LE)", $in_file;

my $out_file = q"D:/link/tempf/lt/sources/no_trn/La-En-Lewis & Short Latin Dictionary.dsl";

open my $outH, q">:raw", $out_file;

#print $outH "\xFF\xFE";

binmode $outH, ":encoding(UTF-16LE)";

my @headers = ();

while (my $line = <$inH>) {
    $line =~ s!\[\/?trn\]!!g; # Eliminating [trn] tags.


    print $outH $line;
}