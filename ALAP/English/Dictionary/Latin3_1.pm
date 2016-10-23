package ALAP::English::Dictionary::Latin3_1;
##Engl. translation -> latin roots
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

use ALAP::English::Dictionary::LatinUtil;

my $template1 = <<'END'
@@MEANING
	[m1]Languages[/m]
	[m2][*][ex][i]@@LANG[/i][/ex][/*][/m]
	[m1]Origins[/m]
	[m2]@@ORIG[/m]
END
;

my $header1 = <<'END'
#NAME "English-Latin Dictionary for OALD"
#INDEX_LANGUAGE "English"
#CONTENTS_LANGUAGE "English"

END
;

my %debug;

my $word;
my $lang;
my $ff;
my $etym_tr;

my $do_gather;

my %words;

my $in_file = q"D:/link/tempf/eng/En-En_Oxford Advanced Learners Dictionary.dsl";
#my $in_file = q"D:/link/tempf/eng/test.dsl";

open my $inH, q"<:raw:encoding(UTF-16LE)", $in_file;

my $out_file = q"D:/link/tempf/eng/out3_1.dsl";
#my $out_file = q"D:/link/tempf/eng/out_t3_1.dsl";

open my $outH, q">:raw", $out_file;

print $outH "\xFF\xFE";

binmode $outH, ":encoding(UTF-16LE)";

print $outH $header1;

while (my $line = <$inH>) {
  chomp($line);

  $line =~ s/\s+$//;

  if ( $line =~ m!^\S! ) {
    $word = $line;

    # Discard several meaning one after another
    while ( $line =~ m!^\S! ) {
      $line = <$inH>;
    }

    undef $do_gather;
  }

  if ( $line =~ m!^\s*\Q{{Word Origin}}\E! ) {
    $do_gather = 1;
  } elsif ( $line =~ m!^\s*\Q{{\E! ) {
    undef $do_gather;
  }

  if ($do_gather) {
    undef_vars();

    while( $line =~ m!@{[tag("lang")]}|@{[tag("ff")]}!gc ) {
      my ($next_lang, $next_ff) = ($1, $2);

      $lang = $next_lang if defined $next_lang;

      if (defined $next_ff) {
        my ($next_etym_tr) = $line =~ m!\G(?:\s|\[[^\]]*?\])*@{[tag("etym_tr")]}!gc;

        if (defined $next_etym_tr) {
          $ff = $next_ff;
          $etym_tr = $next_etym_tr;

          $etym_tr =~ s/^\x{2018}//;
          $etym_tr =~ s/\x{2019}$//;

          $etym_tr =~ s/^\s*//;
          $etym_tr =~ s/\s*$//;

          $lang //= "UNDEF";

          $words{$word}{$lang}{$ff} = $etym_tr;
        }
      }
    }
  }

}

my %meaning;

for my $word (keys %words) {
  for my $lang (keys %{$words{$word}}) {
    for my $ff (keys %{$words{$word}{$lang}}) {
      my $etym_tr = $words{$word}{$lang}{$ff};

      for my $etym (split m/\s*,\s*/, $etym_tr) {
        $meaning{$etym}{lang}{$lang}++;
        $meaning{$etym}{orig}{$ff}++;
      }
    }
  }
}

for my $trans (keys %meaning) {
 our %trans;
 local *trans = $meaning{$trans};

 concat_count($trans{lang});
 concat_count($trans{orig});
}


my @meaning = by 2 => %meaning;

@meaning = sort {lc $$a[0] cmp lc $$b[0]} @meaning;

for my $word_pair (@meaning) {
    my $trans = $word_pair->[0];

  print $outH insert_into_template($template1, {
    ORIG => $word_pair->[1]{orig},
    LANG => $word_pair->[1]{lang},
    MEANING => {escape($trans), 1},
  }, $trans);
}

#use Data::Dumper;
#print Dumper(\%words);
#print ~~%words . $/;
#print ~~ keys(%words) . $/;

print ~~%meaning . $/;
print ~~ keys(%meaning) . $/;

#use Data::Dumper;
#print Dumper(\%latin);

my @top = sort {$$a[0] <=> $$b[0]} @{$debug{top_elem}};
print Dumper(\@top);

sub undef_vars {
  undef $lang;
  undef $ff;
  undef $etym_tr;
}
1;

