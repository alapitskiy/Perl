package ALAP::English::Dictionary::BookOfUsage::Util::Util;
use Modern::Perl;

use ALAP::English::Dictionary::BookOfUsage::Util::SgmlSupport;

#img_stat();
entity();

sub img_stat {
  my $file = q"D:/link/tempf/dsl/amBook.dsl";

  my %h;

  open my $fh, "<:encoding(UTF-16LE)", $file;

  while ( my $line = <$fh> ) {
    my (@imgs) = $line =~ m!\[g\].*?\/([^\/]*)\.gif\[\/g\]!g;


    @h{@imgs} = map {($_ // 0) + 1} @h{@imgs};
  }

  say "FINISH";
  say "$_ : $h{$_} : " . $ent{$_} for sort keys %h;
}

sub entity {
  use HTML::Entities;
  say decode_entities('&#180;');
  say "ENTITIES";

#  say decode_entities("&#oomacr;");

  say "ent: " . $_ for ($ent{"sigma"}, $ent{"Sigma"},  $ent{"sigmaf"},   $ent{"sigmav"});
}

1;
