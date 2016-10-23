package ALAP::English::Subs;
use Modern::Perl;
use ALAP::FileUtils;
use ALAP::Utils;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

#my $subFile = $ARGV[0] // 'test.txt';
my $subFile = $ARGV[0]
  // 'F:\Dropbox\mesh\english\subs\Once.LiMiTED.DVDRip.XviD.srt';
#  // 'I:\Video\Den_Surka_1993_BDRip_Menen_2,18\Den_Surka_1993_BDRip_Menen.Eng.srt';
my $wordsFile = 'D:\link\tempf\input.txt';
#my $wordsFile = 'input.txt';
my $output    = 'D:\link\tempf\out.xlsx';

my @subs = read_file($subFile);
chomp(@subs);

@subs = grep {
  state $last = \$_;
  if (m/^[[:lower:]]/) {
    $$last .= " $_";
    $last = \$_;
    0;
  }
  else {
    $last = \$_;
    1;
  }
} @subs;

for (@subs) {
  $_ =~ s!\<.\>!!;
  $_ =~ s!\<\/.\>!!;
}

my @inds;
while ( my ( $ind, $_ ) = each(@subs) ) {
  $ind = '.' if m/^\s*$/ || m/^\d/;
  push @inds, $ind;
}
my @indGroups = grep /./, split( /(?:\.,)+/, join( ',', @inds ) . ',' );
my @joinedSubs;
for my $group (@indGroups) {
  push @joinedSubs, $_ for join( ' ', @subs[ split( /,/, $group ) ] );
}

my @csvArr;
open my $h, '<', $wordsFile;
while ( my $word = <$h> ) {
  chomp($word);

  # special case 1
  my $sp1 = $word;
  $sp1 = chop($sp1) eq 'y' ? $sp1 . 'i' : '';
  my $example = first { m/\b${word}/i } @joinedSubs;
  $example = first { m/\b${sp1}/i } @joinedSubs if !$example && $sp1;
  if ( defined $example ) {
    push @csvArr, { word => $word, xample => $example };
  }
  else {
    say STDERR "no example for word: $word";
  }
}
#use Text::CSV::Slurp;
#my $csv = Text::CSV::Slurp->create( input => \@csvArr );
#say $csv;

use Excel::Writer::XLSX;
my $workbook  = Excel::Writer::XLSX->new($output);
my $worksheet = $workbook->add_worksheet();
while ( my ( $ind, $hash ) = each @csvArr ) {
  $worksheet->write( $ind, 0, $hash->{word} );
  $worksheet->write( $ind, 1, $hash->{xample} );
}

1;
