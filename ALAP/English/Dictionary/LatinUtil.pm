package ALAP::English::Dictionary::LatinUtil;
# Utilities for Latin dictionary scripts
use Modern::Perl;

use re 'eval';

use List::Gen;
use List::AllUtils;
1;

sub import {
  no strict 'refs';

  my $caller = caller;

  while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
    next if $name eq 'BEGIN';     # don't export BEGIN blocks
    next if $name eq 'import';    # don't export this sub
    next if UNIVERSAL::isa( $symbol, 'SCALAR' );    # let pass constants
    next unless *{$symbol}{CODE};                   # export subs only

    my $imported = $caller . '::' . $name;
    *{$imported} = \*{$symbol};
  }
}

sub concat_count {
  our %h;

  local *h = +shift;

  my $len = length("" . max values %h);

  my %res;

  if (~~@{[%h]} >= 4) {
    while (my ($key, $value) = each(%h)) {
      my $newkey = sprintf(q"%" . "${len}s", $value) . q" - " . $key;

      $res{$newkey} = $value;
    }

    %h = %res;
  }
}

sub word_arr_to_hash {
  our @words;

  local *words = +shift;

  @words = sort {lc $b cmp lc $a} @words;

  my @index = @{[1 .. scalar @words]};

  my %words = List::AllUtils::mesh @words, @index;

  return \%words;
}

sub insert_into_template {
  my $template = shift;

  my %values = %{+shift};

  while ( my($key, $stat) = each %values ) {
    my @stat = by 2 => %{$stat};

    @stat = sort {

    if (!defined $$a[1] or !defined $$b[1]) {
#      print "\n ------------- \n";
#      print Dumper(\@{$stat});
#      print "\n -TWO------------ \n";
      #print Dumper(\@stat);
    };

    0+$$b[1] <=> 0+$$a[1] } @stat;

    #DEBUG
#    push @{$debug{top_elem}}, [scalar @stat, $key, +shift];
    #DEBUG

    for my $val (map {$$_[0]} @stat) {
      $template =~ s/((^[^\n]*)\@\@${key}([^\n]*))$/$2$val$3\n$1/m;
    }

    $template =~ s/^[^\n]*\@\@${key}[^\n]*\n//m;
  }

  return $template;
}

sub tag {
  my $tg = shift;
  return qr!\{\{$tg\}\}(.*?)\{\{\/$tg\}\}!;
}

sub escape {
  @_ = @_ if defined wantarray;

  $_[0] =~ s/([\@\#\(\)\{\}\[\]\\\~\<\>])/\\$1/g;

  @_;
}