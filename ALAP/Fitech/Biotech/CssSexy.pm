package ALAP::Fitech::Biotech::CssSexy;
# The script deletes upper-case version of words from the Urban Dictionary
use Modern::Perl;
use Data::Dumper;
use Carp::Always;
use autodie;

use ALAP::Fitech::Biotech::Html::Tags;
use ALAP::Fitech::Biotech::Tables;
Conversion_table->import;

my $tag = Tag->new();
$tag->add_attribute("fuck", "fucker");
$tag->add_attribute("fuck", "fucker");

$tag->add_attribute("fuck1", "fucker1");

$tag->add_attribute("fuck", "fucker2");

$tag->push_tag(LeafTag->new('sucka'));
$tag->push_tag(LeafTag->new('sucka2'));

say $tag->to_string();

#say Rate_table->new();

say Rate_table->new(table => {'G' => {'H' => 0.7}})->get_rate('G', '');
say convert('TGG');

use ALAP::Fitech::Biotech::Sequence;

my $store = Seq_store->new();
my $seq = Sequence->new(store => $store);

say $seq->init_seq;

say "position: " . $seq->anchor_pos;
