package ALAP::English::Dictionary::Urban::Urban;
# The script deletes upper-case version of words from the Urban Dictionary
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

#my $in_file = q"D:/link/tempf/latin_samples/sample.dsl";
#my $in_file =
# q"D:/link/tempf/Urban Dictionary (En-En)/Urban Dictionary (En-En).dsl/dsl/Urban Dictionary (En-En) part 1.dsl";

my $in_file =
 q"D:/link/tempf/Urban Dictionary (En-En)/Urban Dictionary (En-En).dsl/dsl/Urban Dictionary (En-En) part 2.dsl";

open my $inH, q"<:raw:encoding(UTF-16LE)", $in_file;

#my $out_file = q"D:/link/tempf/latin_samples/out.dsl";
#my $out_file = q"D:/link/tempf/latin_samples/Urban Dictionary (En-En) part 1.dsl";
my $out_file = q"D:/link/tempf/latin_samples/Urban Dictionary (En-En) part 2_v2.dsl";

open my $outH, q">:raw", $out_file;

#print $outH "\xFF\xFE";

binmode $outH, ":encoding(UTF-16LE)";

my @headers = ();

while (my $line = <$inH>) {
  if ($line =~ m/^\s/) {
    if (@headers) {
      handleHeaders(@headers);
    }

    @headers = ();

    print $outH $line;
  } else {
    push @headers, $line;
  }

}

sub handleHeaders {
  my @headers = @_;

  my $prev;

  for my $curr (@headers) {
    if (! defined $prev) {
      $prev = $curr;

      next;
    }

    if (lc $prev eq lc $curr) {
      my ($diff1, $diff2) = getCharDiff($prev, $curr);

      if ($diff2 =~ m/[a-z]/) {
        $prev = $curr;
      }

     if ($diff1 =~ m/[a-z]/ and $diff2 =~ m/[a-z]/) {
        print  "MIX line: $.;  prev: $prev;  curr: $curr";
      }

    } else {
      print $outH $prev;

      $prev = $curr;
    }
  }

  if (! defined $prev) {
    say "prev is not defined headers size : @{[$#headers]}";

    say for @headers;

    say q"------------";
  }

  print $outH $prev;
}

sub getCharDiff {
  my ($s1, $s2) = @_;

  my @s1 = split(//, $s1);
  my @s2 = split(//, $s2);

  my ($diff1, $diff2) = ("", "");

  for my $i (0 .. $#s1) {
    if ($s1[$i] ne $s2[$i]) {
      $diff1 .= $s1[$i];
      $diff2 .= $s2[$i];
    }
  }

  return ($diff1, $diff2);
}
1;
