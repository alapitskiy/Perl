package ALAP::English::Dictionary::Latin3_3;
#Engl. translation -> latin roots -> list of words for each root
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

use Clone qw(clone);

use ALAP::English::Dictionary::LatinUtil;

my $template1 = <<'END'
@@MEANING
	[m1]Languages[/m]
	[m2][*][ex][i]@@LANG[/i][/ex][/*][/m]
	[m1]Origins[/m]
@@ORIG_TEMPLATE
END
;

my $template2 = <<'END'
	[m2][b][c mediumslateblue]@@ORIG[/c][/b],[/m]
	[m3][ex]@@MEANING[/ex][/m]
	[m2]Descendants [*](@@DESC_NUM)[/*][/m]
	[m3]@@WORD[/m]
END
;

#NAME "English3-Latin Dictionary for OALD"
my $header1 = <<'END'
#NAME "Meaning-Root-Descendants Dictionary for OALD v2"
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

#my $out_file = q"E:/Meaning-Root-Desc_v2.dsl";
my $out_file = q"D:/link/tempf/eng/Meaning-Root-Desc_v2.dsl";
#my $out_file = q"D:/link/tempf/eng/out_t3_3.dsl";

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

my %orig_trans;

my %orig_words;

for my $word (keys %words) {
  for my $lang (keys %{$words{$word}}) {
    for my $ff (keys %{$words{$word}{$lang}}) {
      my $etym_tr = $words{$word}{$lang}{$ff};

      for my $etym (split m/\s*,\s*/, $etym_tr) {
        $meaning{$etym}{lang}{$lang}++;
        $meaning{$etym}{orig}{$ff}++;

        $orig_trans{$ff}{$etym_tr}++;

        $orig_words{$ff}{$word}++;
      }
    }
  }
}

# working with %orig_words
for my $orig (keys %orig_words) {
  my @words = keys %{$orig_words{$orig}};

  @words = sort {lc $b cmp lc $a} @words;

  my %words = List::AllUtils::mesh @words, @{[1 .. scalar @words]};

  $orig_words{$orig} = \%words;
}
# finish %orig_words

for my $trans (keys %meaning) {
  our %trans;
  local *trans = $meaning{$trans};

  concat_count($trans{lang});
}

#my %orig_trans_concated;
#%orig_trans_concated = %{clone(\%orig_trans)};


for my $orig (keys %orig_trans) {
  concat_count($orig_trans{$orig});
}

my @meaning = by 2 => %meaning;

@meaning = sort {lc $$a[0] cmp lc $$b[0]} @meaning;

for my $word_pair (@meaning) {
    my $trans = $word_pair->[0];

   our %h;
   local *h = $word_pair->[1]{orig};

   my %templates;

   for my $orig (keys %h) {
     my $count = $h{$orig};

     my $template = insert_into_template($template2, {
                        ORIG => {(scalar keys %h > 1 ? "$count - " : "" ) . $orig, 1},
                        MEANING => $orig_trans{$orig},
                        DESC_NUM => {scalar keys %{$orig_words{$orig}}, 1},
                        WORD => $orig_words{$orig},
                      }, "foggy");

     $template =~ s/\n\Z//;

     $templates{$template} = $count;
   }

  print $outH insert_into_template($template1, {
    ORIG_TEMPLATE => \%templates,
    LANG => $word_pair->[1]{lang},
    MEANING => {escape($trans), 1},
  }, "foggy");
}

#use Data::Dumper;
#print Dumper(\%words);
#print ~~%words . $/;
#print ~~ keys(%words) . $/;

print ~~%meaning . $/;
print ~~ keys(%meaning) . $/;

#use Data::Dumper;
#print Dumper(\%latin);

sub undef_vars {
  undef $lang;
  undef $ff;
  undef $etym_tr;
}
1;


