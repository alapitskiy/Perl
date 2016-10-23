package ALAP::English::Dictionary::Latin2;
# English word -> list of latin roots -> meaning and descendants

use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use re 'eval';

use List::Gen;
use List::AllUtils;

use ALAP::English::Dictionary::LatinUtil;

# my $template10 = <<'END'
#@@WORD
#  [b]1) [/b][p][i][c][com]@@ORIG[/com][/c][/i][/p]
#	[m1]Languages[/m]
#	[m2][*][ex][i]@@LANG[/i][/ex][/*][/m]
#	[m1]Meanings[/m]
#	[m2][i]@@MEANING[/i][/m]
#	[m1]Descendants[/m]
#	[m2]@@WORD[/m]
#END
#;

my $template1 = <<'END'
	[b]1) [/b][p][i][c][com]@@ORIG[/com][/c][/i][/p]
	[m1]Languages[/m]
	[m2][*][ex][i]@@LANG[/i][/ex][/*][/m]
	[m1]Meanings[/m]
	[m2][i]@@MEANING[/i][/m]
	[m1]Descendants [*](@@DESC_NUM)[/*][/m]
	[m2]@@WORD[/m]
END
;

#NAME "Root siblings for OALD"
my $header1 = <<'END'
#NAME "English-Latin-Siblings for OALD v2"
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

my $out_file = q"D:/link/tempf/eng/En-Ln-Siblings_v2.dsl";
#my $out_file = q"D:/link/tempf/eng/out_t2.dsl";

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
        $lang //= "undef";

        my ($next_etym_tr) = $line =~ m!\G(?:\s|\[[^\]]*?\])*@{[tag("etym_tr")]}!gc;

        $ff = $next_ff;

        if (defined $next_etym_tr) {
          $etym_tr = $next_etym_tr;

          $etym_tr =~ s/^\x{2018}//;
          $etym_tr =~ s/\x{2019}$//;

          $words{$word}{$lang}{$ff} = $etym_tr;
        } else {
          $words{$word}{$lang}{$ff} = "undef";
        }
      }
    }
  }

}

my %latin;

for my $word (keys %words) {
  for my $lang (keys %{$words{$word}}) {
    for my $ff (keys %{$words{$word}{$lang}}) {
      my $etym_tr = $words{$word}{$lang}{$ff};

      $latin{$ff}{lang}{$lang}++;
      $latin{$ff}{etym_tr}{$etym_tr}++;
      push @{$latin{$ff}{word}}, $word;
    }
  }
}

my %word_roots;

for my $ff (keys %latin) {
  for my $word (@{$latin{$ff}{word}}) {
    $word_roots{$word}{$ff} = scalar @{$latin{$ff}{word}};
  }
}

for my $ff (keys %latin) {
 our %ff;
 local *ff = $latin{$ff};

 concat_count($ff{lang});
 concat_count($ff{etym_tr});

 $ff{word} = word_arr_to_hash($ff{word});
}

my @latin = by 2 => %latin;

@latin = sort {lc $$a[0] cmp lc $$b[0]} @latin;

for my $word_pair (@latin) {
    my $orig_word = $word_pair->[0];

    $word_pair->[1]{template1} = insert_into_template($template1, {
    ORIG => {$orig_word, 1},
    LANG => $word_pair->[1]{lang},
    MEANING => $word_pair->[1]{etym_tr},
    DESC_NUM => {scalar keys %{$word_pair->[1]{word}}, 1},
    WORD => $word_pair->[1]{word},
  }, $orig_word);
}


my @word_roots = by 2 => %word_roots;

@word_roots = sort {lc $$a[0] cmp lc $$b[0]} @word_roots;

for my $word_pair (@word_roots) {
  my $word = $word_pair->[0];

  my @ff = by 2 => %{$word_pair->[1]};

  @ff = sort {$a->[1] <=> $b->[1]} @ff;

  print $outH "@{[escape($word)]}\n";



  for my $ff_ind (1 .. scalar @ff) {
    my $ff = $ff[$ff_ind - 1]->[0];

    my $template = $latin{$ff}{template1};

    if (scalar @ff == 1) {
      $template =~ s/(\A[^\d]*?\d\S*)/$1\*/;  # 1) => 1*
    } else {
      $template =~ s/(\A[^\d]*?)\d(\S*\s*\[\/b\])/"${1}${ff_ind}${2}of @{[scalar @ff]} "/e;  # 1) => 1*
    }

    print $outH $template;
  }

}

#use Data::Dumper;
#print Dumper(\%words);
#print ~~%words . $/;
#print ~~ keys(%words) . $/;

print ~~%latin . $/;
print ~~ keys(%latin) . $/;

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

