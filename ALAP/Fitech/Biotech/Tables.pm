package ALAP::Fitech::Biotech::Tables;

=head1 DESCRIPTION
  This file contains tables for the Biotech project.
    Rate_table
    Conversion_table
=cut

package Rate_table;
use Moose;

use autodie;

use overload '""' => sub {use Data::Dumper; Dumper($_[0]->table);};

use ALAP::Fitech::Biotech::Util;

has file_name => (
  is => 'ro',
  isa => 'Str',
  default => 'D:/link/tempf/example/IA_281343_rat.csv',
);

has table => (
  is => 'rw',
  isa => 'HashRef',
  lazy_build => 1,
  trigger => \&_set_table,
);

sub get_rate($$) {
  my ($self, $first, $second) = @_;
  my $table = $self->table;

  my $val = $table->{$first}{$second};
  $val //= $table->{$second}{$first};
  $val //= $first eq $second ? 1 : 0;

  return $val
}

# Allows just supply a filename in constructor.
around BUILDARGS => allow_constructor_for('file_name');

# H, L, 0.85 => H, L, 0.85; L, H, 0.85
sub _set_table {
  my $self = shift;
  my $table = shift;

  my %res_table = %$table;

  for my $first (keys %$table) {
    for my $second (keys %{$table->{$first}}) {
      $res_table{$second}{$first} = $table->{$first}{$second};
    }
  }

  %$table = %res_table;
};

sub _build_table {
  my $self = shift;

  my %table = ();

  open my $fh, "<", $self->file_name;

  while (<$fh>) {
     my ($first, $second, $value) = m/["']?(\w)["']?(?:\s*,\s*)["']?(\w)["']?(?:\s*,\s*)['"]?([\d\.]+)/;

     (print "can't parse line $. in file " . $self->file_name . "\n"), next if ! defined $value;

     $table{$first}{$second} = $value;
  }

  close $fh;

  $self->table(\%table);
}


package Conversion_table;
#use Carp;

use Exporter 'import';
our @EXPORT = 'convert';

my $stopCodonOcher = 'Z';
my $stopCodonAmber = 'Z';
my $stopCodonOpal = 'Z';

my %table = (
  "TTT", 'F',
  "TTC", 'F',
  "TTA", 'L',
  "TTG", 'L',
  "CTT", 'L',
  "CTC", 'L',
  "CTA", 'L',
  "CTG", 'L',
  "ATT", 'I',
  "ATC", 'I',
  "ATA", 'I',
  "ATG", 'M',
  "GTT", 'V',
  "GTC", 'V',
  "GTA", 'V',
  "GTG", 'V',
  "TCT", 'S',
  "TCC", 'S',
  "TCA", 'S',
  "TCG", 'S',
  "CCT", 'P',
  "CCC", 'P',
  "CCA", 'P',
  "CCG", 'P',
  "ACT", 'T',
  "ACC", 'T',
  "ACA", 'T',
  "ACG", 'T',
  "GCT", 'A',
  "GCC", 'A',
  "GCA", 'A',
  "GCG", 'A',
  "TAT", 'Y',
  "TAC", 'Y',
  "TAA", $stopCodonOcher,
  "TAG", $stopCodonAmber,
  "CAT", 'H',
  "CAC", 'H',
  "CAA", 'Q',
  "CAG", 'Q',
  "AAT", 'N',
  "AAC", 'N',
  "AAA", 'K',
  "AAG", 'K',
  "GAT", 'D',
  "GAC", 'D',
  "GAA", 'E',
  "GAG", 'E',
  "TGT", 'C',
  "TGC", 'C',
  "TGA", $stopCodonOpal,
  "TGG", 'W',
  "CGT", 'R',
  "CGC", 'R',
  "CGA", 'R',
  "CGG", 'R',
  "AGT", 'S',
  "AGC", 'S',
  "AGA", 'R',
  "AGG", 'R',
  "GGT", 'G',
  "GGC", 'G',
  "GGA", 'G',
  "GGG", 'G',
);

sub convert($) {
  return $table{$_[0]} if defined $table{$_[0]};

  return 'N';
}

1;
