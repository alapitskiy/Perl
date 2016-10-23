package ALAP::Fitech::Biotech::Sequence;

=head1
  This file contains packages for working with Biotech sequences.
    Sequence_store - offers a secuence
    Sequence - a more elaborated class, which offers additional operations such as finding the position of a startAnchor,
      dividing the sequence into blocks of tree symbols, etc.
=cut

package Seq_store;
use Moose;

use autodie;
use ALAP::Fitech::Biotech::Util;

has file_name => (
  is => 'ro',
  isa => 'Str',
  default => 'D:/link/tempf/example/IA-1A1-SeqVH-F_A01.seq',
);

has seq => (
  is => 'ro',
  isa => 'Str',
  lazy_build => 1,
);

# Allows just supply a filename in constructor.
around BUILDARGS => allow_constructor_for('file_name');

sub _build_seq {
  my $self = shift;

  open my $fh, '<', $self->file_name;
  my $seq = do {local $/ = undef, <$fh>};
  close $fh;

  $seq =~ s/\s//g;

  return $seq;
}

package Sequence;
use Moose;

use constant ANCHOR => "CTCGAG";

has store => (
  is => 'ro',
  isa => 'Seq_store',
  required => 1,
);

has init_seq => (
  is => 'ro',
  isa => 'Str',
  lazy_build => 1,
);

has anchor_pos => (
  is => 'ro',
  isa => 'Int',
  lazy_build => 1,
);

has triplets => (
  is => 'ro',
  isa => 'ArrayRef[Triplet]',
  auto_deref => 1,
  lazy_build => 1,
);

sub _build_init_seq {
  my $self = shift;

  return $self->store->seq;
}

sub _build_anchor_pos {
  my $self = shift;

  return index $self->init_seq, ANCHOR;
}

sub _build_triplets {
  my $self = shift;

  my ($seq, $anch_pos) = ($self->init_seq, $self->anchor_pos);

  my $shift = ( 3 - ( $anch_pos % 3 ) ) % 3;

  $seq .= ' ' x $shift;

  my @triplets = $seq =~ m/(...)/g;
  my @res = ();

  for my $i ( 0..$#triplets ) {
     push @res, Triplet->new( chars => $triplets[$i], position => ($i * 3 - $shift) );
  }

  for my $triplet (@res) {
    for my $char ($triplet->chars) {
      if ($char->position >= $anch_pos) {
        $char->set_working;
        $char->set_anchor if $char->position < $anch_pos + length(ANCHOR);
      }
    }
  }

  return \@res;
}

BEGIN {
package Char;
use Moose;
use Moose::Util::TypeConstraints;
use ALAP::Fitech::Biotech::Util;

use overload '""' => sub {$_[0]->symbol};

subtype 'BioSymbol'
  => as 'Str'
  => where { m/[ ACGT]/ };

has symbol => (
  is => 'ro',
  isa => 'BioSymbol',
  required => 1,
);

has position => (
  is => 'ro',
  isa => 'Int',
  predicate => 'has_position',
  required => 0,
);

has 'is_anchor' => (
  traits => ['Bool'],
  is => 'rw',
  isa => 'Bool',
  default => 0,
  handles => {
    set_anchor => 'set',
  }
);

has 'is_first_marker' => (
  traits => ['Bool'],
  is => 'rw',
  isa => 'Bool',
  default => 0,
  handles => {
    set_first_marker => 'set',
  }
);

has 'is_second_marker' => (
  traits => ['Bool'],
  is => 'rw',
  isa => 'Bool',
  default => 0,
  handles => {
    set_second_marker => 'set',
  }
);

has 'is_working' => (
  traits => ['Bool'],
  is => 'rw',
  isa => 'Bool',
  default => 0,
  handles => {
    set_working => 'set',
  }
);

around BUILDARGS => allow_constructor_for('symbol');

package Triplet;
use Moose;
use ALAP::Fitech::Biotech::Util;

has chars => (
  is => 'ro',
  isa => 'ArrayRef[Char]',
  required => 1,
  auto_deref => 1,
  trigger => \&_set_chars,
  traits => ['Array'],
  handles => {
    push_chars => 'push',
  }
);

has position => (
  is => 'ro',
  isa => 'Int',
  predicate => 'has_position',
  required => 0,
);

around BUILDARGS => allow_constructor_for('chars');

sub _set_chars {
  my $self = shift;

  #If it is 'ABC'
  if (! ref $_[0]) {
    my $i = 0;
    $_[0] = [ map {Char->new( symbol => $_, $self->has_position ? ( position => ( $self->position + $i++) ) : () )} split(//, $_[0]) ];
  }

  if (@$_[0] != 3) {
    confess ("Attempt to set a wrong triplet: [" . join(" ", @_) . ']');
  }
}

}

1;