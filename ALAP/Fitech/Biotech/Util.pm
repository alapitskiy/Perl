package ALAP::Fitech::Biotech::Util;

use Exporter 'import';
our @EXPORT = qw(allow_constructor_for);

sub allow_constructor_for {
  my $att_name = shift;

  return sub {
    my ($orig, $class) = (shift, shift);

    if (@_ == 1 and ! ref $_[0]) {
      return $class->$orig($att_name => $_[0]);
    }
    else {
      return $class->$orig(@_);
    }
  }
}

1;
